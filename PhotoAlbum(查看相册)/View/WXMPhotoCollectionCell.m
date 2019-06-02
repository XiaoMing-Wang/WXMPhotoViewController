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
@property(nonatomic, strong) UIView *photoMaskView;

/** 图片 */
@property(nonatomic, strong) UIImageView *imageView;

/** 资源类型标记 */
@property(nonatomic, strong) UIButton *typeSign;

/** 勾选框 */
@property(nonatomic, strong) WXMPhotoSignView *sign;
@end

@implementation WXMPhotoCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) [self setupInterface];
    return self;
}

- (void)setupInterface {
    _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = YES;
    [self.contentView addSubview:_imageView];
}

/** 设置相册类型 */
- (void)setPhotoType:(WXMPhotoDetailType)photoType {
    _photoType = photoType;
    
    if (photoType == WXMPhotoDetailTypeMultiSelect && !_photoMaskView && !_sign) {
        _photoMaskView = [[UIView alloc] initWithFrame:self.bounds];
        _photoMaskView.hidden = YES;
        _photoMaskView.userInteractionEnabled = NO;
        _photoMaskView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.65];
        _sign = [[WXMPhotoSignView alloc] initWithSupViewSize:_imageView.frame.size];
        [self.contentView addSubview:_photoMaskView];
        [self.contentView addSubview:_sign];
    }
}

/** 异步赋值 数量特别多异步获取 */
- (void)setPhotoAsset:(WXMPhotoAsset *)photoAsset {
    @autoreleasepool {
        _photoAsset = photoAsset;
        [self wxm_setTypeSignInterface];
        
        if (photoAsset.smallImage) _imageView.image = photoAsset.smallImage;
        if (!photoAsset.smallImage) {
            PHAsset *asset = photoAsset.asset;
            CGSize size = CGSizeMake(WXMItemWidth, WXMItemWidth);
            WXMPhotoManager *man = [WXMPhotoManager sharedInstance];
            [man getPictures_customSize:asset synchronous:NO assetSize:size completion:^(UIImage *image) {
                _photoAsset.aspectRatio = image.size.height / image.size.width * 1.0;
                self.imageView.image = image;
                photoAsset.smallImage = image;
            }];
        }
    }
}

/** 多选模式下设置代理 */
- (void)setDelegate:(id<WXMPhotoSignProtocol>)delegate
          indexPath:(NSIndexPath *)indexPath
          signModel:(WXMPhotoSignModel *)signModel
            respond:(BOOL)respond {
    _sign.signModel = signModel;
    _sign.delegate = delegate;
    _sign.indexPath = indexPath;
    
    /** 白色蒙版 */
    if (respond == NO) {
        _photoMaskView.hidden = (signModel != nil);
        _sign.userInteraction = _photoMaskView.hidden;
    } else {
        _photoMaskView.hidden = YES;
        _sign.userInteraction = YES;
    }
    _canRespond = _photoMaskView.hidden;
}

/** 设置显示界面效果 */
- (void)wxm_setTypeSignInterface {
    if (_photoAsset.mediaType == WXMPHAssetMediaTypeVideo && WXMPhotoShowVideoSign) {
        [self.contentView addSubview:self.typeSign];
        NSLog(@"%zd",_photoAsset.asset.duration);
        NSString * duration = [NSString stringWithFormat:@"  %zd",_photoAsset.asset.duration];
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
@end
