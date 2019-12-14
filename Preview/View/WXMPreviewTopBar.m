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
@property (nonatomic, strong) UILabel *promptLabel;
@property (nonatomic, strong) UIView * line;
@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *rightButton;
@end
@implementation WXMPreviewTopBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) [self setupInterface];
    return self;
}

/** 初始化界面 */
- (void)setupInterface {
    self.clipsToBounds = NO;
    self.userInteractionEnabled = YES;
    self.frame = CGRectMake(0, 0, WXMPhoto_Width, WXMPhoto_BarHeight);
    self.backgroundColor = WXMPhotoPreviewbarColor;

    [self addSubview:self.leftButton];
    [self addSubview:self.rightButton];
    
    _promptLabel = [[UILabel alloc] init];
    _promptLabel.frame = CGRectMake(0, WXMPhoto_BarHeight, WXMPhoto_Width, 40);
    _promptLabel.text = @"   选择视频时不能选择图片";
    _promptLabel.font = [UIFont systemFontOfSize:12];
    _promptLabel.textColor = [UIColor whiteColor];
    _promptLabel.backgroundColor = self.backgroundColor;
    _promptLabel.numberOfLines = 1;
    _promptLabel.hidden = YES;
    
    _line = [UIView new];
    _line.frame = CGRectMake(5, WXMPhoto_BarHeight, WXMPhoto_Width, 0.75);
    _line.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
    _line.hidden = YES;
    [self addSubview:_promptLabel];
    [self addSubview:_line];
}

/** 设置左按钮是否显示 */
- (void)setShowLeftButton:(BOOL)showLeftButton {
    _showLeftButton = showLeftButton;
    _leftButton.hidden = !_showLeftButton;
}

/** 设置右按钮是否显示 */
- (void)setShowRightButton:(BOOL)showRightButton  {
    _showRightButton = showRightButton;
    _rightButton.hidden = !_showRightButton;
}

/** 目前选中的是那种资源 video image no三种 */
- (void)setChooseType:(WXMPhotoMediaType)chooseType assetType:(WXMPhotoMediaType)assetType {
    self.line.hidden = self.promptLabel.hidden = YES;
    if (chooseType == WXMPHAssetMediaTypeNone) return;
    
    BOOL isVideo = (chooseType == WXMPHAssetMediaTypeVideo);
    BOOL assetVideo = (assetType == WXMPHAssetMediaTypeVideo);
    if (isVideo) {
        self.line.hidden = self.promptLabel.hidden = assetVideo;
        self.promptLabel.text = @"   选择视频时不能选择图片";
    } else {
        self.line.hidden = self.promptLabel.hidden = !assetVideo;
        self.promptLabel.text = @"   选择图片时不能选择视频";
    }
}

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
    self.leftButton.userInteractionEnabled = NO;
    dispatch_time_t time_t = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.35 * NSEC_PER_SEC));
    dispatch_after(time_t, dispatch_get_main_queue(), ^{
        self.leftButton.userInteractionEnabled = YES;
    });
    
    if ([self.delegate respondsToSelector:@selector(wxm_touchTopLeftItem)]) {
        [self.delegate wxm_touchTopLeftItem];
    }
}

/** 右按钮 */
- (void)rightItemTouchEvents {
    self.rightButton.userInteractionEnabled = NO;
    dispatch_time_t time_t = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.35 * NSEC_PER_SEC));
    dispatch_after(time_t, dispatch_get_main_queue(), ^{
        self.rightButton.userInteractionEnabled = YES;
    });
    
    if ([self.delegate respondsToSelector:@selector(wxm_touchTopRightItem:)]) {
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
