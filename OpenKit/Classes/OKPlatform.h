//
//  OKPlatformInfo.h
//  SShare
//
//  Created by Natan on 12/28/15.
//  Copyright © 2015 Natan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OKActivity.h"

typedef NS_ENUM(NSInteger, OKPlatform) {
    OKPlatformWeibo,
    OKPlatformQQ,
    OKPlatformWeChat,
};

@interface OKPlatformInfo : NSObject
@property (nonatomic, copy, readonly) NSString *appKey;
@property (nonatomic, copy, readonly) NSString *appSecret;
@property (nonatomic, copy, readonly) NSURL *redirectURL;

- (instancetype)initWithAppKey:(NSString*)key
                        secret:(NSString*)secrect
             redirectURL:(NSURL*)url;
@end


@class OKAccount;
@class OKItem;

typedef void (^OKCompletion)(BOOL success);
typedef void (^OKLoginCompletion)(OKAccount *);

@protocol OKPlatformHandler <NSObject>
@required
- (BOOL)isShareSuppored;
- (BOOL)isPaySupported;
- (instancetype)initWithInfo:(OKPlatformInfo*)info;
- (void)shareObject:(OKItem*)item withType:(OKActivityType)type completion:(OKCompletion)completion;
- (void)loginInViewController:(UIViewController*)controller completion:(OKLoginCompletion)completion;
- (BOOL)handleOpenURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options;

@optional
- (void)sendPayRequest:(NSDictionary*)request completion:(OKCompletion)completion;
@end
