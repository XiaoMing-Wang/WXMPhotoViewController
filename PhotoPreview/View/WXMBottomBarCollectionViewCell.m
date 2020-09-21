//
//  WXMBottomBarCollectionViewCell.m
//  2222222
//
//  Created by wq on 2020/3/15.
//  Copyright © 2020 wxm. All rights reserved.
//

#import "WXMPhotoConfiguration.h"
#import "WXMBottomBarCollectionViewCell.h"

@interface WXMBottomBarCollectionViewCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *videoSymbol;

/** 当前cell的下载的ID 复用的时候使用 */
@property (nonatomic, assign) int32_t currentRequestID;

/** 唯一标识 */
@property (nonatomic, copy) NSString *assetIdentifier;

@end

@implementation WXMBottomBarCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) [self initializationInterface];
    return self;
}

- (void)initializationInterface {
    self.imageView = [[UIImageView alloc] init];
    self.imageView.clipsToBounds = YES;
    self.imageView.size = CGSizeMake(WXMPhotoPreviewImageWH, WXMPhotoPreviewImageWH);
    self.imageView.layer.borderWidth = 1.5;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.layer.borderColor = [UIColor clearColor].CGColor;
    
    self.videoSymbol = [[UIImageView alloc] init];
    self.videoSymbol.size = CGSizeMake(20, 20);
    self.videoSymbol.image = [UIImage imageNamed:@"phoro_play"];
    self.videoSymbol.centerX = self.contentView.width / 2;
    self.videoSymbol.centerY = self.contentView.height / 2;
    self.videoSymbol.hidden = YES;
      
    [self.contentView addSubview:self.imageView];
    [self.contentView addSubview:self.videoSymbol];
}

- (void)setRecordModel:(WXMPhotoRecordModel *)recordModel {
    _recordModel = recordModel;
    _assetIdentifier = recordModel.recordAsset.asset.localIdentifier;
    _videoSymbol.hidden = (recordModel.mediaType != WXMPHAssetMediaTypeVideo);
    
    CGFloat wh = self.imageView.width * 2.0;
    [[WXMPhotoManager sharedInstance] getPicturesCustomSize:recordModel.recordAsset.asset synchronous:NO assetSize:CGSizeMake(wh, wh) completion:^(UIImage *image) {
        if ([self.assetIdentifier isEqualToString:recordModel.recordAsset.asset.localIdentifier]) {
            self.imageView.image = image;
        }
    }];
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    UIColor *color = isSelected ? WXMSelectedColor : [UIColor clearColor];
    [self.imageView.layer setBorderWidth:1.5];
    [self.imageView.layer setBorderColor:color.CGColor];
}

@end
