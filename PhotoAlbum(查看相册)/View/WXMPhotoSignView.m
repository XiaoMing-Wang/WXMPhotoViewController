//
//  WXMPhotoSign.m
//  ModuleDebugging
//
//  Created by edz on 2019/5/12.
//  Copyright © 2019年 wq. All rights reserved.
//
#import "WXMPhotoConfiguration.h"
#import "WXMPhotoSignView.h"

@interface WXMPhotoSignView ()
@property (nonatomic, assign) CGSize supSize;
@property (nonatomic, strong) UIButton *contentView;
@end
@implementation WXMPhotoSignView

- (instancetype)initWithSupViewSize:(CGSize)size {
    if (self = [super initWithFrame:CGRectZero]) {
        self.supSize = size;
        self.userContinueExpansion = YES;
        [self setupInterface];
    }
    return self;
}

/** 初始化界面 */
- (void)setupInterface {
    CGFloat supWH = self.supSize.width;
    CGFloat wh = WXMSelectedWH;
    CGFloat x = (supWH * 0.5) - wh - 2.5;
    CGFloat y = 2.5;
    self.frame = CGRectMake(supWH * 0.5, 0, supWH * 0.5, supWH * 0.4);
    [self wxm_addTarget:self action:@selector(wxm_touchEvent)];
    
    UIImage *normal = [UIImage imageNamed:@"photo_sign_default"];
    UIImage *selected = [UIImage imageNamed:@"photo_sign_background"];
    _contentView = [[UIButton alloc] initWithFrame:CGRectMake(x, y, wh, wh)];
    _contentView.userInteractionEnabled = NO;
    _contentView.titleLabel.font = [UIFont systemFontOfSize:WXMSelectedFont];
    [_contentView setBackgroundImage:normal forState:UIControlStateNormal];
    [_contentView setBackgroundImage:selected forState:UIControlStateSelected];
    [self addSubview:_contentView];
}

/** 点击 */
- (void)wxm_touchEvent {
    if (self.userContinueExpansion == NO) {
        [self wxm_showAlertController];
        return;
    }
    
    self.selected = !self.selected;
    [self setProperties];
    [self setAnimation];
    
    /** 设置第几个选中 */
    if (self.delegate && [self.delegate respondsToSelector:@selector(touchWXMPhotoSignView:selected:)]) {
        NSInteger count = [self.delegate touchWXMPhotoSignView:_indexPath selected:self.selected];
        if (count >= 0 && count < WXMMultiSelectMax)  {
            [self.contentView setTitle:@(count + 1).stringValue forState:UIControlStateSelected];
        }
    }
}

/** 设置属性 */
- (void)setProperties {
    self.contentView.selected = self.selected;
    [self.contentView setTitle:@"" forState:UIControlStateNormal];
    [self.contentView setTitle:@"" forState:UIControlStateSelected];
}

/** 设置动画 */
- (void)setAnimation {
    if (!self.selected) return;
    self.contentView.transform = CGAffineTransformMakeScale(0.3, 0.3);
    [UIView animateWithDuration:1.f delay:0 usingSpringWithDamping:0.4 initialSpringVelocity:0.0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        self.contentView.transform = CGAffineTransformIdentity;
    } completion:nil];
}

/** 赋值 */
- (void)setSignModel:(WXMPhotoSignModel *)signModel {
    self.selected = (signModel != nil);
    [self setProperties];
    [self.contentView setTitle:@(signModel.rank).stringValue forState:UIControlStateSelected];
}

/** 提示框 */
- (void)wxm_showAlertController {
    NSString *title = [NSString stringWithFormat:@"您最多可以选择%d张图片",WXMMultiSelectMax];
    [WXMPhotoAssistant showAlertViewControllerWithTitle:title message:@"" cancel:@"知道了"
                                            otherAction:nil completeBlock:nil];
}
@end
