//
//  WXMPhotoShapeController.h
//  ModuleDebugging
//
//  Created by edz on 2019/5/17.
//  Copyright © 2019年 wq. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface TOCropOverlayView : UIView

/** Hides the interior grid lines, sans animation. */
@property (nonatomic, assign) BOOL gridHidden;

/** Add/Remove the interior horizontal grid lines. */
@property (nonatomic, assign) BOOL displayHorizontalGridLines;

/** Add/Remove the interior vertical grid lines. */
@property (nonatomic, assign) BOOL displayVerticalGridLines;

/** Shows and hides the interior grid lines with an optional crossfade animation. */
- (void)setGridHidden:(BOOL)hidden animated:(BOOL)animated;

@end
