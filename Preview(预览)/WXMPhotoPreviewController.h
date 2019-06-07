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

/** 是否显示视频 NO会显示为视频第一帧 */
@property (nonatomic, assign) BOOL showVideo;

/** 预览类型 */
@property (nonatomic, assign) WXMPhotoPreviewType previewType;

/** 存储被标记的图片model */
@property (nonatomic, strong) WXMDictionary_Array *signObj;
@property (nonatomic, strong) NSMutableDictionary *signDictionary;

/** 全部 */
@property (nonatomic, strong) NSMutableArray *dataSource;

/**  */
@property (nonatomic, strong) NSIndexPath *indexPath;

/** 回调 */
@property (nonatomic, copy) UIView* (^dragCallback)(void);
@property (nonatomic, copy) NSDictionary* (^callback)(NSInteger index, NSInteger rank);
@property (nonatomic, strong) WXMDictionary_Array* (^signCallback)(NSInteger index);

/** 转场背景 */
@property (nonatomic, strong) UIView *wxm_windowView;
@property (nonatomic, strong) UIView *wxm_contentView;

/** 回调 */
@property (nonatomic, weak) id<WXMPhotoProtocol> delegate;
@property (nonatomic, strong) void (^results)(UIImage *image);
@property (nonatomic, strong) void (^resultArray)(NSArray<UIImage *> *images);

@property (nonatomic, strong) UIImage * (^transitions)(NSInteger index);

/** 自定义转场使用 */
- (NSInteger)transitionIndex;
- (UIScrollView *)transitionScrollerView;
@end
