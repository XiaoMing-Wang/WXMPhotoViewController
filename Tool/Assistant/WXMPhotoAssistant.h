//
//  WXMPhotoAssistant.h
//  ModuleDebugging
//
//  Created by edz on 2019/5/14.
//  Copyright © 2019年 wq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class PHAsset;

@interface WXMPhotoAssistant : NSObject

/** loadingView */
+ (void)wxm_showLoadingView:(UIView *)supView;

/** 根据颜色绘制图片 */
+ (UIImage *)wxmPhoto_imageWithColor:(UIColor *)color;

/** 获取截图view */
+ (UIView *)wxmPhoto_snapViewImage:(UIView *)screenshots;

/** 显示导航1px线条 */
+ (void)wxm_navigationLine:(UINavigationController *)nav show:(BOOL)show;

/** 获取原始图大小 */
+ (CGFloat)wxm_getOriginalSize:(PHAsset *)asset;

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
@end