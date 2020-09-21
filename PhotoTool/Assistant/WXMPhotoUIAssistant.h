//
//  WXMPhotoAssistant.h
//  ModuleDebugging
//
//  Created by edz on 2019/5/14.
//  Copyright © 2019年 wq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
@class PHAsset;

@interface WXMPhotoUIAssistant : NSObject

/** loadingView */
+ (void)showLoadingView:(UIView *)supView;

/** 根据颜色绘制图片 */
+ (UIImage *)photoImageWithColor:(UIColor *)color;

/** 获取截图view */
+ (UIView *)photoSnapViewImage:(UIView *)screenshots;

/** 显示导航1px线条 */
+ (void)navigationLine:(UINavigationController *)nav show:(BOOL)show;

/** 获取原始图大小 */
+ (CGFloat)getOriginalSize:(PHAsset *)asset;
+ (CGFloat)getOriginalMultipartfile:(PHAsset *)asset;

/** 获取 ButtonItem */
+ (UIBarButtonItem *)createButtonItem:(NSString *)title
                                   target:(id)target
                                   action:(SEL)action;

/** 警告框 Alert*/
+ (void)showAlertViewControllerWithTitle:(NSString *)title
                                 message:(NSString *)message
                                  cancel:(NSString *)cancleString
                             otherAction:(NSArray *)otherAction
                           completeBlock:(void (^)(NSInteger index))block;
@end
