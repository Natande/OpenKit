//
//  OKManager.m
//  SShare
//
//  Created by Natan on 12/28/15.
//  Copyright © 2015 Natan. All rights reserved.
//

#import "OKManager.h"
#import "OKWXHandler.h"
#import "OKQQHandler.h"
#import "OKWeiboHandler.h"

static NSMutableDictionary<NSNumber*,id<OKPlatformHandler> > *_handlers;

@implementation OKManager
+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _handlers = [[NSMutableDictionary alloc] init];
    });
}

+ (BOOL)isShareSuppored:(OKPlatform)platform {
    return [_handlers[@(platform)] isShareSuppored];
}


+ (BOOL)isPaySupported:(OKPlatform)platform {
    return [_handlers[@(platform)] isPaySupported];
}

+ (void)registerInfo:(OKPlatformInfo*)info forPlatform:(OKPlatform)platform {
    switch (platform) {
        case OKPlatformWeibo:
            _handlers[@(platform)] = [[OKWeiboHandler alloc] initWithInfo:info];
            break;
        case OKPlatformQQ:
            _handlers[@(platform)] = [[OKQQHandler alloc] initWithInfo:info];
            break;
        case OKPlatformWeChat:
            _handlers[@(platform)] = [[OKWXHandler alloc] initWithInfo:info];
            break;
        default:
            NSAssert(NO, @"invalid OKPlatform");
    }
}

+ (void)shareObject:(OKItem*)item toPlatform:(OKPlatform)platform type:(OKActivityType)type completion:(OKCompletion)completion {
    [_handlers[@(platform)] shareObject:item withType:type completion:completion];
}

+ (void)loginOnPlatform:(OKPlatform)platform inViewController:(UIViewController*)controller completion:(OKLoginCompletion)completion {
    [_handlers[@(platform)] loginInViewController:controller completion:completion];
}


+ (void)sendPayRequest:(NSDictionary*)request toPlatform:(OKPlatform)platform completion:(OKCompletion)completion {
    id<OKPlatformHandler> handler = _handlers[@(platform)];
    if ([handler respondsToSelector:@selector(sendPayRequest:completion:)]) {
        [handler sendPayRequest:request completion:completion];
    }
}

+ (BOOL)handleOpenURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    __block BOOL handled = NO;
    [_handlers enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, id<OKPlatformHandler>  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj handleOpenURL:url options:options]) {
            handled = YES;
            *stop = YES;
        }
    }];
    return handled;
}


@end
