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
@property(nonatomic, strong) UIView *obstructionsView;

/** 图片 */
@property(nonatomic, strong) UIImageView *imageView;

/** 资源类型标记 */
@property(nonatomic, strong) UIButton *typeSign;

/** 勾选框 */
@property(nonatomic, strong) WXMPhotoSignView *sign;

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
        [self.contentView addSubview:self.obstructionsView];
        [self.contentView addSubview:self.sign];
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
- (void)setUserCanTouch:(BOOL)userCanTouch {
    _userCanTouch = userCanTouch;
    
    /** 用户能否点击 */
    _obstructionsView.hidden = userCanTouch;
    _sign.userContinueExpansion = userCanTouch;
}


/** 多选模式下设置代理 */
- (void)setDelegate:(id<WXMPhotoSignProtocol>)delegate
          indexPath:(NSIndexPath *)indexPath
          signModel:(WXMPhotoSignModel *)signModel
           showMask:(BOOL)showMask {
    
    _indexPath = indexPath;
    _sign.signModel = signModel;
    _sign.delegate = delegate;
    _sign.indexPath = indexPath;
    if (showMask == NO) {
        self.userCanTouch = YES;
    } else {
        self.userCanTouch = (signModel != nil);
    }
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

- (UIView *)obstructionsView {
    if (!_obstructionsView) {
        _obstructionsView = [[UIView alloc] initWithFrame:self.bounds];
        _obstructionsView.hidden = YES;
        _obstructionsView.userInteractionEnabled = NO;
        _obstructionsView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.65];
        _sign = [[WXMPhotoSignView alloc] initWithSupViewSize:_imageView.frame.size];
    }
    return _obstructionsView;
}

@end
