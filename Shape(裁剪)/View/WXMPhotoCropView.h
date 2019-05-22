//
//  WXMPhotoCropView.h
//  ModuleDebugging
//
//  Created by wq on 2019/5/18.
//  Copyright © 2019年 wq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXMPhotoOverlayView.h"

/** 触点类型 */
typedef NS_ENUM(NSInteger, WXMPhotoCropType) {
    WXMPhotoCropTypeNo = 0,
    
    /** 上下左右 */
    WXMPhotoCropTypeTop,
    WXMPhotoCropTypeBottom,
    WXMPhotoCropTypeLeft,
    WXMPhotoCropTypeRight,

    WXMPhotoCropTypeLeft_Top,    /** 左上角 */
    WXMPhotoCropTypeLeft_Bottom, /** 左下角 */
    WXMPhotoCropTypeRight_Top,   /** 右上角 */
    WXMPhotoCropTypeRight_Bottom /** 右下角 */
};

@interface WXMPhotoCropView : UIView

/** 显示的image */
@property(nonatomic, strong) UIImage *image;

/** 网格 */
@property(strong, readonly) WXMPhotoOverlayView *gridOverlayView;

- (instancetype)initWithImage:(UIImage *)image;
@end
