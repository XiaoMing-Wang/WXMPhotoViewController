//
//  WXMPhotoPreviewTopView.m
//  ModuleDebugging
//
//  Created by edz on 2019/5/13.
//  Copyright © 2019年 wq. All rights reserved.
//

#import "WXMPhotoConfiguration.h"
#import "WXMPreviewTopBar.h"
@interface WXMPreviewTopBar ()
@property(nonatomic, strong) UIButton *leftButton;
@property(nonatomic, strong) UIButton *rightButton;
@end
@implementation WXMPreviewTopBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) [self setupInterface];
    return self;
}

/** 初始化界面 */
- (void)setupInterface {
    self.userInteractionEnabled = YES;
    self.frame = CGRectMake(0, 0, WXMPhoto_Width, WXMPhoto_BarHeight);
    self.backgroundColor = WXMPhoto_RGBColor(33, 33, 33);

    [self addSubview:self.leftButton];
    [self addSubview:self.rightButton];
}

/** 设置左按钮是否显示 */
- (void)setShowLeftButton:(BOOL)showLeftButton {
    _showLeftButton = showLeftButton;
    _leftButton.hidden = !_showLeftButton;
}

- (void)setShowRightButton:(BOOL)showRightButton  {
    _showRightButton = showRightButton;
    _rightButton.hidden = !_showRightButton;
}

/**  */
- (void)setSignModel:(WXMPhotoSignModel *)signModel {
    _signModel = signModel;
    if (signModel == nil) {
        self.rightButton.selected = NO;
        [self.rightButton setTitle:@"" forState:UIControlStateSelected];
    } else {
        self.rightButton.selected = YES;
        [self.rightButton setTitle:@(signModel.rank).stringValue forState:UIControlStateSelected];
    }
}

/** 左按钮 */
- (void)leftItemTouchEvents {
    if (self.delegate && [self.delegate respondsToSelector:@selector(wxm_touchTopLeftItem)]) {
        [self.delegate wxm_touchTopLeftItem];
    }
}

/** 右按钮 */
- (void)rightItemTouchEvents {
    if (self.delegate && [self.delegate respondsToSelector:@selector(wxm_touchTopRightItem:)]) {
        [self.delegate wxm_touchTopRightItem:self.signModel];
    }
}

/** 显示隐藏 */
- (void)setAccordingState:(BOOL)state {
    if (state) self.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = state;
    }];
}

/** 返回按钮 */
- (UIButton *)leftButton {
    if (!_leftButton) {
        _leftButton = [[UIButton alloc] initWithFrame:(CGRect){CGPointZero, 26, 26}];
        _leftButton.left = 8;
        _leftButton.bottom = self.height - (44 - _leftButton.height) / 2;
        [_leftButton wxm_setEnlargeEdgeWithTop:20 left:8 right:40 bottom:_leftButton.bottom];
        [_leftButton wxm_setBackgroundImage:@"live_icon_back"];
        [_leftButton wxm_addTarget:self action:@selector(leftItemTouchEvents)];
    }
    return _leftButton;
}

/** 选中按钮 */
- (UIButton *)rightButton {
    if (!_rightButton) {
        _rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 27, 27)];
        _rightButton.layoutRight = 12;
        _rightButton.centerY = self.leftButton.centerY;
        _rightButton.titleLabel.font = [UIFont systemFontOfSize:15];
        UIImage *normal = [UIImage imageNamed:@"photo_sign_default"];
        UIImage *selected = [UIImage imageNamed:@"photo_sign_background"];
        [_rightButton setBackgroundImage:normal forState:UIControlStateNormal];
        [_rightButton setBackgroundImage:selected forState:UIControlStateSelected];
        [_rightButton wxm_setEnlargeEdgeWithTop:20 left:40 right:10 bottom:_rightButton.bottom];
        [_rightButton wxm_addTarget:self action:@selector(rightItemTouchEvents)];
    }
    return _rightButton;
}

@end
