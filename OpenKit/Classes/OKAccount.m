//
//  OKAccount.m
//  SShare
//
//  Created by Natan on 12/28/15.
//  Copyright © 2015 Natan. All rights reserved.
//

#import "OKAccount.h"

@implementation OKAccount
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.platform = [aDecoder decodeIntegerForKey:@"platform"];
        self.openID = [aDecoder decodeObjectForKey:@"open_id"];
        self.accessToken = [aDecoder decodeObjectForKey:@"access_token"];
        self.refreshToken = [aDecoder decodeObjectForKey:@"refresh_token"];
        self.expiredAt = [aDecoder decodeDoubleForKey:@"expired_at"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:self.platform forKey:@"platform"];
    [aCoder encodeObject:self.openID forKey:@"open_id"];
    [aCoder encodeObject:self.accessToken forKey:@"access_token"];
    [aCoder encodeObject:self.refreshToken forKey:@"refresh_token"];
    [aCoder encodeDouble:self.expiredAt forKey:@"expired_at"];
}
@end
