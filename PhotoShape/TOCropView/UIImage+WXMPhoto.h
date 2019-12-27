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

/** 修改图片大小 */
- (UIImage *)scaleToSize:(CGSize)size;

/** 按比例重绘图片 */
- (UIImage *)compressionImage;

/** 获取压缩后的data */
- (NSData *)compressionImageData;
@end

NS_ASSUME_NONNULL_END
