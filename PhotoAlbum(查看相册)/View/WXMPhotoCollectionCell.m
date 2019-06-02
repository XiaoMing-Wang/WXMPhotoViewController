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
@property (nonatomic, strong) UIView *photoMaskView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) WXMPhotoSignView *sign;
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
        if (photoAsset.smallImage) _imageView.image = photoAsset.smallImage;
        if (!photoAsset.smallImage) {
            PHAsset *asset = photoAsset.asset;
            CGSize size = CGSizeMake(WXMItemWidth, WXMItemWidth);
            WXMPhotoManager *manager = [WXMPhotoManager sharedInstance];
            [manager getPictures_customSize:asset synchronous:NO assetSize:size completion:^(UIImage *image) {
                /**  NSLog(@"%f-%f",image.size.width,image.size.height); */
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
@end
