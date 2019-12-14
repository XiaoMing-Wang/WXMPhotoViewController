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
    self.userCanTouch = YES;
    self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    
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
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wimplicit-retain-self"
 
- (void)setPhotoAsset:(WXMPhotoAsset *)photoAsset {
    _photoAsset = photoAsset;
    _assetIdentifier = _photoAsset.asset.localIdentifier;
    CGSize size = CGSizeMake(WXMItemWidth, WXMItemWidth);
    
    /** 设置界面 */
    [self wxm_setTypeSignInterface];
    
    /** PHImageRequestOptionsResizeModeExact返回精确大小 */
    /** PHImageRequestOptionsResizeModeExact想返回缩略图在返回需要大小 */
    int32_t ids = [[WXMPhotoManager sharedInstance]
                   getPicturesByAsset:photoAsset.asset
                   synchronous:NO
                   original:NO
                   assetSize:size
                   resizeMode:PHImageRequestOptionsResizeModeExact
                   deliveryMode:PHImageRequestOptionsDeliveryModeOpportunistic
                   completion:^(UIImage *image) {
        
        if ([_assetIdentifier isEqualToString:_photoAsset.asset.localIdentifier]) {
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
#pragma clang diagnostic pop


/** 多选模式下设置代理 */
- (void)setDelegate:(id<WXMPhotoSignProtocol>)delegate
          indexPath:(NSIndexPath *)indexPath
          signModel:(WXMPhotoSignModel *)signModel
          available:(BOOL)available {
    
    _delegate = delegate;
    _indexPath = indexPath;
    _signModel = signModel;
    BOOL selected = (signModel != nil);
    if (selected) available = YES;
    
    [self signButtonSelected:selected];
    [self wxm_setTypeSignInterface];
    [self setUserCanTouch:available animation:NO];
}

/** 设置能否响应 */
- (void)setUserCanTouch:(BOOL)userCanTouch animation:(BOOL)animation {
    _userCanTouch = userCanTouch;
    
    /** 用户能否点击 */
    CGFloat duration = animation ? 0.2 : 0;
    [UIView animateWithDuration:duration animations:^{
        self.maskCoverView.alpha = (!userCanTouch);
    }];
}

/** 设置显示界面效果 */
- (void)wxm_setTypeSignInterface {
    self.typeSign.hidden = YES;
    [self.contentView bringSubviewToFront:self.typeSign];
    
    /** 视频 */
    if (_photoAsset.mediaType == WXMPHAssetMediaTypeVideo &&
        WXMPhotoShowVideoSign &&
        WXMPhotoSupportVideo) {
        if (self.showVideo)  self.typeSign.hidden = NO;
        NSString *duration = [NSString stringWithFormat:@"  %@", _photoAsset.videoDrantion];
        [self.typeSign setTitle:duration forState:UIControlStateNormal];
        
        UIImage *image = [UIImage imageNamed:@"photo_videoSmall"];
        [self.typeSign setImage:image forState:UIControlStateNormal];
        self.typeSign.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        self.typeSign.titleLabel.font = [UIFont systemFontOfSize:11];
        
    /** GIF */
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
    self.chooseButton.selected = selected;
    UIControlState sele = UIControlStateSelected;
    if (selected) {
        [self.chooseButton setTitle:@(_signModel.rank).stringValue forState:sele];
    } else {
        [self.chooseButton setTitle:@"" forState:UIControlStateNormal];
        [self.chooseButton setTitle:@"" forState:sele];
    }
}

/** 勾号点击 */
- (void)wxm_touchEvent {
    if (self.userCanTouch == NO) {
        [self wxm_showAlertController];
        return;
    }
    
    self.chooseButton.selected = !_chooseButton.selected;
    [self.chooseButton setTitle:@"" forState:UIControlStateNormal];
    [self.chooseButton setTitle:@"" forState:UIControlStateSelected];
    [self setAnimation];
    
    /** 设置第几个选中 */
    if ([self.delegate respondsToSelector:@selector(touchWXMPhotoSignView:selected:)]) {
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
    if ([self.delegate respondsToSelector:@selector(wxm_cantTouchWXMPhotoSignView:)]){
        [self.delegate wxm_cantTouchWXMPhotoSignView:self.photoAsset.mediaType];
    }
}

/** 刷新标号排名 */
- (void)refreshRankingWithSignModel:(WXMPhotoSignModel *)signModel {
    _signModel = signModel;
    _chooseButton.selected = YES;
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
        _typeSign.hidden = YES;
        [_typeSign setTitle:@"" forState:UIControlStateNormal];
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
        UIImage *normal = [UIImage imageNamed:@"photo_sign_default"];
        UIImage *selected = [UIImage imageNamed:@"photo_sign_background"];
        
        CGFloat wh = WXMSelectedWH;
        _chooseButton = [[UIButton alloc] init];
        _chooseButton = [[UIButton alloc] initWithFrame:CGRectMake(0,3,wh,wh)];
        _chooseButton.right = self.contentView.width - 3;
        _chooseButton.titleLabel.font = [UIFont systemFontOfSize:WXMSelectedFont];
        [_chooseButton setBackgroundImage:normal forState:UIControlStateNormal];
        [_chooseButton setBackgroundImage:selected forState:UIControlStateSelected];
        [_chooseButton wxm_addTarget:self action:@selector(wxm_touchEvent)];
        [_chooseButton wxm_setEnlargeEdgeWithTop:3 left:15 right:3 bottom:15];
    }
    return _chooseButton;
}

- (void)dealloc {
    self.imageView.image = nil;
}

@end

