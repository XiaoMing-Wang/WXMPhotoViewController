//
//  WXMPhotoListCell.m
//  ModuleDebugging
//
//  Created by edz on 2019/5/5.
//  Copyright © 2019年 wq. All rights reserved.
//
#import "WXMPhotoListCell.h"

@interface WXMPhotoListCell ()
@property (strong, nonatomic) UIImageView *posterImageView;
@property (strong, nonatomic) UILabel *titleLable;
@end

@implementation WXMPhotoListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    [self setupInterface];
    return self;
}

/** 初始化 */
- (void)setupInterface {
    _posterImageView = [[UIImageView alloc] init];
    _posterImageView.contentMode = UIViewContentModeScaleAspectFill;
    _posterImageView.clipsToBounds = YES;
    _posterImageView.frame = CGRectMake(15, 15, 70, 70);
    
    _titleLable = [[UILabel alloc] init];
    _titleLable.font = [UIFont systemFontOfSize:16];
    _titleLable.frame = CGRectMake(105, 0, self.frame.size.width - 105 - 20, 100);
    _titleLable.textColor = [UIColor lightGrayColor];
    _titleLable.textAlignment = NSTextAlignmentLeft;
    
    [self.contentView addSubview:_posterImageView];
    [self.contentView addSubview:_titleLable];
}

/** 赋值 相册界面相片少同步获取 */
- (void)setPhoneList:(WXMPhotoList *)phoneList {
    _phoneList = phoneList;
    @autoreleasepool {
        NSRange range = NSMakeRange(0, _phoneList.title.length);
        NSString *infoHelp = [NSString stringWithFormat:@"  (%zd)", _phoneList.photoNum];
        NSString *info = [_phoneList.title stringByAppendingString:infoHelp];
        NSMutableAttributedString *atts = [[NSMutableAttributedString alloc] initWithString:info];
        [atts addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:range];
        self.titleLable.attributedText = atts;
        
        if (phoneList.firstImage) self.posterImageView.image = phoneList.firstImage;
        if (phoneList.firstImage == nil) {
            CGFloat w = ([UIScreen mainScreen].bounds.size.width > 400) ? 210 : 140;
            CGSize size = CGSizeMake(w, w);
            PHAsset *asset = self.phoneList.firstAsset;
            WXMPhotoManager *man = [WXMPhotoManager sharedInstance];
            [man wxm_synchronousGetPictures:asset size:size completion:^(UIImage *image) {
                self.posterImageView.image = image;
                phoneList.firstImage = image;
            }];
        }
    }
}
@end

