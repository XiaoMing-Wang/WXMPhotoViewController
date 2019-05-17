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
@property (nonatomic, strong) UIView *increaseView;
@property (nonatomic, strong) UILabel *numberLabel;
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
    [self addSubview:_leftButton];
    
    CGFloat x = WXMPhoto_Width - 74;
    CGFloat wh = 21;
    UIButton * rightButton = [[UIButton alloc] initWithFrame:CGRectMake(x, status, 74, 44)];
    [rightButton addTarget:self action:@selector(rightItem) forControlEvents:UIControlEventTouchUpInside];
    _increaseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, wh, wh)];
    _increaseView.center = CGPointMake(rightButton.frame.size.width/2+16,rightButton.frame.size.height/2);
    _increaseView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0];
    _increaseView.layer.cornerRadius = _increaseView.frame.size.width / 2;
    _increaseView.layer.borderWidth = 1;
    _increaseView.layer.borderColor = [UIColor whiteColor].CGColor;
    _increaseView.userInteractionEnabled = NO;
    
    _numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, wh, wh)];
    _numberLabel.textAlignment = NSTextAlignmentCenter;
    _numberLabel.font = [UIFont systemFontOfSize:15];
    _numberLabel.textColor = [UIColor whiteColor];
    _numberLabel.hidden = YES;
    _numberLabel.userInteractionEnabled = NO;
    [_increaseView addSubview:_numberLabel];
    
    [rightButton addSubview:_increaseView];
    [self addSubview:rightButton];
    /** [_leftButton addTarget:self action:@selector(buttonClick:)
     * forControlEvents:UIControlEventTouchUpInside]; */
}
/** 设置左按钮是否显示 */
- (void)setShowLeft:(BOOL)showLeft {
    _showLeft = showLeft;
    _leftButton.hidden = !showLeft;
}
- (void)setSignModel:(WXMPhotoSignModel *)signModel {
    _signModel = signModel;
    if (signModel == nil) {
        _numberLabel.hidden = YES;
        _increaseView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0];
        _increaseView.layer.borderColor = [UIColor whiteColor].CGColor;
    } else {
        _numberLabel.hidden = NO;
        _numberLabel.text = @(signModel.rank).stringValue;
        _increaseView.backgroundColor = [WXMSelectedColor colorWithAlphaComponent:0.6];
        _increaseView.layer.borderColor = [UIColor clearColor].CGColor;
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
