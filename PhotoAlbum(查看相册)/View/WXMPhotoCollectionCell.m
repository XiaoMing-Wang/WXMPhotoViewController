//
//  WXMPhotoCollectionCell.m
//  ModuleDebugging
//
//  Created by wq on 2019/5/18.
//  Copyright © 2019年 wq. All rights reserved.
//
#import "WXMPhotoCollectionCell.h"
#import "WXMPhotoConfiguration.h"

@interface WXMPhotoCollectionCell ()

/** 白色蒙版 */
@property(nonatomic, strong) UIView *maskCoverView;

/** 图片 */
@property(nonatomic, strong) UIImageView *imageView;

/** 资源类型标记 */
@property(nonatomic, strong) UIButton *typeSign;

/** 勾选框  */
@property (nonatomic, strong) UIButton *chooseButton;

@property (nonatomic, assign) int32_t currentRequestID;
@end

@implementation WXMPhotoCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) [self setupInterface];
    return self;
}

- (void)setupInterface {
    _userCanTouch = YES;
    _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = YES;
    [self.contentView addSubview:self.imageView];
}

/** 设置相册类型 */
- (void)setPhotoType:(WXMPhotoDetailType)photoType {
    _photoType = photoType;
    if (photoType == WXMPhotoDetailTypeMultiSelect) {
        [self.contentView addSubview:self.maskCoverView];
        [self.contentView addSubview:self.chooseButton];
    }
}

/** 异步赋值 数量特别多异步获取 */
- (void)setPhotoAsset:(WXMPhotoAsset *)photoAsset {
    @autoreleasepool {
        _photoAsset = photoAsset;
        WXMPhotoManager *man = [WXMPhotoManager sharedInstance];
        
        if (photoAsset.smallImage) {
            self.imageView.image = photoAsset.smallImage;
            if (self.currentRequestID) [man cancelRequestWithID:self.currentRequestID];
            return;
        }

        PHAsset *asset = photoAsset.asset;
        CGSize size = CGSizeMake(WXMItemWidth, WXMItemWidth);
        if (self.currentRequestID) [man cancelRequestWithID:self.currentRequestID];
        int32_t ids = [man getPictures_customSize:asset synchronous:NO assetSize:size completion:^(UIImage *image) {
            self.photoAsset.aspectRatio = image.size.height / image.size.width * 1.0;
            self.imageView.image = image;
            photoAsset.smallImage = image;
        }];
        
        self.currentRequestID = ids;
        self.photoAsset.requestID = ids;
        [self wxm_setTypeSignInterface];
    }
}

/** 设置能否响应 */
- (void)setUserCanTouch:(BOOL)userCanTouch animation:(BOOL)animation {
    _userCanTouch = userCanTouch;
    
    /** 用户能否点击 */
    CGFloat duration = animation ? 0.2 : 0;
    [UIView animateWithDuration:duration animations:^{ self.maskCoverView.alpha = !userCanTouch;}];
}


/** 多选模式下设置代理 */
- (void)setDelegate:(id<WXMPhotoSignProtocol>)delegate
          indexPath:(NSIndexPath *)indexPath
          signModel:(WXMPhotoSignModel *)signModel
           showMask:(BOOL)showMask {
    
    _delegate = delegate;
    _indexPath = indexPath;
    _signModel = signModel;
    [self signButtonSelected:(signModel != nil)];
    [self wxm_setTypeSignInterface];
    
    if (showMask == NO) [self setUserCanTouch:YES animation:NO];
    else [self setUserCanTouch:(signModel != nil) animation:NO];
}

