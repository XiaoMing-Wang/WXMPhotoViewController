//
//  PhotoViewController.h
//  DinpayPurse
//
//  Created by Mac on 17/2/20.
//  Copyright © 2017年 wq. All rights reserved.
/** 相册分组列表控制器*/
#import <UIKit/UIKit.h>
#import "WXMPhotoConfiguration.h"

@interface WXMPhotoViewController : UIViewController

/** 代理 */
@property (nonatomic, weak) id<WXMDetailTitleBarProtocol> delegate;

/** 显示选择框 */
- (void)showPhotoListController;

/** 隐藏选择框 */
- (void)hiddenPhotoListController;

@end
