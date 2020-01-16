//
//  WXMPhotoNavigationbar.m
//  Multi-project-coordination
//
//  Created by wq on 2020/1/16.
//  Copyright © 2020 wxm. All rights reserved.
//
#import "UIView+WXMPhoto.h"
#import "WXMPhotoNavigationbar.h"

@interface WXMPhotoNavigationbar ()
@property (nonatomic, strong) UILabel *titleLabels;
@property (nonatomic, strong) UIImageView *arrowView;
@end

@implementation WXMPhotoNavigationbar

/** 初始化 */
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) [self setupInterface];
    return self;
}

- (void)setupInterface {
    self.titleLabels = [[UILabel alloc] init];
    self.titleLabels.font = [UIFont boldSystemFontOfSize:17];
    self.titleLabels.textColor = [UIColor blackColor];
    
    self.frame = CGRectMake(0, 0, 200, 44);
    [self addSubview:self.titleLabels];
}

- (void)setTitles:(NSString *)titles {
    _titles = titles;
    self.titleLabels.text = titles;
    [self.titleLabels sizeToFit];
    self.titleLabels.centerX = self.width / 2 - 10;
    self.titleLabels.centerY = self.height / 2;
}

@end
