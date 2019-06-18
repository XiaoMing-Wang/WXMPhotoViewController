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
    [self.contentView addSubview:self.typeSign];
}

/** 设置相册类型 */
- (void)setPhotoType:(WXMPhotoDetailType)photoType {
    _photoType = photoType;
    if (photoType == WXMPhotoDetailTypeMultiSelect) {
        [self.contentView addSubview:self.maskCoverView];
        [self.contentView addSubview:self.chooseButton];
    }  else if (photoType == WXMPhotoDetailTypeTailoring) {
        self.typeSign.alpha = WXMPhotoTailoringShowGIFSign;
    }
}

/** 异步赋值 数量特别多异步获取 */
- (void)setPhotoAsset:(WXMPhotoAsset *)photoAsset {
    _photoAsset = photoAsset;
    self.representedAssetIdentifier = _photoAsset.asset.localIdentifier;
    [self wxm_setTypeSignInterface];
    CGSize size = CGSizeMake(WXMItemWidth, WXMItemWidth);
        
    /** PHImageRequestOptionsResizeModeExact返回精确大小 */
    /** PHImageRequestOptionsResizeModeExact想返回缩略图在返回需要大小 */
    int32_t ids = [[WXMPhotoManager sharedInstance] getPicturesByAsset:photoAsset.asset synchronous:NO original:NO assetSize:size resizeMode:PHImageRequestOptionsResizeModeExact deliveryMode:PHImageRequestOptionsDeliveryModeOpportunistic completion:^(UIImage *image) {
        if ([self.representedAssetIdentifier isEqualToString:_photoAsset.asset.localIdentifier]) {
            self.imageView.image = image;
        } else {
            [[WXMPhotoManager sharedInstance] cancelRequestWithID:_currentRequestID];
        }
    }];

    if (ids && _currentRequestID && ids != _currentRequestID) {
        [[WXMPhotoManager sharedInstance] cancelRequestWithID:_currentRequestID];
    }
    _currentRequestID = ids;
    _photoAsset.requestID = ids;
    [self setNeedsLayout];
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
           canTouch:(BOOL)canTouch {
    
    _delegate = delegate;
    _indexPath = indexPath;
    _signModel = signModel;
    [self signButtonSelected:(signModel != nil)];
    [self wxm_setTypeSignInterface];
    
    if (signModel != nil) canTouch = YES;
    [self setUserCanTouch:canTouch animation:NO];
}

/** 设置显示界面效果 */
- (void)wxm_setTypeSignInterface {
    self.typeSign.hidden = YES;
    [self.contentView bringSubviewToFront:self.typeSign];
    
    if (_photoAsset.mediaType == WXMPHAssetMediaTypeVideo &&
        WXMPhotoShowVideoSign &&
        WXMPhotoSupportVideo) {
        if (self.showVideo)  self.typeSign.hidden = NO;
        NSString * duration = [NSString stringWithFormat:@"  %@",_photoAsset.videoDrantion];
        [self.typeSign setTitle:duration forState:UIControlStateNormal];
        
        UIImage *image = [UIImage imageNamed:@"photo_videoSmall"];
        [self.typeSign setImage:image forState:UIControlStateNormal];
        self.typeSign.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        self.typeSign.titleLabel.font = [UIFont systemFontOfSize:11];
        
    } else if (_photoAsset.mediaType == WXMPHAssetMediaTypePhotoGif && WXMPhotoShowGIFSign) {
        
        self.typeSign.hidden = NO;
        self.typeSign.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        [self.typeSign setTitle:@"  GIF" forState:UIControlStateNormal];
        [self.typeSign setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        self.typeSign.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    }
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
    if (self.delegate&&[self.delegate respondsToSelector:@selector(touchWXMPhotoSignView:selected:)]) {
        BOOL selected = _chooseButton.selected;
        NSInteger count = [self.delegate touchWXMPhotoSignView:_indexPath selected:selected];
        if (count >= 0 && count < WXMMultiSelectMax) {
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
    if (self.delegate && [self.delegate respondsToSelector:@selector(wxm_cantTouchWXMPhotoSignView)]){
        [self.delegate wxm_cantTouchWXMPhotoSignView];
    }
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
        [_typeSign setTitle:@"" forState:UIControlStateNormal];
        _typeSign.hidden = YES;
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

