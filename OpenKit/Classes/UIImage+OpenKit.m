//
//  UIImage+S.m
//  OKit
//
//  Created by qiyu.tqy on 12/29/15.
//  Copyright © 2015 Natan. All rights reserved.
//

#import "UIImage+OpenKit.h"

@implementation UIImage (OpenKit)
- (UIImage*)OK_resizedImageOfSize:(CGSize)size {
    CGFloat w = self.size.width;
    CGFloat h = self.size.height;
    double ratio = h / w;
    double destRatio = size.height / size.width;
    if (fabs(ratio - destRatio) > 0.1 ) {
        CGFloat x = 0, y = 0;
        if (ratio > destRatio) {
            h = w * destRatio;
            y = (self.size.height - h) / 2;
        } else {
            w = h / destRatio;
            x = (self.size.width - w) / 2;
        }
        
        if (self.imageOrientation == UIImageOrientationLeft || self.imageOrientation == UIImageOrientationLeftMirrored || self.imageOrientation == UIImageOrientationRight || self.imageOrientation == UIImageOrientationRightMirrored){
            CGFloat temp = x;
            x = y;
            y = temp;
        }
        
        CGImageRef croppedImageRef = CGImageCreateWithImageInRect(self.CGImage, CGRectMake(x, y, w, h));
        UIImage *croppedImage = [UIImage imageWithCGImage:croppedImageRef scale:self.scale orientation:self.imageOrientation];
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
        [croppedImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        CGImageRelease(croppedImageRef);
        return resizedImage;
    } else {
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
        [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
        UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return resizedImage;
    }
}
@end
