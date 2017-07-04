//
//  OKManager.h
//  SShare
//
//  Created by Natan on 12/28/15.
//  Copyright © 2015 Natan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OKItem.h"
#import "OKAccount.h"
#import "OKPlatform.h"
#import "OKActivity.h"

@interface OKManager : NSObject

+ (BOOL)isShareSuppored:(OKPlatform)platform;

+ (BOOL)isPaySupported:(OKPlatform)platform;

+ (void)registerInfo:(OKPlatformInfo*)info forPlatform:(OKPlatform)platform;

+ (void)shareObject:(OKItem*)item toPlatform:(OKPlatform)platform type:(OKActivityType)type completion:(OKCompletion)completion;


+ (void)loginOnPlatform:(OKPlatform)platform inViewController:(UIViewController*)controller completion:(OKLoginCompletion)completion;

+ (void)sendPayRequest:(NSDictionary*)request toPlatform:(OKPlatform)platform completion:(OKCompletion)completion;

+ (BOOL)handleOpenURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options;

@end
