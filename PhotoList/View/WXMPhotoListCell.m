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
    CGFloat wh = WXMPhotoListCellH * 0.65;
    CGFloat left = wh + 30;
    self.posterImageView = [[UIImageView alloc] init];
    self.posterImageView.frame = CGRectMake(15, (WXMPhotoListCellH - wh) / 2.0, wh, wh);
    self.posterImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.posterImageView.clipsToBounds = YES;
    
    self.titleLable = [[UILabel alloc] init];
    self.titleLable.frame = CGRectMake(left, 0, self.frame.size.width - 125, WXMPhotoListCellH);
    self.titleLable.font = [UIFont systemFontOfSize:15];
    self.titleLable.textColor = [UIColor blackColor];
    self.titleLable.textAlignment = NSTextAlignmentLeft;
    
    [self.contentView addSubview:self.posterImageView];
    [self.contentView addSubview:self.titleLable];
}

/** 相册界面相片少同步获取 */
- (void)setPhoneList:(WXMPhotoList *)phoneList {
    _phoneList = phoneList;
    
    CGFloat wh = self.posterImageView.width * 2.0;
    NSString *infoHelp = [NSString stringWithFormat:@"  (%zd)", _phoneList.photoNum];
    NSString *info = [_phoneList.title stringByAppendingString:infoHelp];
    self.titleLable.text = info;
    [[WXMPhotoManager sharedInstance] getPicturesCustomSize:self.phoneList.firstAsset synchronous:NO assetSize:CGSizeMake(wh, wh) completion:^(UIImage *image) {
        self.posterImageView.image = image;
    }];
}
@end

