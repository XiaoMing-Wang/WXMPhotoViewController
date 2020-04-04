//
//  UIView+WXMPhoto.h
//  ModuleDebugging
//
//  Created by wq on 2019/5/19.
//  Copyright © 2019年 wq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (WXMPhoto)

/** 绝对定位 */
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;

@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) CGSize size;

@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat right;
@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat bottom;

/** 相对定位 */
@property (nonatomic, assign) BOOL layoutCenterSupView;
@property (nonatomic, assign) CGFloat layoutRight;
@property (nonatomic, assign) CGFloat layoutBottom;

@end

@interface UIScrollView (WXMPhoto)
@property (nonatomic, assign) CGFloat contentOffsetX;
@property (nonatomic, assign) CGFloat contentOffsetY;
@property (nonatomic, assign) CGFloat contentSizeWidth;
@property (nonatomic, assign) CGFloat contentSizeHeight;
@property (nonatomic, assign) CGFloat contentInsetTop;
@property (nonatomic, assign) CGFloat contentInsetLeft;
@property (nonatomic, assign) CGFloat contentInsetBottom;
@property (nonatomic, assign) CGFloat contentInsetRight;
@end

@interface UIButton (WXMPhoto)

/** 点击 block */
- (void)wp_addTarget:(id)target action:(SEL)action;
- (void)wp_setBackgroundImage:(NSString *)imageName;

/** 扩大Button的点击范围 */
- (void)wp_setEnlargeEdgeWithTop:(CGFloat)top
                             left:(CGFloat)left
                            right:(CGFloat)right
                           bottom:(CGFloat)bottom;
@end

@interface UIImage (WXMPhoto)
- (UIImage *)wp_redraw;
@end
