//
//  SActiviy.m
//  SShare
//
//  Created by Natan on 12/28/15.
//  Copyright © 2015 Natan. All rights reserved.
//

#import "OKActivity.h"
#import "OKActivityManager.h"
#import "OKManager.h"

@implementation OKActivity
+ (UIActivityCategory)activityCategory {
    return UIActivityCategoryShare;
}

- (NSString *)activityType {
    switch (self.type) {
        case OKActivityTypeQQFriends:
            return @"OKQQ";
        case OKActivityTypeWeibo:
            return @"OKWeibo";
        case OKActivityTypeWXFriends:
            return @"OKWXFriends";
        case OKActivityTypeWXCircle:
            return @"OKWXCircle";
        default:
            NSAssert(NO, @"invalid OKPlatform");
            break;
    }
    return @"";
}

// default returns nil. subclass must override and must return non-nil value
- (NSString *)activityTitle {
    switch (self.type) {
        case OKActivityTypeQQFriends:
            return @"QQ";
        case OKActivityTypeWeibo:
            return @"微博";
        case OKActivityTypeWXFriends:
            return @"微信好友";
        case OKActivityTypeWXCircle:
            return @"微信朋友圈";
        default:
            NSAssert(NO, @"invalid OKPlatform");
            break;
    }
}

- ( UIImage *)activityImage {
    return [OKActivityManager iconForActivityType:self.type];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return self.item != nil;
}

- (void)performActivity{
    OKPlatform platform;
    switch (self.type) {
        case OKActivityTypeQQFriends:
            platform = OKPlatformQQ;
            break;
        case OKActivityTypeWeibo:
            platform = OKPlatformWeibo;
            break;
        case OKActivityTypeWXCircle:
        case OKActivityTypeWXFriends:
            platform = OKPlatformWeChat;
            break;
        default:
            return;
    }
    [OKManager shareObject:self.item toPlatform:platform type:self.type completion:^(BOOL success) {
        [self activityDidFinish:YES];
    }];
    
}

@end
