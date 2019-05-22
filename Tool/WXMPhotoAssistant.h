//
//  WXMPhotoAssistant.h
//  ModuleDebugging
//
//  Created by edz on 2019/5/14.
//  Copyright © 2019年 wq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WXMPhotoAssistant : NSObject

/** 根据颜色回执图片 */
+ (UIImage *)wxmPhoto_imageWithColor:(UIColor *)color;

/** 截图 */
+ (UIImage *)wxmPhoto_makeViewImage:(UIView *)screenshots;

/** 显示导航1px线条 */
+ (void)wxm_navigationLine:(UINavigationController *)nav show:(BOOL)show;

/** 获取 ButtonItem */
+ (UIBarButtonItem *)wxm_createButtonItem:(NSString *)title
                                   target:(id)target
                                   action:(SEL)action;

/** 警告框 Alert*/
+ (void)showAlertViewControllerWithTitle:(NSString *)title
                                 message:(NSString *)message
                                  cancel:(NSString *)cancleString
                             otherAction:(NSArray *)otherAction
                           completeBlock:(void (^)(NSInteger index))block;


/** 布局 */
+ (void)setX:(CGFloat)x impView:(UIView *)impView;
+ (void)setRight:(CGFloat)right impView:(UIView *)impView;
+ (void)setY:(CGFloat)y impView:(UIView *)impView;
+ (void)setBottom:(CGFloat)bottom impView:(UIView *)impView;
+ (void)setWidth:(CGFloat)width impView:(UIView *)impView;
+ (void)setHeight:(CGFloat)height impView:(UIView *)impView;
+ (void)setCenterX:(CGFloat)centerX impView:(UIView *)impView;
+ (void)setCenterY:(CGFloat)centerY impView:(UIView *)impView;
@end
