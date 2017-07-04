//
//  OKItem.h
//  SShare
//
//  Created by Natan on 12/28/15.
//  Copyright © 2015 Natan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OKPlatform.h"

typedef NS_ENUM(NSInteger, OKLinkType) {
    OKLinkTypeWebpage,
    OKLinkTypeImage,
    OKLinkTypeAudio,
    OKLinkTypeVideo,
};

@interface OKItem : NSObject
@property (nonatomic, copy) NSString *title; //required
@property (nonatomic, copy) NSString *desc; //optional
@property (nonatomic, strong) UIImage *image; //required
@property (nonatomic, strong) NSURL *link; //required
@property (nonatomic, assign) OKLinkType linkType; //not support
@end
