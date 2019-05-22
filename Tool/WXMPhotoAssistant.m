//
//  WXMPhotoAssistant.m
//  ModuleDebugging
//
//  Created by edz on 2019/5/14.
//  Copyright © 2019年 wq. All rights reserved.
//

#import "WXMPhotoAssistant.h"
#import "WXMPhotoConfiguration.h"
#import <objc/runtime.h>

@implementation WXMPhotoAssistant
static char wxm_Photoline;

/** 根据颜色回执图片 */
+ (UIImage *)wxmPhoto_imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

/** 截图 */
+ (UIImage *)wxmPhoto_makeViewImage:(UIView *)screenshots {
    CGSize size = CGSizeMake(WXMPhoto_Width, WXMPhoto_Height);
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    [screenshots.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
/** 显示导航1px线条 */
+ (void)wxm_navigationLine:(UINavigationController *)nav show:(BOOL)show {
    CALayer *line = objc_getAssociatedObject(nav, &wxm_Photoline);
    if (line && show == NO) line.hidden = YES;
    if (show == NO) return;;
    
    if (!line) {
        line = [CALayer layer];
        line.frame = CGRectMake(0, 44, WXMPhoto_Width, 0.5);
        line.backgroundColor = WXMBarLineColor.CGColor;
        [nav.navigationBar.layer addSublayer:line];
        objc_setAssociatedObject(nav, &wxm_Photoline, line, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    line.hidden = NO;
}

/** 获取 UIBarButtonItem*/
+ (UIBarButtonItem *)wxm_createButtonItem:(NSString *)title
                                   target:(id)target
                                   action:(SEL)action {
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:target action:action];
    buttonItem.tintColor = WXMBarTitleColor;
    return buttonItem;
}



/** 警告框 AlertViewController */
+ (void)showAlertViewControllerWithTitle:(NSString *)title
                                 message:(NSString *)message
                                  cancel:(NSString *)cancleString
                             otherAction:(NSArray *)otherAction
                           completeBlock:(void (^)(NSInteger index))block {
    
    UIAlertController *a=[UIAlertController alertControllerWithTitle:title message:message preferredStyle:1];
    UIAlertController *alert = a;
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:cancleString style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (block) block(0);
    }];
    
    [alert addAction:cancle];
    for (int i = 0; i < otherAction.count; i++) {
        NSString * title = otherAction[i];
        UIAlertAction *action = [UIAlertAction actionWithTitle:title style:0 handler:^(UIAlertAction *action) {
            if (block) block(i + 1);
        }];
        [alert addAction:action];
    }
    
    UIViewController * rootVC = WXMPhoto_KWindow.rootViewController;
    if (rootVC.presentedViewController) rootVC = rootVC.presentedViewController;
    [rootVC presentViewController:alert animated:YES completion:nil];
}

/** 布局 */
+ (void)setX:(CGFloat)x impView:(UIView *)impView {
    CGRect frame = impView.frame;
    frame.origin.x = x;
    impView.frame = frame;
}
+ (void)setRight:(CGFloat)right impView:(UIView *)impView {
    [self setX:right - impView.frame.size.width impView:impView];
}
+ (void)setY:(CGFloat)y impView:(UIView *)impView {
    CGRect frame = impView.frame;
    frame.origin.y = y;
    impView.frame = frame;
}
+ (void)setBottom:(CGFloat)bottom impView:(UIView *)impView {
    [self setY:bottom - impView.frame.size.height impView:impView];
}
+ (void)setWidth:(CGFloat)width impView:(UIView *)impView {
    CGRect frame = impView.frame;
    frame.size.width = width;
    impView.frame = frame;
}
+ (void)setHeight:(CGFloat)height impView:(UIView *)impView {
    CGRect frame = impView.frame;
    frame.size.height = height;
    impView.frame = frame;
}
+ (void)setCenterX:(CGFloat)centerX impView:(UIView *)impView {
    CGPoint point = impView.center;
    point.x = centerX;
    impView.center = point;
}
+ (void)setCenterY:(CGFloat)centerY impView:(UIView *)impView {
    CGPoint point = impView.center;
    point.y = centerY;
    impView.center = point;
}
@end
