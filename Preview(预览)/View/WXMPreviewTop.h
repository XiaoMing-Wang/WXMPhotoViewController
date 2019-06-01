//
//  WXMPhotoPreviewTopView.h
//  ModuleDebugging
//
//  Created by edz on 2019/5/13.
//  Copyright © 2019年 wq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXMPhotoSignModel.h"

@interface WXMPreviewTop : UIView
@property (nonatomic, assign) BOOL showLeftButton;
@property (nonatomic, assign) BOOL showRightButton;
@property (nonatomic, strong) WXMPhotoSignModel *signModel;
@property (nonatomic, assign) id<WXMPreviewToolbarProtocol> delegate;

/** 显示隐藏 */
- (void)setAccordingState:(BOOL)state;

@end
