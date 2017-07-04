//
//  OKWXHandler.m
//  SShare
//
//  Created by Natan on 12/28/15.
//  Copyright © 2015 Natan. All rights reserved.
//

#import "OKWXHandler.h"
#import "WXApi.h"

#import "OKItem.h"
#import "OKAccount.h"
#import "OKActivity.h"
#import "UIImage+OpenKit.h"

static NSString *kAuthScope = @"snsapi_message,snsapi_userinfo,snsapi_friend,snsapi_contact";
static NSString *kAuthState = @"sns";

@implementation OKWXHandler {
    OKCompletion _shareCompletion;
    OKLoginCompletion _loginCompletion;
    OKCompletion _payCompletion;
    OKPlatformInfo *_info;
}

+ (instancetype)handler {
    static OKWXHandler *_handler;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _handler = [[OKWXHandler alloc] init];
    });
    return _handler;
}

- (BOOL)isShareSuppored {
    return [WXApi isWXAppInstalled];
}

- (BOOL)isPaySupported {
    return [WXApi isWXAppInstalled];
}

- (instancetype)initWithInfo:(OKPlatformInfo *)info {
    self = [super init];
    if (self) {
        _info = info;
        [WXApi registerApp:info.appKey];
    }
    return self;
}

- (void)shareObject:(OKItem *)item withType:(OKActivityType)type completion:(OKCompletion)completion {
    _shareCompletion = NULL;
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = item.title;
    message.description = item.desc;
    NSData *thumbData = UIImageJPEGRepresentation(item.image, 0.5);
    if (thumbData.length > 32 * 1024) {
        UIImage *img = [item.image OK_resizedImageOfSize:CGSizeMake(180, 180)];
        thumbData = UIImageJPEGRepresentation(img, 0.5);
    }
    message.thumbData = thumbData;
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = [item.link absoluteString];
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    if (type == OKActivityTypeWXCircle) {
        req.scene = WXSceneTimeline;
    } else {
        req.scene = WXSceneSession;
    }
    
    if([WXApi sendReq:req]) {
        _shareCompletion = completion;
    } else {
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO);
            });
        }
    }
}


- (void)sendPayRequest:(NSDictionary*)request completion:(OKCompletion)completion {
    _payCompletion = NULL;
    PayReq* req = [[PayReq alloc] init];
    req.partnerId = request[@"appId"];
    req.prepayId  = request[@"prepay_id"];
    req.nonceStr  = request[@"nonceStr"];
    req.timeStamp = [request[@"timeStamp"] intValue];
    req.package = @"Sign=WXPay";
    req.sign = request[@"paySign"];
    if ([WXApi sendReq:req]) {
        _payCompletion = completion;
    } else {
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO);
            });
        }
    }
}

- (void)loginInViewController:(UIViewController*)controller completion:(OKLoginCompletion)completion {
    _loginCompletion = NULL;
    SendAuthReq* req = [[SendAuthReq alloc] init];
    req.scope = kAuthScope; // @"post_timeline,sns"
    req.state = kAuthState;
    req.openID = _info.appKey;
    
    if ([WXApi sendAuthReq:req viewController:controller delegate:self]) {
        _loginCompletion = completion;
    } else {
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil);
            });
        }
    }
}

- (BOOL)handleOpenURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    return [WXApi handleOpenURL:url delegate:self];
}

- (void)onReq:(BaseReq *)req {

}

- (void)onResp:(BaseResp *)resp {
    if ([resp iOKindOfClass:[SendMessageToWXResp class]] &&_shareCompletion) {
        _shareCompletion(resp.errCode == WXSuccess);
        _shareCompletion = NULL;
    } else if ([resp iOKindOfClass:[SendAuthResp class]] && _loginCompletion) {
        SendAuthResp *authResp = (SendAuthResp *)resp;
        if (authResp.code.length == 0) {
            _loginCompletion(nil);
            _loginCompletion = NULL;
        } else {
            [self requestAccessToken:authResp];
        }
    } else if([resp iOKindOfClass:[PayResp class]] && _payCompletion){
        _payCompletion(resp.errCode == WXSuccess);
        _payCompletion = NULL;
    }
}

- (void)requestAccessToken:(SendAuthResp*)authResp {
    NSURLSession *session = [NSURLSession sharedSession];
    NSString *urlString = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code", _info.appKey, _info.appSecret, authResp.code];
    
    NSURLSessionTaOK *taOK = [session dataTaOKWithURL:[NSURL URLWithString:urlString]
                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                            
                                            if (!_loginCompletion) {
                                                return;
                                            }
                                            
                                            NSDictionary *tokenInfo = [NSJSONSerialization JSONObjectWithData:data
                                                                                                     options:NSJSONReadingAllowFragments
                                                                                                       error:nil];
                                            NSString *accessToken = tokenInfo[@"access_token"];
                                            if ([accessToken iOKindOfClass:[NSString class]] == NO || accessToken.length == 0) {
                                                _loginCompletion(nil);
                                                _loginCompletion = NULL;
                                            } else {
                                                [self requestUserInfo:tokenInfo];
                                            }
                                        }];
    [taOK resume];
}

- (void)requestUserInfo:(NSDictionary*)tokenInfo {
    NSString *urlStr = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@", tokenInfo[@"access_token"], _info.appKey];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTaOK *taOK = [session dataTaOKWithURL:[NSURL URLWithString:urlStr]
                                     completionHandler:^(NSData *  data, NSURLResponse *  response, NSError *  error) {
                                         if (!_loginCompletion) {
                                             return;
                                         }
                                         NSDictionary *userInfo = [NSJSONSerialization JSONObjectWithData:data
                                                                                                  options:NSJSONReadingAllowFragments
                                                                                                    error:nil];
                                         if (userInfo[@"nickname"] == nil) {
                                             _loginCompletion(nil);
                                         } else {
                                             OKAccount *account = [[OKAccount alloc] init];
                                             account.name = userInfo[@"nickname"];
                                             account.avatar = userInfo[@"headimgurl"];
                                             account.openID = userInfo[@"openid"];
                                             account.accessToken = tokenInfo[@"access_token"];
                                             account.refreshToken = tokenInfo[@"refresh_token"];
                                             account.unionid = userInfo[@"unionid"];
                                             account.expiredAt = [tokenInfo[@"expires_in"] integerValue] + [[NSDate date] timeIntervalSince1970];
                                             _loginCompletion(account);
                                         }
                                         _loginCompletion = NULL;
                                     }];
    [taOK resume];
}


@end
