//
//  UIImage+WXMPhoto.h
//  ModuleDebugging
//
//  Created by edz on 2019/6/14.
//  Copyright © 2019 wq. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (WXMPhoto)

- (UIImage *)croppedImageWithFrame:(CGRect)frame
                             angle:(NSInteger)angle
                      circularClip:(BOOL)circular;


- (UIImage*)scaleToSize:(CGSize)size;
@end

NS_ASSUME_NONNULL_END
