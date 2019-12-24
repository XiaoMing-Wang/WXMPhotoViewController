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

/** 相册数组 */
@property (nonatomic, strong) WXMPhotoList *phoneList;

/** 相册类型 */
@property (nonatomic, assign) WXMPhotoDetailType photoType;

/** 可以选择多少张图片 0为WXMMultiSelectMax */
@property (nonatomic, assign) NSInteger multiSelectMax;

/** 可以选择多少个视频 0为WXMMultiSelectVideoMax */
@property (nonatomic, assign) NSInteger multiSelectVideoMax;

/** 是否可以选video (场景:已经选中图片的情况下不能再选择video) */
@property (nonatomic, assign) BOOL canSelectedVideo;

/** WXMPhotoDetailTypeGetPhoto 和
    WXMPhotoDetailTypeGetPhoto_256 设置有效 */
/** 是否有预览 默认YES */
@property (nonatomic, assign) BOOL exitPreview;

/** 是否显示视频 NO会显示为视频第一帧 */
@property (nonatomic, assign) BOOL showVideo;

/** 期望获取图片大小 */
@property (nonatomic, assign) CGSize expectSize;

/** 回调 */
@property (nonatomic, weak) id<WXMPhotoProtocol> delegate;

/** 自定义转场使用 */
- (UICollectionView *)transitionCollectionView;

@end
