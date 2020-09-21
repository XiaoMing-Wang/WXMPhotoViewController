//
//  WXMPhotoDetailTitleBar.m
//  2222222
//
//  Created by wq on 2020/2/9.
//  Copyright © 2020 wxm. All rights reserved.
//

#import "WXMPhotoDetailTitleBar.h"

@interface WXMPhotoDetailTitleBar ()
@property (nonatomic, strong) UILabel *titleLabels;
@property (nonatomic, strong) UIImageView *arrowView;
@end

@implementation WXMPhotoDetailTitleBar

- (instancetype)init {
    self = [super init];
    if (self) [self initializeInterface];
    return self;
}

- (void)initializeInterface {
    self.titleLabels = [[UILabel alloc] init];
    self.titleLabels.font = [UIFont systemFontOfSize:17];
    self.titleLabels.textColor = [UIColor blackColor];
    self.arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.arrowView.image = [UIImage imageNamed:@"photo_arrow"];
    
    [self layoutAllSubviews];
    [self addSubview:self.titleLabels];
    [self addSubview:self.arrowView];
    [self addTarget:self action:@selector(eventTouch) forControlEvents:UIControlEventTouchUpInside];
}

- (void)eventTouch {
    self.unfold = !self.unfold;
    if (self.unfold) self.arrowView.transform = CGAffineTransformMakeRotation(M_PI);
    if (!self.unfold) self.arrowView.transform = CGAffineTransformIdentity;
        
    if ([self.delegate respondsToSelector:@selector(wp_touchTitleBarWithUnfold:)]) {
        [self.delegate wp_touchTitleBarWithUnfold:self.unfold];
    }
    
    self.userInteractionEnabled = NO;
    dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.28 * NSEC_PER_SEC));
    dispatch_after(when, dispatch_get_main_queue(), ^{
        self.userInteractionEnabled = YES;
    });
}

- (void)reductionArrowView {
    self.unfold = NO;
    self.arrowView.transform = CGAffineTransformIdentity;
}

- (void)layoutAllSubviews {
    self.titleLabels.text = self.title;
    [self.titleLabels sizeToFit];
    self.titleLabels.center = CGPointMake(self.titleLabels.center.x, 40 / 2.0);
    
    CGFloat aX = self.titleLabels.frame.size.width;
    self.arrowView.frame = CGRectMake(aX + 2.5, 0, 18, 16);
    self.arrowView.center = CGPointMake(self.arrowView.center.x, 40 / 2.0);
    self.frame = CGRectMake(0, 0, aX + 25, 40);
}

- (void)setTitle:(NSString *)title {
    _title = title;
    [self reductionArrowView];
    [self layoutAllSubviews];
}

@end
