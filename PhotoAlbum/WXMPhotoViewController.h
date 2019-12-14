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

/** 可以选择多少张图片 0为WXMMultiSelectMax */
@property (nonatomic, assign) NSInteger multiSelectMax;

/** 可以选择多少个视频 0为WXMMultiSelectVideoMax */
@property (nonatomic, assign) NSInteger multiSelectVideoMax;

/** 是否可以选video (场景:已经选中图片的情况下不能再选择video) */
@property (nonatomic, assign) BOOL canSelectedVideo;

/** 是否跳转相机胶卷 默认YES */
@property (nonatomic, assign) BOOL pushCamera;

/** WXMPhotoDetailTypeGetPhoto 和
    WXMPhotoDetailTypeGetPhoto_256和
    WXMPhotoDetailTypeGetPhotoCustomSize 设置有效 */
/** 是否有预览 默认YES */
@property (nonatomic, assign) BOOL exitPreview;

/** 是否显示视频 默认YES */
@property (nonatomic, assign) BOOL showVideo;

/** 期望返回图片的size nil返回预览时大小 */
/** WXMPhotoDetailTypeGetPhotoCustomSize和
    WXMPhotoDetailTypeMultiSelect 设置无效 */
@property (nonatomic, assign) CGSize expectSize;

/** 相册模式 */
@property (nonatomic, assign) WXMPhotoDetailType photoType;

/** 回调 */
@property (nonatomic, weak) id<WXMPhotoProtocol> delegate;
@end
