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

@interface WXMPhotoPreviewController : UIViewController

/** 相册模式 */
@property (nonatomic, assign) WXMPhotoDetailType photoType;

/** 期望获取图片大小 */
@property (nonatomic, assign) CGSize expectSize;

/** 是否显示视频 NO会显示为视频第一帧 */
@property (nonatomic, assign) BOOL showVideo;
@property (nonatomic, assign) BOOL isOriginalImage;

/** 预览类型 */
@property (nonatomic, assign) WXMPhotoPreviewType previewType;

/** 存储被标记的图片model */
@property (nonatomic, strong) WXMDictionary_Array *signObj;

/** 全部 */
@property (nonatomic, strong) NSMutableArray *dataSource;

/** 可以选中的个数 */
@property (nonatomic, assign) NSInteger selectedMaxCount;

/** 当前选中的index */
@property (nonatomic, strong) NSIndexPath *indexPath;

/** 回调 */
@property (nonatomic, copy) UIView* (^dragCallback)(void);
@property (nonatomic, strong) WXMDictionary_Array* (^signCallback)(NSInteger index);

/** 转场背景 */
@property (nonatomic, strong) UIView *wxm_windowView;
@property (nonatomic, strong) UIView *wxm_contentView;

/** 回调 */
@property (nonatomic, weak) id<WXMPhotoProtocol> delegate;

/** 自定义转场使用 */
- (NSInteger)transitionIndex;
- (UIScrollView *)transitionScrollerView;
@end
