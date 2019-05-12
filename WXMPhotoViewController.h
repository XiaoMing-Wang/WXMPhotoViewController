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

/** 是否跳转相机胶卷 默认YES */
@property (nonatomic, assign) BOOL pushCamera;

/** 相册模式 */
@property (nonatomic, assign) WXMPhotoDetailType photoType;

/** 期望size 不传默认原图大小 */
@property (nonatomic, assign) CGSize expectSize;
@property (nonatomic, weak) id<WXMPhotoProtocol> delegate;

/** 回调 */
@property (nonatomic, strong) void (^results)(UIImage *image);
@property (nonatomic, strong) void (^resultArray)(NSArray<UIImage *> *images);
@end
