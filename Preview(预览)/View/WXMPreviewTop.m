//
//  WXMPhotoPreviewTopView.m
//  ModuleDebugging
//
//  Created by edz on 2019/5/13.
//  Copyright © 2019年 wq. All rights reserved.
//
#import "WXMPhotoConfiguration.h"
#import "WXMPreviewTop.h"
@interface WXMPreviewTop ()
@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, strong) UIButton *rightSubItem;

//@property (nonatomic, strong) UIImageView *increaseView;
//@property (nonatomic, strong) UILabel *numberLabel;
@end
@implementation WXMPreviewTop

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) [self setupInterface];
    return self;
}
/** 初始化界面 */
- (void)setupInterface {
    self.userInteractionEnabled = YES;
    self.frame = CGRectMake(0, 0, WXMPhoto_Width, WXMPhoto_BarHeight);
    self.backgroundColor = WXMPhoto_RGBColor(33, 33, 33);
    CGFloat status = WXMPhoto_BarHeight - 44;
    
    _leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, status, 65, 44)];
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 0, 26, 26)];
    imageView.center = CGPointMake(imageView.center.x, _leftButton.frame.size.height / 2);
    imageView.image = [UIImage imageNamed:@"live_icon_back"];
    imageView.userInteractionEnabled = NO;
    [_leftButton addSubview:imageView];
    [_leftButton addTarget:self action:@selector(leftItem) forControlEvents:UIControlEventTouchUpInside];
   
    CGFloat x = WXMPhoto_Width - 74;
    CGFloat itemWH = 28;
    CGFloat subX = 74 - itemWH - 12;
    
    _rightButton = [[UIButton alloc] initWithFrame:CGRectMake(x, status, 74, _leftButton.frame.size.height)];
    [_rightButton addTarget:self action:@selector(rightItem) forControlEvents:UIControlEventTouchUpInside];
    _rightSubItem = [[UIButton alloc] initWithFrame:CGRectMake(subX, 0, itemWH, itemWH)];
    _rightSubItem.userInteractionEnabled = NO;
    _rightSubItem.titleLabel.font = [UIFont systemFontOfSize:WXMSelectedFont];
    
    UIImage *normal = [UIImage imageNamed:@"photo_sign_default"];
    UIImage *selected = [UIImage imageNamed:@"photo_sign_background"];
    [_rightSubItem setBackgroundImage:normal forState:UIControlStateNormal];
    [_rightSubItem setBackgroundImage:selected forState:UIControlStateSelected];
    _rightSubItem.center = CGPointMake(_rightSubItem.center.x,_rightButton.frame.size.height / 2);
    [_rightButton addSubview:_rightSubItem];
    
    [self addSubview:_leftButton];
    [self addSubview:_rightButton];
}

/** 设置左按钮是否显示 */
- (void)setShowLeft:(BOOL)showLeft {
    _showLeft = showLeft;
    _leftButton.hidden = !showLeft;
}

- (void)setSignModel:(WXMPhotoSignModel *)signModel {
    _signModel = signModel;
    if (signModel == nil) {
        self.rightSubItem.selected = NO;
        [self.rightSubItem setTitle:@"" forState:UIControlStateSelected];
    } else {
        self.rightSubItem.selected = YES;
        [self.rightSubItem setTitle:@(signModel.rank).stringValue forState:UIControlStateSelected];
    }
}

/** 左按钮 */
- (void)leftItem {
    if (self.delegate && [self.delegate respondsToSelector:@selector(wxm_touchTopLeftItem)]) {
        [self.delegate wxm_touchTopLeftItem];
    }
}

/** 右按钮 */
- (void)rightItem {
    if (self.delegate && [self.delegate respondsToSelector:@selector(wxm_touchTopRightItem:)]) {
        [self.delegate wxm_touchTopRightItem:self.signModel];
    }
}

/** 显示隐藏 */
- (void)setAccordingState:(BOOL)state {
    if (state) self.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = state;
    }];
}

@end