/** 设置显示界面效果 */
- (void)wxm_setTypeSignInterface {
    if (_photoAsset.mediaType == WXMPHAssetMediaTypeVideo && WXMPhotoShowVideoSign) {
        [self.contentView addSubview:self.typeSign];
        NSString * duration = [NSString stringWithFormat:@"  %@",_photoAsset.videoDrantion];
        [self.typeSign setTitle:duration forState:UIControlStateNormal];
        [self.typeSign setImage:[UIImage imageNamed:@"photo_videoSmall"] forState:UIControlStateNormal];
        self.typeSign.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        self.typeSign.titleLabel.font = [UIFont systemFontOfSize:12];
        
    } else if (_photoAsset.mediaType == WXMPHAssetMediaTypePhotoGif && WXMPhotoShowGIFSign) {
        [self.contentView addSubview:self.typeSign];
        self.typeSign.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [self.typeSign setTitle:@"  GIF" forState:UIControlStateNormal];
        [self.typeSign setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        self.typeSign.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    } else {
        [self.typeSign removeFromSuperview];
    }
    [self.contentView bringSubviewToFront:self.typeSign];
}

/** 设置button选中 */
- (void)signButtonSelected:(BOOL)selected {
    _chooseButton.selected = selected;
    if (selected) {
        [_chooseButton setTitle:@(_signModel.rank).stringValue forState:UIControlStateSelected];
    } else {
        [_chooseButton setTitle:@"" forState:UIControlStateNormal];
        [_chooseButton setTitle:@"" forState:UIControlStateSelected];
    }
}

/** 点击 */
- (void)wxm_touchEvent {
    if (self.userCanTouch == NO) {
        [self wxm_showAlertController];
        return;
    }
    
    _chooseButton.selected = !_chooseButton.selected;
    [_chooseButton setTitle:@"" forState:UIControlStateNormal];
    [_chooseButton setTitle:@"" forState:UIControlStateSelected];
    [self setAnimation];

    /** 设置第几个选中 */
    if (self.delegate && [self.delegate respondsToSelector:@selector(touchWXMPhotoSignView:selected:)]) {
        NSInteger count = [self.delegate touchWXMPhotoSignView:_indexPath selected:_chooseButton.selected];
        if (count >= 0 && count < WXMMultiSelectMax)  {
            [_chooseButton setTitle:@(count + 1).stringValue forState:UIControlStateSelected];
        }
    }
}

/** 设置动画 */
- (void)setAnimation {
    if (!self.chooseButton.selected) return;
    self.chooseButton.userInteractionEnabled = NO;
    self.chooseButton.transform = CGAffineTransformMakeScale(0.3, 0.3);
    [UIView animateWithDuration:1.f delay:0 usingSpringWithDamping:0.4 initialSpringVelocity:0.0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        self.chooseButton.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.chooseButton.userInteractionEnabled = YES;
    }];
}

/** 提示框 */
- (void)wxm_showAlertController {
    NSString *title = [NSString stringWithFormat:@"您最多可以选择%d张图片",WXMMultiSelectMax];
    [WXMPhotoAssistant showAlertViewControllerWithTitle:title message:@"" cancel:@"知道了"
                                            otherAction:nil completeBlock:nil];
}

/** 刷新标号排名 */
- (void)refreshRankingWithSignModel:(WXMPhotoSignModel *)signModel {
    _signModel = signModel;
    [_chooseButton setTitle:@(_signModel.rank).stringValue forState:UIControlStateSelected];
}

/** 标志view */
- (UIButton *)typeSign {
    if (!_typeSign) {
        _typeSign = [[UIButton alloc] init];
        _typeSign.size = CGSizeMake(_imageView.width - 10, 20);
        _typeSign.bottom = _imageView.height - 5;
        _typeSign.left = 5;
        _typeSign.userInteractionEnabled = NO;
        _typeSign.titleLabel.font = [UIFont systemFontOfSize:12];
        [_typeSign setTitle:@"  00:66" forState:UIControlStateNormal];
        [_typeSign setImage:[UIImage imageNamed:@"photo_videoOverlay2"] forState:UIControlStateNormal];
    }
    return _typeSign;
}

/** 白色蒙版 */
- (UIView *)maskCoverView {
    if (!_maskCoverView) {
        _maskCoverView = [[UIView alloc] initWithFrame:self.bounds];
        _maskCoverView.alpha = 0;
        _maskCoverView.userInteractionEnabled = NO;
        _maskCoverView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.65];
    }
    return _maskCoverView;
}

- (UIButton *)chooseButton {
    if (!_chooseButton) {
        _chooseButton = [[UIButton alloc] init];
        UIImage *normal = [UIImage imageNamed:@"photo_sign_default"];
        UIImage *selected = [UIImage imageNamed:@"photo_sign_background"];
        _chooseButton = [[UIButton alloc] initWithFrame:CGRectMake(0,3, WXMSelectedWH, WXMSelectedWH)];
        _chooseButton.right = self.contentView.width - 3;
        _chooseButton.titleLabel.font = [UIFont systemFontOfSize:WXMSelectedFont];
        [_chooseButton setBackgroundImage:normal forState:UIControlStateNormal];
        [_chooseButton setBackgroundImage:selected forState:UIControlStateSelected];
        [_chooseButton wxm_addTarget:self action:@selector(wxm_touchEvent)];
        [_chooseButton wxm_setEnlargeEdgeWithTop:3 left:15 right:3 bottom:15];
    }
    return _chooseButton;
}

@end
