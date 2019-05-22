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
    return 0.35;
}
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    if (self.transitionsType == WXMPhotoTransitionsTypePush) {
        [self pushWithTransitionContext:transitionContext];
    } else if (self.transitionsType == WXMPhotoTransitionsTypePop) {
        [self popWithTransitionContext:transitionContext];
    }
}

/** push */
- (void)pushWithTransitionContext:(id <UIViewControllerContextTransitioning>)transitionContext {
    
}

/** pop */
- (void)popWithTransitionContext:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    WXMPhotoDetailViewController *toViewController = [transitionContext
        viewControllerForKey:UITransitionContextToViewControllerKey];
    WXMPhotoPreviewController *fromViewController = [transitionContext
        viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *toView = toViewController.view;
    UIView *fromView = fromViewController.view;
    
    @autoreleasepool {
        UIScrollView *scr = fromViewController.transitionScrollerView;
        NSInteger row = fromViewController.transitionIndex;
        UICollectionView *collectionView = toViewController.transitionCollectionView;
        if (collectionView) {
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
            UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
            CGRect aRect = [cell convertRect:cell.bounds toView:window];
            
            /** from */
            UIImageView *mainImageView = [self mainImageView:scr];
            UIImageView *blackView = objc_getAssociatedObject(scr, @"black");
            CGFloat scale = mainImageView.frame.size.height / mainImageView.frame.size.width;
            [mainImageView removeFromSuperview];
            
            /** wrap */
            CGRect rect = CGRectMake(0, 0, scr.frame.size.width, scr.frame.size.width * scale);
            WXMPhotoImageView *wrapImageView = [[WXMPhotoImageView alloc] initWithFrame:rect];
            wrapImageView.center = scr.center;
            wrapImageView.image = mainImageView.image;
            wrapImageView.contentMode = UIViewContentModeScaleAspectFill;
            wrapImageView.clipsToBounds = YES;
            
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
            } completion:^(BOOL finished) {
                [wrapImageView removeFromSuperview];
                [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
            }];
        }
    }
}
- (UIImageView *)mainImageView:(UIScrollView *)scrollView {
    __block UIImageView * imageView = nil;
    [scrollView.subviews enumerateObjectsUsingBlock:^(UIView *  obj, NSUInteger idx, BOOL * stop) {
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
