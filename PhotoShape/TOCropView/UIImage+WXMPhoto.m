//
//  UIImage+WXMPhoto.m
//  ModuleDebugging
//
//  Created by edz on 2019/6/14.
//  Copyright © 2019 wq. All rights reserved.
//

#import "UIImage+WXMPhoto.h"

@implementation UIImage (WXMPhoto)

- (BOOL)hasAlpha {
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(self.CGImage);
    return (alphaInfo == kCGImageAlphaFirst || alphaInfo == kCGImageAlphaLast ||
            alphaInfo == kCGImageAlphaPremultipliedFirst ||
            alphaInfo == kCGImageAlphaPremultipliedLast);
}

- (UIImage *)croppedImageWithFrame:(CGRect)frame
                             angle:(NSInteger)angle
                      circularClip:(BOOL)circular {
    
    UIImage *croppedImage = nil;
    UIGraphicsBeginImageContextWithOptions(frame.size, ![self hasAlpha] && !circular, self.scale);
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        if (circular) {
            CGContextAddEllipseInRect(context, (CGRect){CGPointZero, frame.size});
            CGContextClip(context);
        }
        
        //To conserve memory in not needing to completely re-render the image re-rotated,
        //map the image to a view and then use Core Animation to manipulate its rotation
        if (angle != 0) {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:self];
            imageView.layer.minificationFilter = kCAFilterNearest;
            imageView.layer.magnificationFilter = kCAFilterNearest;
            imageView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, angle * (M_PI/180.0f));
            CGRect rotatedRect = CGRectApplyAffineTransform(imageView.bounds, imageView.transform);
            UIView *containerView = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, rotatedRect.size}];
            [containerView addSubview:imageView];
            imageView.center = containerView.center;
            CGContextTranslateCTM(context, -frame.origin.x, -frame.origin.y);
            [containerView.layer renderInContext:context];
        } else {
            CGContextTranslateCTM(context, -frame.origin.x, -frame.origin.y);
            [self drawAtPoint:CGPointZero];
        }
        
        croppedImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    return [UIImage imageWithCGImage:croppedImage.CGImage
                               scale:self.scale
                         orientation:UIImageOrientationUp];
}

- (UIImage*)scaleToSize:(CGSize)size {
    if ([[UIScreen mainScreen] scale] == 0.0) {
        UIGraphicsBeginImageContext(size);
    } else {
        UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    }
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

/** 按比例重绘图片 */
- (UIImage *)compressionImage {
    
    UIImage *image = self;
    
    /**  宽高比 */
    CGFloat ratio = image.size.width / image.size.height;

    /**  目标大小 */
    CGFloat targetW = 1280;
    CGFloat targetH = 1280;

    /**  宽高均 <= 1280，图片尺寸大小保持不变 */
    if (image.size.width < 1280 && image.size.height < 1280) {
        return image;
    } else if (image.size.width > 1280 && image.size.height > 1280) {

        /** 宽大于高 取较小值(高)等于1280，较大值等比例压缩 */
        if (ratio > 1) {
            targetH = 1280;
            targetW = targetH * ratio;
        } else {
            targetW = 1280;
            targetH = targetW / ratio;
        }
    } else {
        /**  宽或高 > 1280 宽图 图片尺寸大小保持不变 */
        if (ratio > 2) {
            targetW = image.size.width;
            targetH = image.size.height;
        } else if (ratio < 0.5) {
            /**   长图 图片尺寸大小保持不变 */
            targetW = image.size.width;
            targetH = image.size.height;
        } else if (ratio > 1) {
            /**  宽大于高 取较大值(宽)等于1280，较小值等比例压缩 */
            targetW = 1280;
            targetH = targetW / ratio;
        } else {
            /**  高大于宽 取较大值(高)等于1280，较小值等比例压缩 */
            targetH = 1280;
            targetW = targetH * ratio;
        }
    }
    return [self scaleToSize:CGSizeMake(targetW, targetH)];
}

/** 获取压缩后的data */
- (NSData *)compressionImageData {
    UIImage *newsImage = self.compressionImage;
    NSData *data = UIImageJPEGRepresentation(newsImage, 0.75);
    return data ?: nil;
}
@end
