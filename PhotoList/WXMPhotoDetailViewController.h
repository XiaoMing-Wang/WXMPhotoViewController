//
//  WXMPhotoDetailViewController.h
//  ModuleDebugging
//
//  Created by edz on 2019/5/6.
//  Copyright © 2019年 wq. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "WXMPhotoViewController.h"
#import "WXMPhotoConfiguration.h"

@class WXMPhotoList;
@interface WXMPhotoDetailViewController : UIViewController

/** 相册类型 */
// WXMPhotoDetailTypeGetPhoto = 0,             /* 单选原图大小 */
// WXMPhotoDetailTypeGetPhoto_256 = 1,         /* 单选256*256 */
// WXMPhotoDetailTypeGetPhotoCustomSize = 2,   /* 单选自定义大小 */
// WXMPhotoDetailTypeMultiSelect = 3,          /* 多选 + 预览 */
// WXMPhotoDetailTypeTailoring = 4,            /* 预览 + 裁剪 */
@property (nonatomic, assign) WXMPhotoDetailType photoType;

/** 是否有预览 默认YES */
/** WXMPhotoDetailTypeGetPhoto 和 WXMPhotoDetailTypeGetPhoto_256 设置才有效 */
@property (nonatomic, assign) BOOL exitPreview;

/** 期望获取图片大小 WXMPhotoDetailTypeTailoring WXMPhotoDetailTypeGetPhotoCustomSize 有效 */
@property (nonatomic, assign) CGSize expectSize;

/** 是否显示视频 NO会显示为视频第一帧 */
@property (nonatomic, assign) BOOL showVideo;

/** 是否可以选video (场景:已经选中图片的情况下不能再选择video) */
@property (nonatomic, assign) BOOL canSelectedVideo;

/** 是否需要解压 默认YES */
@property (nonatomic, assign) BOOL needUnpack;

/** 是否同时选择视频和图片 默认NO */
@property (nonatomic, assign) BOOL chooseVideoWithPhoto;

/** 可以选择多少张图片 0为WXMMultiSelectMax */
@property (nonatomic, assign) NSInteger multiSelectMax;

/** 可以选择多少个视频 0为WXMMultiSelectVideoMax(1的情况下视频没有选择圈) */
@property (nonatomic, assign) NSInteger multiSelectVideoMax;

/** 回调 */
@property (nonatomic, weak) id<WXMPhotoProtocol> delegate;

/** 自定义转场使用 */
- (UICollectionView *)transitionCollectionView;

@end
