//
//  OKAccount.h
//
//
//  Created by Natan on 12/28/15.
//  Copyright © 2015 Natan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OKPlatform.h"

typedef NS_ENUM(NSInteger, OKGender) {
    OKGenderUnknown = 0,
    OKGenderMale = 1,
    OKGenderFemale = 2,
};

@interface OKAccount : NSObject<NSCoding>
@property (nonatomic, assign) OKPlatform platform;
@property (nonatomic, copy) NSString *openID;
@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSString *refreshToken;
@property (nonatomic, copy) NSString *unionid;
@property (nonatomic, assign) NSTimeInterval expiredAt;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) OKGender gender;
@property (nonatomic, copy) NSString *avatar;
@end
