//
//  WXMPhotoPreviewController.h
//  ModuleDebugging
//
//  Created by edz on 2019/5/12.
//  Copyright © 2019年 wq. All rights reserved.
//
#import "WXMPhotoConfiguration.h"
#import <UIKit/UIKit.h>
#import "WXMDictionary_Array.h"

@protocol WXMPhotoPreviewRefreshDelegate <NSObject>

/** 刷新相册详情界面 */
- (void)wp_reloadPhotoDetailViewController;

/** 获取截图 */
- (UIView *)wp_getScreenshotsPhotoDetailViewController;

@end

@interface WXMPhotoPreviewController : UIViewController

/** 刷新代理 */
@property (nonatomic, assign) id <WXMPhotoPreviewRefreshDelegate>refreshDelegate;

/** 相册模式 */
@property (nonatomic, assign) WXMPhotoDetailType photoType;

/** 预览类型 单张预览 多张预览 */
@property (nonatomic, assign) WXMPhotoPreviewType previewType;

/** 是否显示视频 NO会显示为视频第一帧 */
@property (nonatomic, assign) BOOL showVideo;

/** 是否可以选video (场景:已经选中图片的情况下不能再选择video) */
@property (nonatomic, assign) BOOL canSelectedVideo;

/** 是否同时选择视频和图片 默认NO */
@property (nonatomic, assign) BOOL chooseVideoWithPhoto;

/** 可以选中多少张 */
@property (nonatomic, assign) NSInteger realSelectCount;

/** 可以选中多少个视频 */
@property (nonatomic, assign) NSInteger realSelectVideo;

/** 是否显示原图 */
@property (nonatomic, assign) BOOL isOriginalImage;

/** 当前选中的index */
@property (nonatomic, strong) NSIndexPath *indexPath;

/** 存储被标记的图片model */
@property (nonatomic, strong) WXMDictionary_Array *dictionaryArray;

/** 全部 */
@property (nonatomic, strong) NSMutableArray *dataSource;






/** 可以选中的个数 */
@property (nonatomic, assign) NSInteger selectedMaxCount;

/** 转场背景 */
@property (nonatomic, strong) UIView *wp_windowView;
@property (nonatomic, strong) UIView *wp_contentView;

/** 回调 */
@property (nonatomic, weak) id<WXMPhotoProtocol> delegate;

/** 自定义转场使用 */
- (NSInteger)transitionIndex;
- (UIScrollView *)transitionScrollerView;
@end
