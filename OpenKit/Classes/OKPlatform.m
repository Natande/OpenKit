//
//  OKPlatformInfo.m
//  SShare
//
//  Created by Natan on 12/28/15.
//  Copyright © 2015 Natan. All rights reserved.
//

#import "OKPlatform.h"

@implementation OKPlatformInfo

- (instancetype)initWithAppKey:(NSString*)key secret:(NSString*)secrect redirectURL:(NSURL*)url {
    self = [super init];
    if (self) {
        _appKey = key;
        _appSecret = secrect;
        _redirectURL = url;
    }
    return self;
}
@end
