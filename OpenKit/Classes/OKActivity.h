//
//  SActiviy.h
//  SShare
//
//  Created by Natan on 12/28/15.
//  Copyright © 2015 Natan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, OKActivityType) {
    OKActivityTypeWeibo,
    OKActivityTypeQQFriends,
    OKActivityTypeWXFriends,
    OKActivityTypeWXCircle,
};

@class OKItem;
@interface OKActivity : UIActivity
@property (nonatomic, strong) OKItem *item;
@property (nonatomic, assign) OKActivityType type;
@end
