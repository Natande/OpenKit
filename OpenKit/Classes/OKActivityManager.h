//
//  OKActivityController.h
//  SShare
//
//  Created by Natan on 12/28/15.
//  Copyright © 2015 Natan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OKPlatform.h"
#import "OKItem.h"
#import "OKActivity.h"

@interface OKActivityManager : NSObject

+ (void)setAppIcon:(UIImage*)image;

+ (void)setExcludedSystemActivities:(NSArray*)activities;

+ (void)setIcon:(UIImage*)icon forActivityType:(OKActivityType)type;

+ (UIImage*)iconForActivityType:(OKActivityType)type;

+ (void)shareObject:(OKItem*)item
      activityTypes:(NSArray*)activityTypes
   inViewController:(UIViewController*)controller
         completion:(OKCompletion)completion;

@end
