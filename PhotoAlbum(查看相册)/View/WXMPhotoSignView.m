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
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *numberLabel;
@end
@implementation WXMPhotoSignView

/**  */
- (instancetype)initWithSupViewSize:(CGSize)size {
    if (self = [super initWithFrame:CGRectZero]) {
        self.supSize = size;
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
    [self addTarget:self action:@selector(touchEvent) forControlEvents:UIControlEventTouchUpInside];

    _contentView = [[UIView alloc] initWithFrame:CGRectMake(x, y, wh, wh)];
    _contentView.layer.cornerRadius = wh / 2;
    _contentView.layer.borderWidth = 1;
    _contentView.layer.borderColor = [UIColor whiteColor].CGColor;
    _contentView.userInteractionEnabled = NO;
    
    _numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, wh, wh)];
    _numberLabel.textAlignment = NSTextAlignmentCenter;
    _numberLabel.text = @"1";
    _numberLabel.font = [UIFont systemFontOfSize:15];
    _numberLabel.textColor = [UIColor whiteColor];
    _numberLabel.hidden = YES;
    _numberLabel.userInteractionEnabled = NO;
    [_contentView addSubview:_numberLabel];
    
    [self addSubview:_contentView];
}

/** 点击 */
- (void)touchEvent {
    if (self.userInteraction == NO) {
        [self showAlertController];
        return;
    }
    
    self.selected = !self.selected;
    [self setProperties];
    if (self.delegate && [self.delegate respondsToSelector:@selector(touchWXMPhotoSignView:selected:)]) {
        NSInteger count = [self.delegate touchWXMPhotoSignView:self.indexPath selected:self.selected];
        if (count >= 0 && count < WXMMultiSelectMax) self.numberLabel.text = @(count+1).stringValue;
    }
    [self setAnimation];
}

/** 设置属性 */
- (void)setProperties {
    self.numberLabel.text = @"";
    self.contentView.backgroundColor = self.selected ? WXMSelectedColor : [UIColor clearColor];
    self.contentView.layer.borderColor = (self.selected ?[UIColor clearColor]:[UIColor whiteColor]).CGColor;
    self.numberLabel.hidden = !self.selected;
}
/** 设置动画 */
- (void)setAnimation {
    if (self.numberLabel.hidden) return;
    self.contentView.transform = CGAffineTransformMakeScale(0.3, 0.3);
    [UIView animateWithDuration:1.f delay:0 usingSpringWithDamping:0.4 initialSpringVelocity:0.0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        self.contentView.transform = CGAffineTransformIdentity;
    } completion:nil];
}
/**  */
- (void)setSignModel:(WXMPhotoSignModel *)signModel {
    self.selected = (signModel != nil);
    [self setProperties];
    self.numberLabel.text = @(signModel.rank).stringValue;
}
/** 提示框 */
- (void)showAlertController {
    NSString *title = [NSString stringWithFormat:@"您最多可以选择%d张图片",WXMMultiSelectMax];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:@""
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *c = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:c];
    UIWindow * window = [[[UIApplication sharedApplication] delegate] window];
    UIViewController * vc = window.rootViewController;
    if (window.rootViewController.presentedViewController)  {
        vc = window.rootViewController.presentedViewController;
    }
    [vc presentViewController:alert animated:YES completion:nil];
}
@end
