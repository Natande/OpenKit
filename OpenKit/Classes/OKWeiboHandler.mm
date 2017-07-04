//
//  OKWeiboHandler.m
//  SShare
//
//  Created by Natan on 12/28/15.
//  Copyright © 2015 Natan. All rights reserved.
//

#import "OKWeiboHandler.h"
#import "WeiboSDK.h"
#import "WeiboUser.h"
#import "WBHttpRequest+WeiboUser.h"
#import "OKItem.h"
#import "OKAccount.h"
#import "UIImage+OpenKit.h"

@interface OKWeiboHandler ()<WeiboSDKDelegate>
@end

@implementation OKWeiboHandler {
    OKPlatformInfo *_info;
    OKLoginCompletion _loginCompletion;
    OKCompletion _shareCompletion;
}

- (BOOL)isShareSuppored {
    return [WeiboSDK isCanSSOInWeiboApp];
}


- (BOOL)isPaySupported {
    return NO;
}

- (instancetype)initWithInfo:(OKPlatformInfo *)info {
    self = [super init];
    if (self) {
        _info = info;
        [WeiboSDK registerApp:info.appKey];
    }
    return self;
}

- (void)shareObject:(OKItem *)item withType:(OKActivityType)type completion:(OKCompletion)completion {
    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    authRequest.redirectURI = _info.redirectURL.absoluteString;
    authRequest.scope = @"all";
    
    WBMessageObject *message = [WBMessageObject message];
    message.text = item.title;

    if (item.link) {
        WBWebpageObject *webpage = [WBWebpageObject object];
        webpage.objectID = @"hello";
        webpage.title = item.title;
        webpage.description = item.desc;
        NSData *thumbData = UIImageJPEGRepresentation(item.image, 0.5);
        if (thumbData.length > 32 * 1024) {
            UIImage *img = [item.image OK_resizedImageOfSize:CGSizeMake(180, 180)];
            thumbData = UIImageJPEGRepresentation(img, 0.5);
        }
        webpage.thumbnailData = thumbData;
        webpage.webpageUrl = [item.link absoluteString];
        message.mediaObject = webpage;
    } else if (item.image) {
        WBImageObject *image = [WBImageObject object];
        image.imageData = UIImageJPEGRepresentation(item.image, 1.0);
        message.imageObject = image;
    }
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message authInfo:authRequest access_token:nil];
    if ([WeiboSDK sendRequest:request]) {
        _shareCompletion = completion;
    } else {
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO);
            });
        }
    }
}

- (void)loginInViewController:(UIViewController*)controller completion:(OKLoginCompletion)completion {
    _loginCompletion = completion;
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = _info.redirectURL.absoluteString;
    request.scope = @"all";
    [WeiboSDK sendRequest:request];
}

- (BOOL)handleOpenURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    return [WeiboSDK handleOpenURL:url delegate:self];
}


/**
 收到一个来自微博客户端程序的请求
 
 收到微博的请求后，第三方应用应该按照请求类型进行处理，处理完后必须通过 [WeiboSDK sendResponse:] 将结果回传给微博
 @param request 具体的请求对象
 */
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request {
    
}

/**
 收到一个来自微博客户端程序的响应
 
 收到微博的响应后，第三方应用可以通过响应类型、响应的数据和 WBBaseResponse.userInfo 中的数据完成自己的功能
 @param response 具体的响应对象
 */
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response {
    if ([response iOKindOfClass:WBAuthorizeResponse.class] && _loginCompletion) {
        WBAuthorizeResponse *authResp = (WBAuthorizeResponse*)response;
        if (authResp.statusCode != WeiboSDKResponseStatusCodeSuccess) {
            _loginCompletion(nil);
            _loginCompletion = NULL;
        } else {
            [self requestUserProfileWithAuthResp:authResp];
        }
    } else if ([response iOKindOfClass:WBSendMessageToWeiboResponse.class] && _shareCompletion) {
        if (response.statusCode != WeiboSDKResponseStatusCodeSuccess) {
            _shareCompletion(NO);
        } else {
            _shareCompletion(YES);
        }
        _shareCompletion = NULL;
    }
}

- (void)requestUserProfileWithAuthResp:(WBAuthorizeResponse*)authResp {
    [WBHttpRequest requestForUserProfile:authResp.userID
                         withAccessToken:authResp.accessToken
                      andOtherProperties:nil
                                   queue:nil
                   withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
                       if (!_loginCompletion) {
                           return;
                       }
                       
                       if ([result iOKindOfClass:[WeiboUser class ]]) {
                           WeiboUser *user = result;
                           OKAccount *acc = [[OKAccount alloc] init];
                           acc.openID = user.userID;
                           acc.name = user.name;
                           acc.accessToken = authResp.accessToken;
                           acc.expiredAt = [authResp.expirationDate timeIntervalSince1970];
                           acc.refreshToken = authResp.refreshToken;
                           acc.avatar = user.avatarHDUrl;
                           acc.platform = OKPlatformWeibo;
                           if ([user.gender isEqualToString:@"m"]) {
                               acc.gender = OKGenderMale;
                           } else if ([user.gender isEqualToString:@"f"]) {
                               acc.gender = OKGenderFemale;
                           }
                           _loginCompletion(acc);
                       } else {
                           _loginCompletion(nil);
                       }
                       _loginCompletion = NULL;
                   }];
}

@end
