//
//  WXMPhotoGIFImage.h
//  ModuleDebugging
//
//  Created by wq on 2019/5/18.
//  Copyright © 2019年 wq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WXMPhotoGIFImage : UIImage

///-----------------------
/// @name Image Attributes
///-----------------------

/**
 A C array containing the frame durations.
 
 The number of frames is defined by the count of the `images` array property.
 */
@property (nonatomic, readonly) NSTimeInterval *frameDurations;

/**
 Total duration of the animated image.
 */
@property (nonatomic, readonly) NSTimeInterval totalDuration;

/**
 Number of loops the image can do before it stops
 */
@property (nonatomic, readonly) NSUInteger loopCount;

- (UIImage *)getFrameWithIndex:(NSUInteger)idx;

@end
