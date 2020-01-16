//
//  UIView+WXMPhoto.m
//  ModuleDebugging
//
//  Created by wq on 2019/5/19.
//  Copyright © 2019年 wq. All rights reserved.
//
#import <objc/runtime.h>
#import "UIView+WXMPhoto.h"

@implementation UIView (WXMPhoto)

@dynamic layoutRight;
@dynamic layoutBottom;
@dynamic layoutCenterSupView;

- (void)setX:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}
- (void)setY:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}
- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}
- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}
- (void)setCenterX:(CGFloat)centerX {
    CGPoint point = self.center;
    point.x = centerX;
    self.center = point;
}
- (void)setCenterY:(CGFloat)centerY {
    CGPoint point = self.center;
    point.y = centerY;
    self.center = point;
}
- (void)setOrigin:(CGPoint)origin {
    self.frame = (CGRect){ origin, self.size};
}
- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (void)setLeft:(CGFloat)left { [self setX:left]; }
- (void)setRight:(CGFloat)right { [self setX:right - self.width]; }
- (void)setTop:(CGFloat)top { [self setY:top]; }
- (void)setBottom:(CGFloat)bottom { [self setY:bottom - self.height]; }

- (CGFloat)x {return self.frame.origin.x;}
- (CGFloat)y {return self.frame.origin.y;}
- (CGFloat)width {return self.frame.size.width;}
- (CGFloat)height {return self.frame.size.height;}
- (CGFloat)centerX {return self.center.x;}
- (CGFloat)centerY {return self.center.y;}
- (CGFloat)left {return self.frame.origin.x; }
- (CGFloat)right {return self.left + self.width; }
- (CGFloat)top {return self.frame.origin.y;}
- (CGFloat)bottom {  return self.top + self.height; }
- (CGSize)size { return self.frame.size; }
- (CGPoint)origin { return self.frame.origin; }

/** 相对定位 */
- (void)setLayoutRight:(CGFloat)layoutRight {
    if (self.left != 0 && self.width != 0) return;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    if (self.superview) width = self.superview.width;
    if (self.width == 0) self.width = width - self.left - layoutRight;
    if (self.left == 0) self.left = width - self.width - layoutRight;
}

- (void)setLayoutBottom:(CGFloat)layoutBottom {
    if (self.top != 0 && self.height != 0) return;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    if (self.superview) height = self.superview.height;
    if (self.height == 0) self.height = height - self.top - layoutBottom;
    if (self.top == 0) self.top = height - self.height - layoutBottom;
}

- (void)setLayoutCenterSupView:(BOOL)layoutCenterSupView {
    if (!self.superview) return;
    if (layoutCenterSupView) {
        self.centerX = self.superview.width / 2;
        self.centerY = self.superview.height / 2;
    } else self.centerY = self.superview.height / 2;
}

@end

@implementation UIScrollView (WXMPhoto)
- (void)setContentOffsetX:(CGFloat)contentOffsetX {
    self.contentOffset = CGPointMake(contentOffsetX, self.contentOffset.y);
}
- (CGFloat)contentOffsetX {
    return self.contentOffset.x;
}
- (void)setContentOffsetY:(CGFloat)contentOffsetY {
    self.contentOffset = CGPointMake(self.contentOffset.x, contentOffsetY);
}
- (CGFloat)contentOffsetY {
    return self.contentOffset.y;
}

- (void)setContentSizeWidth:(CGFloat)contentSizeWidth {
    self.contentSize = CGSizeMake(contentSizeWidth, self.contentSize.height);
}
- (CGFloat)contentSizeWidth {
    return self.contentSize.width;
}

- (void)setContentSizeHeight:(CGFloat)contentSizeHeight {
    self.contentSize = CGSizeMake(self.contentSize.width, contentSizeHeight);
}
- (CGFloat)contentSizeHeight {
    return self.contentSize.height;
}

- (void)setContentInsetTop:(CGFloat)contentInsetTop {
    [self setContentInset:UIEdgeInsetsMake(contentInsetTop, self.contentInset.left, self.contentInset.bottom, self.contentInset.right)];
}
- (void)setContentInsetLeft:(CGFloat)contentInsetLeft {
    [self setContentInset:UIEdgeInsetsMake(self.contentInset.top, contentInsetLeft, self.contentInset.bottom, self.contentInset.right)];
}
- (void)setContentInsetBottom:(CGFloat)contentInsetBottom {
    [self setContentInset:UIEdgeInsetsMake(self.contentInset.top, self.contentInset.left, contentInsetBottom, self.contentInset.right)];
}
- (void)setContentInsetRight:(CGFloat)contentInsetRight {
    [self setContentInset:UIEdgeInsetsMake(self.contentInset.top, self.contentInset.left, self.contentInset.bottom, contentInsetRight)];
}
- (CGFloat)contentInsetTop {
    return self.contentInset.top;
}
- (CGFloat)contentInsetLeft {
    return self.contentInset.left;
}
- (CGFloat)contentInsetBottom {
    return self.contentInset.bottom;
}
- (CGFloat)contentInsetRight {
    return self.contentInset.right;
}
@end

static char p_touchUpInsideKey;
static char p_topNameKey;
static char p_bottomNameKey;
static char p_leftNameKey;
static char p_rightNameKey;

@implementation UIButton (WXMPhoto)


- (void)callActionBlock:(id)sender {
    void (^buttonBlock)(void) = (void (^)(void))objc_getAssociatedObject(self, &p_touchUpInsideKey);
    if (buttonBlock) buttonBlock();
}

/** */
- (void)wc_addTarget:(nullable id)target action:(SEL)action {
    [self addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

/** */
- (void)wxm_setBackgroundImage:(NSString *)imageName {
    [self setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}

/** 扩大点击 */
- (void)wc_setEnlargeEdgeWithTop:(CGFloat)top left:(CGFloat)left right:(CGFloat)right bottom:(CGFloat)bottom {
    objc_setAssociatedObject(self, &p_topNameKey, @(top), OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &p_rightNameKey, @(right), OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &p_bottomNameKey, @(bottom), OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &p_leftNameKey, @(left), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGRect)p_enlargedRect {
    NSNumber *topEdge = objc_getAssociatedObject(self, &p_topNameKey);
    NSNumber *rightEdge = objc_getAssociatedObject(self, &p_rightNameKey);
    NSNumber *bottomEdge = objc_getAssociatedObject(self, &p_bottomNameKey);
    NSNumber *leftEdge = objc_getAssociatedObject(self, &p_leftNameKey);
    if (topEdge && rightEdge && bottomEdge && leftEdge) {
        CGFloat x = self.bounds.origin.x - leftEdge.floatValue;
        CGFloat y = self.bounds.origin.y - topEdge.floatValue;
        CGFloat w = self.bounds.size.width + leftEdge.floatValue + rightEdge.floatValue;
        CGFloat h = self.bounds.size.height + topEdge.floatValue + bottomEdge.floatValue;
        return CGRectMake(x, y, w, h);
    } else return self.bounds;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect rect = [self p_enlargedRect];
    if (CGRectEqualToRect(rect, self.bounds)) return [super hitTest:point withEvent:event];
    return CGRectContainsPoint(rect, point) ? self : nil;
}



@end
