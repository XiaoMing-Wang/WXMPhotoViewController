//
//  WXMPhotoTransitions.m
//  ModuleDebugging
//
//  Created by wq on 2019/5/16.
//  Copyright © 2019年 wq. All rights reserved.
//
#import "WXMPhotoTransitions.h"
#import "WXMPhotoPreviewController.h"
#import "WXMPhotoDetailViewController.h"
#import "WXMPhotoConfiguration.h"
#import <objc/runtime.h>
#import "WXMPhotoImageView.h"
#import "WXMPhotoCollectionCell.h"

@interface WXMPhotoTransitions ()
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, strong) UIView *mask;
@property (nonatomic, strong) UIView *maskContent;
@end
@implementation WXMPhotoTransitions

+ (instancetype)photoTransitionsWithType:(WXMPhotoTransitionsType)type {
    WXMPhotoTransitions *transitions = [WXMPhotoTransitions new];
    transitions.transitionsType = type;
    return transitions;
}
- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext{
    return .35;
}
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    if (self.transitionsType == WXMPhotoTransitionsTypePush) {
        [self pushWithTransitionContext:transitionContext];
    } else if (self.transitionsType == WXMPhotoTransitionsTypePop) {
        [self popWithTransitionContext:transitionContext];
    }
}

/** push */
- (void)pushWithTransitionContext:(id <UIViewControllerContextTransitioning>)transitionContext {}

/** pop 界面层级比较复杂 所以直接从界面获取元素做动画了... */
- (void)popWithTransitionContext:(id <UIViewControllerContextTransitioning>)transitionContext {
    id <UIViewControllerContextTransitioning> tc = transitionContext;
    WXMPhotoDetailViewController *toVC = [tc viewControllerForKey:UITransitionContextToViewControllerKey];
    WXMPhotoPreviewController *fromVC = [tc viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *toView = toVC.view;
    UIView *fromView = fromVC.view;
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    
    @autoreleasepool {
        
        UIScrollView *scr = fromVC.transitionScrollerView;
        NSInteger row = fromVC.transitionIndex;
        UICollectionView *collectionView = toVC.transitionCollectionView;
        if (collectionView) {
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            WXMPhotoCollectionCell *cell = nil;
            cell = (WXMPhotoCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
            CGRect aRect = [cell convertRect:cell.bounds toView:window];
            
            /** from */
            UIImageView *mainImageView = [self mainImageView:scr];
            UIImageView *blackView = objc_getAssociatedObject(scr, @"black");
            CGFloat scale = mainImageView.height / mainImageView.width;
            [mainImageView removeFromSuperview];
            
            /** wrap */
            CGRect rect = CGRectMake(0, 0, scr.width, scr.width * scale);
            WXMPhotoImageView *wrapImageView = [[WXMPhotoImageView alloc] initWithFrame:rect];
            wrapImageView.center = scr.center;
            wrapImageView.image = mainImageView.image;
            wrapImageView.contentMode = UIViewContentModeScaleAspectFill;
            wrapImageView.clipsToBounds = YES;
            
            /** 白色遮罩 */
            UIView *maskCoverView = nil;
            if (!cell.userCanTouch) {
                maskCoverView = [[UIView alloc] initWithFrame:wrapImageView.bounds];
                maskCoverView.alpha = 0;
                maskCoverView.userInteractionEnabled = NO;
                maskCoverView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.65];
                [wrapImageView addSubview:maskCoverView];
            }
            
            /** 缩放 */
            [self setMaskview:wrapImageView.frame mRect:aRect];
            wrapImageView.maskView = self.mask;
            
            
            [[transitionContext containerView] insertSubview:toView belowSubview:fromView];
            [[transitionContext containerView] addSubview:wrapImageView];
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                if (CGRectEqualToRect(aRect, CGRectZero))  wrapImageView.alpha = 0;
                if (!CGRectEqualToRect(aRect, CGRectZero)) {
                    wrapImageView.frame = aRect;
                    self.mask.frame = CGRectMake(0, 0, aRect.size.width, aRect.size.height);
                    CGRect rect = self.maskContent.frame;
                    rect.origin.y = aRect.size.height * self.scale;
                    rect.size.width = aRect.size.width;
                    rect.size.height = aRect.size.height;
                    self.maskContent.frame = rect;
                }
                blackView.alpha = 0;
                if (!cell.userCanTouch) maskCoverView.alpha = 1;
                
            } completion:^(BOOL finished) {
                [wrapImageView removeFromSuperview];
                [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
            }];
        }
    }
}

- (UIImageView *)mainImageView:(UIScrollView *)scrollView {
    __block UIImageView * imageView = nil;
    [scrollView.subviews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL * stop) {
        if ([obj isKindOfClass:[UIImageView class]]) {
            imageView = (UIImageView *)obj;
            *stop = YES;
        }
    }];
    return imageView;
}

- (void)setMaskview:(CGRect)aRect mRect:(CGRect)mRect {
    if (mRect.origin.y >= WXMPhoto_BarHeight) return;
    CGFloat mHeight = WXMPhoto_BarHeight - mRect.origin.y;
    self.scale = mHeight / mRect.size.height;
    self.mask = [[UIView alloc] initWithFrame:CGRectMake(0, 0, aRect.size.width, aRect.size.height)];
    self.maskContent = [[UIView alloc] initWithFrame:self.mask.bounds];
    self.maskContent.backgroundColor = [UIColor blackColor];
    [self.mask addSubview:self.maskContent];
}

@end
