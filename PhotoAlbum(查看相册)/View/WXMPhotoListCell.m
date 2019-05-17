//
//  WXMPhotoListCell.m
//  ModuleDebugging
//
//  Created by edz on 2019/5/5.
//  Copyright © 2019年 wq. All rights reserved.
//
#define iW (([UIScreen mainScreen].bounds.size.width - 7.5) / 4) * 2
#import "WXMPhotoListCell.h"

@implementation WXMPhotoListCell
- (void)setPhoneList:(WXMPhotoList *)phoneList {
    _phoneList = phoneList;
    NSRange range = NSMakeRange(0, _phoneList.title.length);
    
    NSString *infoHelp = [NSString stringWithFormat:@"  (%zd)", _phoneList.photoNum];
    NSString *info = [_phoneList.title stringByAppendingString:infoHelp];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:info];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:range];
    self.titleLable.attributedText = attributedString;
    
    if (phoneList.firstImage) self.posterImageView.image = phoneList.firstImage;
    if (phoneList.firstImage == nil) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            CGFloat w = ([UIScreen mainScreen].bounds.size.width > 400) ? 210 : 140;
            CGSize size = CGSizeMake(w, w);
            PHAsset *asset = self.phoneList.firstAsset;
            WXMPhotoManager *manager = [WXMPhotoManager sharedInstance];
            [manager getImageByAsset_Synchronous:asset size:size completion:^(UIImage *AssetImage) {
                self.posterImageView.image = AssetImage;
                phoneList.firstImage = AssetImage;
            }];
        });
    }
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    [self __init];
    return self;
}
- (void)__init {
    _posterImageView = [[UIImageView alloc] init];
    _posterImageView.contentMode = UIViewContentModeScaleAspectFill;
    _posterImageView.clipsToBounds = YES;
    _posterImageView.frame = CGRectMake(15, 15, 70, 70);
    [self.contentView addSubview:_posterImageView];
    
    _titleLable = [[UILabel alloc] init];
    _titleLable.font = [UIFont systemFontOfSize:16];
    _titleLable.frame = CGRectMake(105, 0, self.frame.size.width - 105 - 20, 100);
    _titleLable.textColor = [UIColor lightGrayColor];
    _titleLable.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_titleLable];
}

@end

/** 单个相册CollectionViewCell*/
@interface WXMPhotoCollectionCell ()
@property (nonatomic, strong) UIView *photoMaskView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) WXMPhotoSignView *sign;
@end
@implementation WXMPhotoCollectionCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        CGFloat w = self.frame.size.width;
        CGFloat h = self.frame.size.height;
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self.contentView addSubview:_imageView];
    }
    return self;
}
- (void)setPhotoAsset:(WXMPhotoAsset *)photoAsset {
    _photoAsset = photoAsset;
    if (photoAsset.smallImage) _imageView.image = photoAsset.smallImage;
    if (!photoAsset.smallImage) {
        PHAsset *asset = photoAsset.asset;
        CGSize size = CGSizeMake(iW, iW);
        WXMPhotoManager *manager = [WXMPhotoManager sharedInstance];
        [manager getImageByAsset_Asynchronous:asset size:size completion:^(UIImage *assetImage) {
            self.imageView.image = assetImage;
            photoAsset.smallImage = assetImage;
        }];
    }
}
- (void)setPhotoType:(WXMPhotoDetailType)photoType {
    _photoType = photoType;
    if (photoType == WXMPhotoDetailTypeMultiSelect && !_photoMaskView && !_sign) {
        CGFloat w = self.frame.size.width;
        CGFloat h = self.frame.size.height;
        _photoMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
        _photoMaskView.userInteractionEnabled = NO;
        _photoMaskView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.65];
        _sign = [[WXMPhotoSignView alloc] initWithSupViewSize:_imageView.frame.size];
        [self.contentView addSubview:_photoMaskView];
        [self.contentView addSubview:_sign];
        _photoMaskView.hidden = YES;
    }
}
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
