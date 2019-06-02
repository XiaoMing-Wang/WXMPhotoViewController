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

/** 是否有预览默认YES WXMPhotoDetailTypeGetPhoto 和 WXMPhotoDetailTypeGetPhoto_256设置有效 */
@property (nonatomic, assign) BOOL exitPreview;

/** 是否显示视频 NO会显示为视频第一帧 */
@property (nonatomic, assign) BOOL showVideo;

/** 期望size 不传默认原图大小 */
@property (nonatomic, assign) CGSize expectSize;

/** 相册模式 */
@property (nonatomic, assign) WXMPhotoDetailType photoType;

/** 回调 */
@property (nonatomic, weak) id<WXMPhotoProtocol> delegate;
@property (nonatomic, strong) void (^results)(UIImage *image);
@property (nonatomic, strong) void (^resultArray)(NSArray<UIImage *> *images);
@end
