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
@property (nonatomic, strong) UIView *maskCoverView;

/** 图片 */
@property (nonatomic, strong) UIImageView *imageView;

/** 资源类型标记 GIF Video */
@property (nonatomic, strong) UIButton *typeSign;

/** 勾选框  */
@property (nonatomic, strong) UIButton *chooseButton;

/** 当前cell的下载的ID 复用的时候使用 */
@property (nonatomic, assign) int32_t currentRequestID;

/** 唯一标识 */
@property (nonatomic, copy) NSString *assetIdentifier;

@end

@implementation WXMPhotoCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) [self initializationInterface];
    return self;
}

- (void)initializationInterface {
    self.userCanTouch = YES;
    self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    [self.contentView addSubview:self.imageView];
    [self.contentView addSubview:self.typeSign];
    [self.contentView addSubview:self.chooseButton];
    [self.contentView addSubview:self.maskCoverView];
}

/** 是否显示选择框 */
- (void)setDisplayCheckBox:(BOOL)displayCheckBox {
    _displayCheckBox = displayCheckBox;
    self.chooseButton.hidden = (!displayCheckBox);
    self.chooseButton.enabled = displayCheckBox;
}

/** 设置显示界面效果 */
- (void)setShowVideo:(BOOL)showVideo {
    _showVideo = showVideo;
    
    self.typeSign.hidden = YES;
    [self.contentView bringSubviewToFront:self.typeSign];

    /** 视频 */
    if (_photoAsset.mediaType == WXMPHAssetMediaTypeVideo &&
        WXMPhotoShowVideoSign &&
        WXMPhotoSupportVideo) {
        self.typeSign.hidden = (!showVideo);
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

/** 是否可以点击 */
- (void)setUserCanTouch:(BOOL)userCanTouch animation:(BOOL)animation {
    _userCanTouch = userCanTouch;
    CGFloat duration = animation ? 0.2 : 0;
    [UIView animateWithDuration:duration animations:^{
        self.maskCoverView.alpha = !userCanTouch;
        self.userInteractionEnabled = userCanTouch;
    }];
}

/** 选中记录的model */
- (void)setRecordModel:(WXMPhotoRecordModel *)recordModel {
    _recordModel = recordModel;
    if (recordModel) {
        
        NSInteger rank = recordModel.recordRank;
        self.chooseButton.selected = YES;
        [self.chooseButton setTitle:@(rank).stringValue forState:UIControlStateSelected];
        
    } else {
        self.chooseButton.selected = NO;
        [self.chooseButton setTitle:@"" forState:UIControlStateSelected];
    }
}

/** 设置排名 */
- (void)refreshRanking:(WXMPhotoRecordModel *)recordModel animation:(BOOL)animation {
    if (recordModel != nil) {
        NSInteger rank = recordModel.recordRank;
        self.chooseButton.selected = YES;
        [self.chooseButton setTitle:@(rank).stringValue forState:UIControlStateSelected];
        if (animation) [self setAnimation];
    } else {
        self.chooseButton.selected = NO;
        [self.chooseButton setTitle:@"" forState:UIControlStateSelected];
    }
}

/** 异步赋值 数量特别多异步获取 */
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wimplicit-retain-self"
 
- (void)setPhotoAsset:(WXMPhotoAsset *)photoAsset {
    _imageView.image = nil;
    _photoAsset = photoAsset;
    
    /** NSLog(@"%@",photoAsset.asset.localIdentifier); */
    _assetIdentifier = _photoAsset.asset.localIdentifier;
        
    /** PHImageRequestOptionsResizeModeExact返回精确大小 */
    /** PHImageRequestOptionsResizeModeExact想返回缩略图在返回需要大小 */
    int32_t ids = [[WXMPhotoManager sharedInstance]
                   getPicturesByAsset:photoAsset.asset
                   synchronous:NO
                   original:NO
                   assetSize:CGSizeMake(WXMItemWidth, WXMItemWidth)
                   resizeMode:PHImageRequestOptionsResizeModeFast
                   deliveryMode:PHImageRequestOptionsDeliveryModeOpportunistic
                   completion:^(UIImage *image) {
        
        if ([_assetIdentifier isEqualToString:_photoAsset.asset.localIdentifier]) {
            
            @autoreleasepool {
                self.imageView.image = image.wp_redraw;
            }
            
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

/** 勾号点击 */
- (void)wp_touchEvent:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(wp_photoCollectionCellCheckBox:selected:)]) {
        [self.delegate wp_photoCollectionCellCheckBox:self selected:sender.selected];
    }
}

/** 设置动画 */
- (void)setAnimation {
    if (!self.chooseButton.selected) return;
    self.userInteractionEnabled = NO;
    self.chooseButton.transform = CGAffineTransformMakeScale(0.3, 0.3);
    [UIView animateWithDuration:1.f delay:0 usingSpringWithDamping:0.4 initialSpringVelocity:0.0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        self.chooseButton.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.userInteractionEnabled = YES;
    }];
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
        [_chooseButton wp_addTarget:self action:@selector(wp_touchEvent:)];
        [_chooseButton wp_setEnlargeEdgeWithTop:3 left:15 right:3 bottom:15];
    }
    return _chooseButton;
}

- (void)dealloc {
    self.imageView.image = nil;
}

- (UIImage *)redraw:(UIImage *)image {
    CGFloat width = CGImageGetWidth(image.CGImage);
    CGFloat height = CGImageGetHeight(image.CGImage);

    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    
    // 绘制图片大小设置
    [image drawInRect:CGRectMake(0, 0, width, height)];
    
    // 从当前context中创建一个图片
    UIImage* images = UIGraphicsGetImageFromCurrentImageContext();
    
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    // 返回新的改变大小后的图片
    return images;
}
@end

