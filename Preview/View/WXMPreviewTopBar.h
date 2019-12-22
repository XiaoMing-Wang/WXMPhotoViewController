//
//  WXMPhotoPreviewTopView.h
//  ModuleDebugging
//
//  Created by edz on 2019/5/13.
//  Copyright © 2019年 wq. All rights reserved.
//
//预览模式导航栏
#import <UIKit/UIKit.h>
#import "WXMPhotoSignModel.h"

@interface WXMPreviewTopBar : UIView

/** 显示左右按钮 */
@property (nonatomic, assign) BOOL showLeftButton;
@property (nonatomic, assign) BOOL showRightButton;
@property (nonatomic, strong) WXMPhotoSignModel *signModel;
@property (nonatomic, assign) id<WXMPreviewToolbarProtocol> delegate;

/** 显示隐藏 */
- (void)setAccordingState:(BOOL)state;

/** 目前选中的是那种资源 video image no三种 */
- (void)setChooseType:(WXMPhotoMediaType)chooseType asset:(WXMPhotoAsset *)asset;
@end
