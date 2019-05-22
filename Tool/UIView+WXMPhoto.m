//
//  UIView+WXMPhoto.m
//  ModuleDebugging
//
//  Created by wq on 2019/5/19.
//  Copyright © 2019年 wq. All rights reserved.
//

#import "UIView+WXMPhoto.h"

@implementation UIView (WXMPhoto)

- (void)setX:(CGFloat)x {
    CGRect frame   = self.frame;
    frame.origin.x = x;
    self.frame     = frame;
}
- (void)setY:(CGFloat)y {
    CGRect frame   = self.frame;
    frame.origin.y = y;
    self.frame     = frame;
}
- (void)setWidth:(CGFloat)width {
    CGRect frame     = self.frame;
    frame.size.width = width;
    self.frame       = frame;
}
- (void)setHeight:(CGFloat)height {
    CGRect frame      = self.frame;
    frame.size.height = height;
    self.frame        = frame;
}
- (void)setCenterX:(CGFloat)centerX {
    CGPoint point = self.center;
    point.x       = centerX;
    self.center   = point;
}
- (void)setCenterY:(CGFloat)centerY {
    CGPoint point = self.center;
    point.y       = centerY;
    self.center   = point;
}
- (void)setOrigin:(CGPoint)origin {
    self.frame = (CGRect) { origin, self.size };
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
