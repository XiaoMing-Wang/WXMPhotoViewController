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

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    [self setupInterface];
    return self;
}

/** 初始化 */
- (void)setupInterface {
    self.posterImageView = [[UIImageView alloc] init];
    self.posterImageView.frame = CGRectMake(15, 15, 70, 70);
    self.posterImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.posterImageView.clipsToBounds = YES;
    
    self.titleLable = [[UILabel alloc] init];
    self.titleLable.frame = CGRectMake(105, 0, self.frame.size.width - 105 - 20, 100);
    self.titleLable.font = [UIFont systemFontOfSize:16];
    self.titleLable.textColor = [UIColor lightGrayColor];
    self.titleLable.textAlignment = NSTextAlignmentLeft;
    
    [self.contentView addSubview:_posterImageView];
    [self.contentView addSubview:_titleLable];
}

/** 赋值 相册界面相片少同步获取 */
- (void)setPhoneList:(WXMPhotoList *)phoneList {
    _phoneList = phoneList;
    
    NSRange range = NSMakeRange(0, _phoneList.title.length);
    NSString *infoHelp = [NSString stringWithFormat:@"  (%zd)", _phoneList.photoNum];
    NSString *info = [_phoneList.title stringByAppendingString:infoHelp];
    NSMutableAttributedString *atts = [[NSMutableAttributedString alloc] initWithString:info];
    [atts addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:range];
    self.titleLable.attributedText = atts;
    
    __weak __typeof(self) self_weak = self;
    [[WXMPhotoManager sharedInstance] getPictures_customSize:self.phoneList.firstAsset
                                                 synchronous:NO
                                                   assetSize:CGSizeMake(140, 140)
                                                  completion:^(UIImage *image) {
        self_weak.posterImageView.image = image;
    }];
}
@end

