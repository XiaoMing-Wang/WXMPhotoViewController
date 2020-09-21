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
@property (nonatomic, strong) UIView *line;
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
    
    self.promptLabel = [[UILabel alloc] init];
    self.promptLabel.frame = CGRectMake(0, WXMPhoto_BarHeight, WXMPhoto_Width, 40);
    self.promptLabel.text = @"   选择视频时不能选择图片";
    self.promptLabel.font = [UIFont systemFontOfSize:12];
    self.promptLabel.textColor = [UIColor whiteColor];
    self.promptLabel.backgroundColor = self.backgroundColor;
    self.promptLabel.numberOfLines = 1;
    self.promptLabel.hidden = YES;
    
    self.line = [UIView new];
    self.line.frame = CGRectMake(5, WXMPhoto_BarHeight, WXMPhoto_Width, 0.75);
    self.line.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
    self.line.hidden = YES;
    [self addSubview:self.promptLabel];
    [self addSubview:self.line];
}

/** 设置左按钮是否显示 */
- (void)setShowLeftButton:(BOOL)showLeftButton {
    _showLeftButton = showLeftButton;
    _leftButton.hidden = !_showLeftButton;
}

/** 设置右按钮是否显示 */
- (void)setShowRightButton:(BOOL)showRightButton  {
    _showRightButton = showRightButton;
    _rightButton.enabled = showRightButton;
    _rightButton.hidden = !_showRightButton;
}

/** 删除右按钮 */
- (void)deleteRightButton {
    [_rightButton removeFromSuperview];
}

/** 设置勾选框 */
- (void)setRecordModel:(WXMPhotoRecordModel *)recordModel {
    _recordModel = recordModel;
    if (recordModel == nil) {
        self.rightButton.selected = NO;
        [self.rightButton setTitle:@"" forState:UIControlStateSelected];
    } else {
        NSString *title = @(recordModel.recordRank).stringValue;
        self.rightButton.selected = YES;
        [self.rightButton setTitle:title forState:UIControlStateSelected];
    }
}

/** 目前选中的是那种资源 video image no三种 */
- (void)setChooseType:(WXMPhotoMediaType)chooseType asset:(WXMPhotoAsset *)asset unrestrictedmode:(NSInteger)unrestrictedmode {
    WXMPhotoMediaType assetType = asset.mediaType;
    self.line.hidden = self.promptLabel.hidden = YES;
    self.showRightButton = YES;
    if (unrestrictedmode == 0) {
        return;
    }

    /**< 视频超过时长的 */
    if (assetType == WXMPHAssetMediaTypeVideo && asset.asset.duration > WXMPhotoLimitVideoTime && WXMPhotoLimitVideoTime > 0) {
        self.showRightButton = NO;
        self.line.hidden = self.promptLabel.hidden = NO;
        self.promptLabel.text = [NSString stringWithFormat:@"   不支持超过%d秒的视频", WXMPhotoLimitVideoTime];
    }
    
    /** gif超过大小 */
    if (assetType == WXMPHAssetMediaTypePhotoGif && WXMPhotoLimitGIFSize > 0) {
        CGFloat multipartfile = [WXMPhotoUIAssistant getOriginalMultipartfile:asset.asset];
        if (multipartfile > WXMPhotoLimitGIFSize) {
            self.showRightButton = NO;
            self.line.hidden = self.promptLabel.hidden = NO;
            self.promptLabel.text = [NSString stringWithFormat:@"   不支持超过%dM的动图", WXMPhotoLimitGIFSize];
        }
    }
    
    /**< 单一选项 */
    if (unrestrictedmode == 2 && chooseType != WXMPHAssetMediaTypeNone)  {
        BOOL assetVideo = (assetType == WXMPHAssetMediaTypeVideo);
        if (chooseType == WXMPHAssetMediaTypeVideo) {
            if (assetVideo == NO) self.showRightButton = NO;
            self.line.hidden = self.promptLabel.hidden = assetVideo;
            self.promptLabel.text = @"    选择视频时不能选择图片";
        } else {
            if (assetVideo) self.showRightButton = NO;
            self.line.hidden = self.promptLabel.hidden = !assetVideo;
            self.promptLabel.text = @"    选择图片时不能选择视频";
        }
    }
}

/** 左按钮 */
- (void)leftItemTouchEvents {
    self.leftButton.userInteractionEnabled = NO;
    dispatch_time_t time_t = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.35 * NSEC_PER_SEC));
    dispatch_after(time_t, dispatch_get_main_queue(), ^{
        self.leftButton.userInteractionEnabled = YES;
    });
    
    if ([self.delegate respondsToSelector:@selector(wp_touchTopLeftItem)]) {
        [self.delegate wp_touchTopLeftItem];
    }
}

/** 右按钮 */
- (void)rightItemTouchEvents {
    self.rightButton.userInteractionEnabled = NO;
    dispatch_time_t time_t = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.35 * NSEC_PER_SEC));
    dispatch_after(time_t, dispatch_get_main_queue(), ^{
        self.rightButton.userInteractionEnabled = YES;
    });
    
    if ([self.delegate respondsToSelector:@selector(wp_touchTopRightItem:)]) {
        [self.delegate wp_touchTopRightItem:self.recordModel];
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
        [_leftButton wp_setEnlargeEdgeWithTop:20 left:8 right:40 bottom:_leftButton.bottom];
        [_leftButton wp_setBackgroundImage:@"live_icon_back"];
        [_leftButton wp_addTarget:self action:@selector(leftItemTouchEvents)];
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
        [_rightButton wp_setEnlargeEdgeWithTop:20 left:40 right:10 bottom:_rightButton.bottom];
        [_rightButton wp_addTarget:self action:@selector(rightItemTouchEvents)];
    }
    return _rightButton;
}

@end
