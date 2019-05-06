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
@implementation WXMPhotoCollectionCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        CGFloat w = self.frame.size.width;
        CGFloat h = self.frame.size.height;
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;

//        _seleIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 2, 20, 20)];
//        _seleIcon.right = self.width - 2;
//        _seleIcon.hidden = YES;
//        _seleIcon.image = [UIImage imageNamed:@"sign"];
        [self.contentView addSubview:_imageView];
        [self.contentView addSubview:_seleIcon];
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
        [manager getImageByAsset_Asynchronous:asset size:size completion:^(UIImage *AssetImage) {
            self.imageView.image = AssetImage;
            photoAsset.smallImage = AssetImage;
        }];
    }
}
@end
