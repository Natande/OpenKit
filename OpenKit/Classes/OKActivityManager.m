//
//  OKActivityController.m
//  SShare
//
//  Created by Natan on 12/28/15.
//  Copyright © 2015 Natan. All rights reserved.
//

#import "OKActivityManager.h"
#import "OKActivity.h"

static NSMutableDictionary *_activityIcons;
static NSArray *_excludedActivities;
static UIImage *_appIcon;

@implementation OKActivityManager
+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _activityIcons = [[NSMutableDictionary alloc] init];
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_8_4) {
            _excludedActivities = @[UIActivityTypePrint,
                                    UIActivityTypeSaveToCameraRoll,
                                    UIActivityTypeAssignToContact,
                                    UIActivityTypeAddToReadingList,
                                    UIActivityTypePostToFlickr,
                                    UIActivityTypePostToVimeo,
                                    UIActivityTypePostToTencentWeibo,
                                    UIActivityTypePostToWeibo,
                                    UIActivityTypePostToTwitter,
                                    UIActivityTypePostToFacebook,
                                    UIActivityTypeOpenInIBooks];
        } else {
            _excludedActivities = @[UIActivityTypePrint,
                                    UIActivityTypeSaveToCameraRoll,
                                    UIActivityTypeAssignToContact,
                                    UIActivityTypeAddToReadingList,
                                    UIActivityTypePostToFlickr,
                                    UIActivityTypePostToVimeo,
                                    UIActivityTypePostToTencentWeibo,
                                    UIActivityTypePostToWeibo,
                                    UIActivityTypePostToTwitter,
                                    UIActivityTypePostToFacebook];
        }
    });
}

+ (void)setAppIcon:(UIImage *)image {
    _appIcon = image;
}

+ (void)setIcon:(UIImage*)icon forActivityType:(OKActivityType)type {
    _activityIcons[@(type)] = icon;
}

+ (UIImage*)iconForActivityType:(OKActivityType)type {
    UIImage *icon = _activityIcons[@(type)];
    if (!icon) {
        NSString *name = @"";
        switch (type) {
            case OKActivityTypeQQFriends:
                name = @"OK_qq";
                break;
            case OKActivityTypeWXCircle:
                name = @"OK_circle";
                break;
            case OKActivityTypeWXFriends:
                name = @"OK_wx";
                break;
            case OKActivityTypeWeibo:
                name = @"OK_weibo";
                break;
            default:
                break;
        }
        
        if (name.length > 0) {
            icon = [UIImage imageNamed:name inBundle:[NSBundle bundleForClass:self] compatibleWithTraitCollection:nil];
        }
    }
    return icon;
}

+ (void)setExcludedSystemActivities:(NSArray*)activities {
    _excludedActivities = activities;
}

+ (void)shareObject:(OKItem*)item
      activityTypes:(NSArray *)activityTypes
 inViewController:(UIViewController*)controller
 completion:(OKCompletion)completion {
    NSMutableArray *items = [[NSMutableArray alloc] init];
    [items addObject:item.title];
    
    if (item.title) {
        [items addObject:item.title];
    }
    
    if (item.desc) {
        [items addObject:item.desc];
    }
    
    if (!item.image) {
        item.image = _appIcon;
    }
    
    if (item.image) {
        [items addObject:item.image];
    }
    
    if (item.link) {
        [items addObject:item.link];
    }
    
    NSMutableArray *activities = [[NSMutableArray alloc] init];
    for (NSNumber *type in activityTypes) {
        OKActivity *activity = [[OKActivity alloc] init];
        activity.item = item;
        activity.type = [type integerValue];
        [activities addObject:activity];
    }
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:activities];
    activityController.excludedActivityTypes = _excludedActivities;
    [controller presentViewController:activityController animated:YES completion:nil];
}
@end
