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
@property (nonatomic, copy) NSDictionary* (^callback)(NSInteger index, NSInteger rank);

/**  */
@property (nonatomic, strong) UIImage *windowImage;
@property (nonatomic, strong) UIView *windowView;

/** 回调 */
@property (nonatomic, weak) id<WXMPhotoProtocol> delegate;
@property (nonatomic, strong) void (^results)(UIImage *image);
@property (nonatomic, strong) void (^resultArray)(NSArray<UIImage *> *images);

/** 动画 */
@property (nonatomic, strong) UIImage * (^transitions)(NSInteger index);
- (UIScrollView *)transitionScrollerView;
- (NSInteger)transitionIndex;
@end
