//
//  QQHandler.m
//  SShare
//
//  Created by Natan on 12/28/15.
//  Copyright © 2015 Natan. All rights reserved.
//

#import "OKQQHandler.h"

#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/TencentOAuthObject.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import "OKItem.h"
#import "OKAccount.h"

@interface OKQQHandler ()<TencentSessionDelegate>

@end

@implementation OKQQHandler {
    TencentOAuth *_txOAuth;
    OKCompletion _shareCompletion;
    OKLoginCompletion _loginCompletion;
    NSError *_failure;
}

+ (instancetype)handler {
    static OKQQHandler *_handler;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _handler = [[OKQQHandler alloc] init];
    });
    return _handler;
}

- (BOOL)isShareSuppored {
    return [TencentOAuth iphoneQQSupportSSOLogin];
}

- (BOOL)isPaySupported {
    return NO;
}

- (instancetype)initWithInfo:(OKPlatformInfo*)info {
    self = [super init];
    if (self) {
        _txOAuth = [[TencentOAuth alloc] initWithAppId:info.appKey
                                         andDelegate:self];
        _failure = [[NSError alloc] initWithDomain:@"SShare" code:1001 userInfo:nil];
    }
    return self;
}

- (void)shareObject:(OKItem *)item withType:(OKActivityType)type completion:(OKCompletion)completion {
    _shareCompletion = NULL;
    NSData* data = UIImageJPEGRepresentation(item.image, 0.5);
    QQApiObject *obj;
    if (item.link) {
        obj = [QQApiNewsObject objectWithURL:item.link title:item.title description:item.desc previewImageData:data];
    } else {
        obj = [QQApiTextObject objectWithText:item.title];
    }
    SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:obj];
    QQApiSendResultCode result = [QQApiInterface sendReq:req];
    if (result == EQQAPISENDSUCESS) {
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
    _loginCompletion = NULL;
    NSArray *permissions = @[kOPEN_PERMISSION_GET_USER_INFO,
                             kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                             kOPEN_PERMISSION_ADD_ALBUM,
                             kOPEN_PERMISSION_ADD_ONE_BLOG,
                             kOPEN_PERMISSION_ADD_SHARE,
                             kOPEN_PERMISSION_ADD_TOPIC,
                             kOPEN_PERMISSION_CHECK_PAGE_FANS,
                             kOPEN_PERMISSION_GET_INFO,
                             kOPEN_PERMISSION_GET_OTHER_INFO,
                             kOPEN_PERMISSION_LIST_ALBUM,
                             kOPEN_PERMISSION_UPLOAD_PIC,
                             kOPEN_PERMISSION_GET_VIP_INFO,
                             kOPEN_PERMISSION_GET_VIP_RICH_INFO,
                             ];
    if ([_txOAuth authorize:permissions inSafari:NO]) {
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
    return [TencentOAuth HandleOpenURL:url];
}


/**
 * 登录成功后的回调
 */
- (void)tencentDidLogin {
    [_txOAuth getUserInfo];
}

/**
 * 登录失败后的回调
 * \param cancelled 代表用户是否主动退出登录
 */
- (void)tencentDidNotLogin:(BOOL)cancelled {
    
}

/**
 * 登录时网络有问题的回调
 */
- (void)tencentDidNotNetWork {
    if (_loginCompletion) {
        _loginCompletion(nil);
    }
}

/**
 * 登录时权限信息的获得
 */
- (NSArray *)getAuthorizedPermissions:(NSArray *)permissions withExtraParams:(NSDictionary *)extraParams {
    return nil;
}

/**
 * 退出登录的回调
 */
- (void)tencentDidLogout {
    
}

/**
 * 因用户未授予相应权限而需要执行增量授权。在用户调用某个api接口时，如果服务器返回操作未被授权，则触发该回调协议接口，由第三方决定是否跳转到增量授权页面，让用户重新授权。
 * \param tencentOAuth 登录授权对象。
 * \param permissions 需增量授权的权限列表。
 * \return 是否仍然回调返回原始的api请求结果。
 * \note 不实现该协议接口则默认为不开启增量授权流程。若需要增量授权请调用\ref TencentOAuth#incrAuthWithPermissions: \n注意：增量授权时用户可能会修改登录的帐号
 */
- (BOOL)tencentNeedPerformIncrAuth:(TencentOAuth *)tencentOAuth withPermissions:(NSArray *)permissions {
    return YES;
}

/**
 * [该逻辑未实现]因token失效而需要执行重新登录授权。在用户调用某个api接口时，如果服务器返回token失效，则触发该回调协议接口，由第三方决定是否跳转到登录授权页面，让用户重新授权。
 * \param tencentOAuth 登录授权对象。
 * \return 是否仍然回调返回原始的api请求结果。
 * \note 不实现该协议接口则默认为不开启重新登录授权流程。若需要重新登录授权请调用\ref TencentOAuth#reauthorizeWithPermissions: \n注意：重新登录授权时用户可能会修改登录的帐号
 */
- (BOOL)tencentNeedPerformReAuth:(TencentOAuth *)tencentOAuth {
    return YES;
}

/**
 * 用户通过增量授权流程重新授权登录，token及有效期限等信息已被更新。
 * \param tencentOAuth token及有效期限等信息更新后的授权实例对象
 * \note 第三方应用需更新已保存的token及有效期限等信息。
 */
- (void)tencentDidUpdate:(TencentOAuth *)tencentOAuth {
    
}

/**
 * 用户增量授权过程中因取消或网络问题导致授权失败
 * \param reason 授权失败原因，具体失败原因参见sdkdef.h文件中\ref UpdateFailType
 */
- (void)tencentFailedUpdate:(UpdateFailType)reason {
    
}

/**
 * 获取用户个人信息回调
 * \param response API返回结果，具体定义参见sdkdef.h文件中\ref APIResponse
 * \remarks 正确返回示例: \snippet example/getUserInfoResponse.exp success
 *          错误返回示例: \snippet example/getUserInfoResponse.exp fail
 */
- (void)getUserInfoResponse:(APIResponse*) response {
    if (!_loginCompletion) {
        return;
    }
    
    if (response.retCode == URLREQUEST_SUCCEED) {
        NSMutableString *str=[NSMutableString stringWithFormat:@""];
        for (id key in response.jsonResponse) {
            [str appendString: [NSString stringWithFormat:@"%@:%@\n",key,[response.jsonResponse objectForKey:key]]];
        }
        
        OKAccount *acc = [[OKAccount alloc] init];
        acc.openID = _txOAuth.openId;
        acc.accessToken = _txOAuth.accessToken;
        acc.expiredAt = [_txOAuth.expirationDate timeIntervalSince1970];
        acc.name = response.jsonResponse[@"nickname"];
        NSString *gender = response.jsonResponse[@"gender"];
        if ([gender isEqualToString:@"男"]) {
            acc.gender = OKGenderMale;
        } else if ([gender isEqualToString:@"女"]) {
            acc.gender = OKGenderFemale;
        }
        acc.avatar = response.jsonResponse[@"figureurl_qq_2"];
        _loginCompletion(acc);
    } else {
        _loginCompletion(nil);
    }
    _loginCompletion = NULL;
}



/**
 * 社交API统一回调接口
 * \param response API返回结果，具体定义参见sdkdef.h文件中\ref APIResponse
 * \param message 响应的消息，目前支持‘SendStory’,‘AppInvitation’，‘AppChallenge’，‘AppGiftRequest’
 */
- (void)responseDidReceived:(APIResponse*)response forMessage:(NSString *)message {
    
}

/**
 * post请求的上传进度
 * \param tencentOAuth 返回回调的tencentOAuth对象
 * \param bytesWritten 本次回调上传的数据字节数
 * \param totalBytesWritten 总共已经上传的字节数
 * \param totalBytesExpectedToWrite 总共需要上传的字节数
 * \param userData 用户自定义数据
 */
- (void)tencentOAuth:(TencentOAuth *)tencentOAuth didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite userData:(id)userData {
    
}


/**
 * 通知第三方界面需要被关闭
 * \param tencentOAuth 返回回调的tencentOAuth对象
 * \param viewController 需要关闭的viewController
 */
- (void)tencentOAuth:(TencentOAuth *)tencentOAuth doCloseViewController:(UIViewController *)viewController {
    
}

@end
