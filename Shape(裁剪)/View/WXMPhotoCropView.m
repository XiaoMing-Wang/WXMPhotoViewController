//
//  WXMPhotoCropView.m
//  ModuleDebugging
//
//  Created by wq on 2019/5/18.
//  Copyright © 2019年 wq. All rights reserved.
//
#define WXM_Ctr(A,T,B) (( (T >= A) && (T <= B)))
#define WXM_Left 20
#define WXM_Outside 30
#define WXM_Inside 5
#define WXM_MINXY 100

#import "WXMPhotoConfiguration.h"
#import "WXMPhotoCropView.h"
#import "WXMPhotoOverlayView.h"
#import "WXMPhotoShapeScrollView.h"
#import "WXMPhotoAssistant.h"
#import "UIView+WXMPhoto.h"

@interface WXMPhotoCropView () <UIScrollViewDelegate>
/** 手势判断用 */
@property(nonatomic, strong) UIView *touchView;
@property(nonatomic, strong) UIView *unTouchView;
@property(nonatomic, assign) CGRect wxm_oldGridFrame;

/** 主view */
@property (nonatomic, strong) UIImageView *mainImageView;
@property (nonatomic, strong) WXMPhotoShapeScrollView *scrollView;
@property (nonatomic, assign) WXMPhotoCropType cropType;

/** imageView */
@property (nonatomic, assign) CGFloat image_y;
@property (nonatomic, assign) CGFloat imageScale;

/** scrollview */
@property (nonatomic, assign) CGFloat scrollTop;
@property (nonatomic, assign) CGFloat scrollOffset;
@property (nonatomic, assign) CGFloat scrollWH;

/** 动画 */
@property (nonatomic, assign) CGFloat beginTop;
@property (nonatomic, assign) CGFloat beginLeft;
@property (nonatomic, assign) CGFloat beginRight;
@property (nonatomic, assign) CGFloat beginBottom;
@property (nonatomic, assign) CGFloat beginCenterX;
@property (nonatomic, assign) CGFloat beginCenterY;
@property (nonatomic, assign) CGFloat beginWidth;
@property (nonatomic, assign) CGFloat beginHeight;
@end
@implementation WXMPhotoCropView

/** 初始化 */
- (instancetype)initWithImage:(UIImage *)image {
    if (self = [super initWithFrame:CGRectZero]) {
        self.image = image;
        [self setupInterface];
    }
    return self;
}
- (void)setupInterface {
    /** __weak typeof(self) weakSelf = self; */
    CGFloat screenScale = (WXMPhoto_Height / WXMPhoto_Width);
    
    /** 缩小的宽高 */
    /** scrollView的宽高 */
    CGFloat scrollWH = (WXMPhoto_Width - WXM_Left * 2);
    self.scrollWH = scrollWH;

    /** scrollWH宽度时屏幕应该有的高度 */
    CGFloat screenSmallH = scrollWH * screenScale;
    
    /** scrollView的Y值 */
    /** 这里的值是缩小的scrollView应该位于缩小的屏幕中间 还向上 20px */
    self.scrollTop = (screenSmallH - scrollWH) / 2 - 20;
    
    self.frame = CGRectMake(0, 0, WXMPhoto_Width, WXMPhoto_Height);
    self.backgroundColor = [UIColor blackColor];
    
    CGRect rect = CGRectMake(WXM_Left, self.scrollTop, scrollWH, scrollWH);
    self.scrollView = [[WXMPhotoShapeScrollView alloc] initWithFrame:rect];
    self.scrollView.alwaysBounceHorizontal = YES;
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.clipsToBounds = NO;
    self.scrollView.delegate = self;
    [self.scrollView setMinimumZoomScale:1.0];
    [self.scrollView setMaximumZoomScale:4.0f];
    [self addSubview:self.scrollView];
    
    /** 图片比例 */
    self.imageScale = self.image.size.height / self.image.size.width;
    CGFloat image_x = 0;
    CGFloat image_y = 0;
    CGFloat image_w = scrollWH;
    CGFloat image_h = scrollWH * self.imageScale;
    if (image_h < image_w) image_y = ABS(image_w - image_h) / 2;  /** 图片宽大于高 */
    self.image_y = image_y;
    
    /** 图片大小等于屏幕大小时 微信有缩小和滚动动画 */
    if (self.image.size.width==WXMPhoto_Width *2 && self.image.size.height==WXMPhoto_Height *2) {
        image_x = 10;
        image_w = (WXMPhoto_Width - 60);
        image_h = image_w * self.imageScale;
        self.scrollOffset = 20;
    }
    
    CGRect imageFrame = CGRectMake(image_x, image_y, image_w, image_h);
    self.mainImageView = [[UIImageView alloc] initWithFrame:imageFrame];
    self.mainImageView.image = self.image;
    
    /** 画面最开始的状态出于中心位置 即将开始做动画 */
    CGFloat offy = MAX((image_h - self.scrollView.frame.size.height), 0) / 2;
    [self.scrollView setContentOffset:CGPointMake(0, offy - _scrollOffset)];
    [self.scrollView addSubview:self.mainImageView];
    
    /** 网格view */
    _gridOverlayView = [[WXMPhotoOverlayView alloc] initWithFrame:self.mainImageView.bounds];
    _gridOverlayView.center = CGPointMake(_scrollView.center.x, _scrollView.center.y+_scrollOffset);
    _gridOverlayView.userInteractionEnabled = NO;
    
    /** 添加触摸和隔离手势的view */
    [self addSubview:_gridOverlayView];
    [self addSubview:self.touchView];
    [self addSubview:self.unTouchView];
    [self gridOverlayViewSmaller]; /** 开始做动画 */
    
//    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
//    [self addGestureRecognizer:recognizer];
//    recognizer.maximumNumberOfTouches = 1;

}

/** 刚进界面时网格动画 */
- (void)gridOverlayViewSmaller {
    
    [UIView animateWithDuration:0.45 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGFloat width = self.scrollView.frame.size.width;
        CGFloat height = self.scrollView.frame.size.width * self.imageScale;
        self.gridOverlayView.frame = CGRectMake(0, 0, width, width);
        self.gridOverlayView.center = self.scrollView.center;
        
        /** 宽度大于高度 横向滑动 */
        if (self.image_y > 0) {
            CGFloat nesWidth = width / self.imageScale * 1.0;
            self.mainImageView.frame = CGRectMake(0, 0,nesWidth, width);
            [self scrollerViewRollCenter:nesWidth];
            
        /** 高度大于宽度 纵向滑动 */
        } else {
            self.mainImageView.frame = CGRectMake(0, 0, width, height);
            [self scrollerViewRollCenter:height];
        }
    } completion:^(BOOL finished) { [self synchronousSize]; }];
}

/** 滚到中心 */
- (void)scrollerViewRollCenter:(CGFloat)off {
    if (self.image_y > 0)  { //横向中心
        self.scrollView.contentSize = CGSizeMake(off,self.scrollView.contentSize.height);
        CGFloat loction = MAX((off - self.scrollView.frame.size.width), 0) / 2;
        [self.scrollView setContentOffset:CGPointMake(loction, 0)];
    } else {//纵向中心
        self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width,off);
        CGFloat loction = MAX((off - self.scrollView.frame.size.height), 0) / 2;
        [self.scrollView setContentOffset:CGPointMake(0, loction)];
    }
}
/** 这里是把响应手势和过滤手势覆盖的view和网格框大小同步 */
- (void)synchronousSize {
    CGFloat width = _gridOverlayView.width;
    CGFloat height = _gridOverlayView.height;
    _scrollView.size = CGSizeMake(width, height);
    _touchView.size = CGSizeMake((width + WXM_Outside * 2), (height + WXM_Outside * 2));
    _unTouchView.size = CGSizeMake((width - WXM_Inside * 2), (height - WXM_Inside * 2));
    
    _unTouchView.center = _gridOverlayView.center;
    _touchView.center = _gridOverlayView.center;
    _scrollView.center = _gridOverlayView.center;
    _scrollView.contentSize = CGSizeMake(self.mainImageView.width, self.mainImageView.height);
    if (CGRectEqualToRect(CGRectZero, self.wxm_oldGridFrame)) {
        self.wxm_oldGridFrame = _gridOverlayView.frame;
    }
}
/** 缩放view */
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.mainImageView;
}
/** 判断需要响应的view */
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    UIView *hitTestView = [super hitTest:point withEvent:event];
//    if ((point.y < self.touchView.y - 5) || (point.y > self.touchView.bottom + 5) ||
//        (point.x < self.touchView.x - 5) || (point.x > self.touchView.right + 5) ) {
//        return self.scrollView;
//    }
//    if (hitTestView == self.touchView) return self;
//    if (hitTestView == self.scrollView) return self.scrollView;
//    if (hitTestView == self.unTouchView) return self.scrollView;
//    if (hitTestView == self && (point.y < self.touchView.frame.origin.y || point.y > self.touchView.frame.origin.y + self.touchView.frame.size.height)) {
//        return self.scrollView;
//    } else return self;
    return self.scrollView;
    return nil;
}

/** */
//- (void)resetConfiguration {
//    [WXMPhotoAssistant setHeight:self.scrollWH impView:self.gridOverlayView];
//    [WXMPhotoAssistant setWidth:self.scrollWH impView:self.gridOverlayView];
//    [WXMPhotoAssistant setY:self.scrollTop impView:self.gridOverlayView];
//    [WXMPhotoAssistant setCenterX:WXMPhoto_Width / 2 impView:self.gridOverlayView];
//    [self synchronousSize];
//}

//- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
//
//    if (recognizer.state == UIGestureRecognizerStateChanged) {
//        CGPoint translation = [recognizer translationInView:self];
//        CGFloat tranY = translation.y;
//        CGFloat tranX = translation.x;
//        CGFloat old_x = _wxm_oldGridFrame.origin.x;
//        CGFloat old_right = _wxm_oldGridFrame.origin.x + _wxm_oldGridFrame.size.width;
//        CGFloat old_y = _wxm_oldGridFrame.origin.y;
//    /** CGFloat old_w = _wxm_oldGridFrame.size.width; */
//        CGFloat old_h = _wxm_oldGridFrame.size.height;
//        CGFloat gridBottom = _gridOverlayView.frame.origin.y + _gridOverlayView.frame.size.height;
//        CGFloat gridRight= _gridOverlayView.frame.origin.x + _gridOverlayView.frame.size.width;
//        CGFloat square = (tranX + tranY) / 2;
//        CGFloat squareAff = (tranX - tranY) / 2;
//
//        if (self.cropType == WXMPhotoCropTypeBottom) {
//            if (tranY > 0 &&  gridBottom >= (old_y + old_h))  return;
//            CGFloat height = MAX(self.beginHeight + tranY, WXM_MINXY);
//            self.gridOverlayView.size = CGSizeMake(height, height);
//            self.gridOverlayView.y = self.beginTop;
//            self.gridOverlayView.centerX = self.beginCenterX;
//            [self synchronousSize];
//            self.scrollView.contentOffsetX = (_mainImageView.width - _gridOverlayView.width)/ 2;
//        }
//
//        else if (self.cropType == WXMPhotoCropTypeTop) {
//            if (tranY < 0 && _gridOverlayView.frame.origin.y <= old_y) return;
//
//            CGFloat height = MAX(self.beginHeight - tranY, WXM_MINXY);
//            self.gridOverlayView.size = CGSizeMake(height, height);
//            self.gridOverlayView.bottom = self.beginBottom;
//            self.gridOverlayView.centerX = self.beginCenterX;
//            [self synchronousSize];
//
//
//
//        }
//
//        else if (self.cropType == WXMPhotoCropTypeLeft) {
//            if (tranX < 0 && _gridOverlayView.frame.origin.x <= old_x) return;
//
//            CGFloat width = MAX(self.beginWidth - tranX, WXM_MINXY);
//            self.gridOverlayView.size = CGSizeMake(width, width);
//            self.gridOverlayView.right = self.beginRight;
//            self.gridOverlayView.centerY = self.beginCenterY;
//            [self synchronousSize];
//            //self.scrollView.contentOffsetX = -(_wxm_oldGridFrame.size.width - _gridOverlayView.width) / 2;
//        }
//
//        else if (self.cropType == WXMPhotoCropTypeRight) {
//            if (tranX > 0 && gridRight >= old_right) return;
//
//            CGFloat width = MAX(self.beginWidth + tranX, WXM_MINXY);
//            [WXMPhotoAssistant setHeight:width impView:self.gridOverlayView];
//            [WXMPhotoAssistant setWidth:width impView:self.gridOverlayView];
//            [WXMPhotoAssistant setX:self.beginLeft impView:self.gridOverlayView];
//            [WXMPhotoAssistant setCenterY:self.beginCenterY impView:self.gridOverlayView];
//            [self synchronousSize];
//        }
//
//        else if (self.cropType == WXMPhotoCropTypeRight_Bottom) {
//            if (tranX > 0 && gridRight >= old_right) return;
//            if (tranY > 0 && gridBottom >= old_h + old_y) return;
//
//            CGFloat width = MAX(self.beginWidth + square, WXM_MINXY);
//            [WXMPhotoAssistant setHeight:width impView:self.gridOverlayView];
//            [WXMPhotoAssistant setWidth:width impView:self.gridOverlayView];
//            [WXMPhotoAssistant setX:self.beginLeft impView:self.gridOverlayView];
//            [WXMPhotoAssistant setY:self.beginTop impView:self.gridOverlayView];
//            [self synchronousSize];
//        }
//
//        else if (self.cropType == WXMPhotoCropTypeRight_Top) {
//            if (tranX > 0 && gridRight >= old_right) return;
//            if (tranY < 0 && _gridOverlayView.frame.origin.y <= old_y) return;
//
//            CGFloat width = MAX(self.beginWidth + squareAff, WXM_MINXY);
//            [WXMPhotoAssistant setHeight:width impView:self.gridOverlayView];
//            [WXMPhotoAssistant setWidth:width impView:self.gridOverlayView];
//            [WXMPhotoAssistant setX:self.beginLeft impView:self.gridOverlayView];
//            [WXMPhotoAssistant setBottom:self.beginBottom impView:self.gridOverlayView];
//            [self synchronousSize];
//        }
//
//        else if (self.cropType == WXMPhotoCropTypeLeft_Bottom) {
//            if (tranX < 0 && _gridOverlayView.frame.origin.x >= old_x) return;
//            if (tranY > 0 && gridBottom >= old_h + old_y) return;
//
//            CGFloat width = MAX(self.beginWidth - squareAff, WXM_MINXY);
//            [WXMPhotoAssistant setHeight:width impView:self.gridOverlayView];
//            [WXMPhotoAssistant setWidth:width impView:self.gridOverlayView];
//            [WXMPhotoAssistant setY:self.beginTop impView:self.gridOverlayView];
//            [WXMPhotoAssistant setRight:self.beginRight impView:self.gridOverlayView];
//            [self synchronousSize];
//        }
//
//        else if (self.cropType == WXMPhotoCropTypeLeft_Top) {
//            if (tranX < 0 && _gridOverlayView.frame.origin.x >= old_x) return;
//            if (tranY < 0 && _gridOverlayView.frame.origin.y <= old_y) return;
//
//            CGFloat width = MAX(self.beginWidth - square, WXM_MINXY);
//            [WXMPhotoAssistant setHeight:width impView:self.gridOverlayView];
//            [WXMPhotoAssistant setWidth:width impView:self.gridOverlayView];
//            [WXMPhotoAssistant setBottom:self.beginBottom impView:self.gridOverlayView];
//            [WXMPhotoAssistant setRight:self.beginRight impView:self.gridOverlayView];
//            [self synchronousSize];
//        }
//
//    }
//
//
//    if (recognizer.state == UIGestureRecognizerStateBegan) {
//        NSString * string = @"";
//        self.cropType = WXMPhotoCropTypeNo;
//        self.beginTop = self.gridOverlayView.frame.origin.y;
//        self.beginLeft = self.gridOverlayView.frame.origin.x;
//        self.beginCenterX = self.gridOverlayView.center.x;
//        self.beginCenterY = self.gridOverlayView.center.y;
//        self.beginWidth = self.gridOverlayView.frame.size.width;
//        self.beginHeight = self.gridOverlayView.frame.size.height;
//        self.beginBottom = self.beginTop + self.beginHeight;
//        self.beginRight = self.beginLeft + self.beginWidth;
//
//        /** 判断触点在哪 */
//        CGPoint lotion = [recognizer locationInView:self.touchView];
//        CGFloat greenEdge_left = WXM_Left;
//        CGFloat greenEdge_top = WXM_Outside;
//
//        /** 触摸界面中宽度 */
//        CGFloat grid_Width = self.touchView.frame.size.width;
//        CGFloat grid_Height = self.touchView.frame.size.height;
//        CGFloat grid_piece = self.beginWidth / 6.0; /** 半块网格的宽度 */
//
//        /** !!!!!!触摸宽度 !!!!!!!*/
//        CGFloat touch_Width = greenEdge_left + grid_piece;
//        CGFloat touch_Height = greenEdge_top + grid_piece;
//
//        /** 左边 */
//        if (WXM_Ctr(0, lotion.x, touch_Width) &&
//            WXM_Ctr(0, lotion.y, touch_Height)) {
//            NSLog(@"左上角");
//            string = @"左上角";
//            self.cropType = WXMPhotoCropTypeLeft_Top;
//
//        } else if (WXM_Ctr(0, lotion.x, touch_Width) &&
//                   WXM_Ctr(grid_Height - touch_Height, lotion.y, grid_Height)) {
//            NSLog(@"左下方");
//            string = @"左下方";
//            self.cropType = WXMPhotoCropTypeLeft_Bottom;
//
//        } else if (WXM_Ctr(0, lotion.x, touch_Width) &&
//                   WXM_Ctr(0, lotion.y, grid_Height)) {
//            NSLog(@"正左方");
//            string = @"正左方";
//            self.cropType = WXMPhotoCropTypeLeft;
//
//        }
//
//        /** 右边 */
//        else if (WXM_Ctr(grid_Width - touch_Width, lotion.x, grid_Width) &&
//                   WXM_Ctr(0, lotion.y, touch_Height)) {
//            NSLog(@"右上角");
//            string = @"右上角";
//            self.cropType = WXMPhotoCropTypeRight_Top;
//
//        } else if (WXM_Ctr(grid_Width - touch_Width, lotion.x, grid_Width) &&
//                   WXM_Ctr(grid_Height - touch_Height, lotion.y, grid_Height)) {
//            NSLog(@"右下角");
//            string = @"右下角";
//            self.cropType = WXMPhotoCropTypeRight_Bottom;
//
//        } else if (WXM_Ctr(grid_Width - touch_Width, lotion.x, grid_Width) &&
//                   WXM_Ctr(0, lotion.y, grid_Height)) {
//            NSLog(@"正右方");
//            string = @"正右方";
//            self.cropType = WXMPhotoCropTypeRight;
//        }
//
//        /** 上下方 */
//        else if (WXM_Ctr(0, lotion.x, grid_Width) &&
//                 WXM_Ctr(0, lotion.y, touch_Height)) {
//            NSLog(@"正上方");
//            string = @"正上方";
//            self.cropType = WXMPhotoCropTypeTop;
//
//        } else if (WXM_Ctr(0, lotion.x, grid_Width) &&
//                   WXM_Ctr(grid_Height - touch_Height, lotion.y, grid_Height)) {
//            NSLog(@"正下方");
//            string = @"正下方";
//            self.cropType = WXMPhotoCropTypeBottom;
//        }
//
//    }
//}
//

///** 响应的view */
//- (UIView *)touchView {
//    if (!_touchView)  {
//        _touchView = [[UIView alloc] init];
//        _touchView.frame = CGRectMake(0, 0, WXMPhoto_Width, WXMPhoto_Width - 40 + WXM_Outside * 2);
//    /** _touchView.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.5]; */
//        _touchView.center = _gridOverlayView.center;
//        _touchView.tag = 100;
//    }
//    return _touchView;
//}
///** 不可响应的view */
//- (UIView *)unTouchView {
//    if (!_unTouchView) {
//        _unTouchView = [[UIView alloc] init];
//        _unTouchView.frame=CGRectMake(0,0,WXMPhoto_Width-40-WXM_Inside,WXMPhoto_Width-40-WXM_Inside);
//    /** _unTouchView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5]; */
//        _unTouchView.center = _gridOverlayView.center;
//    }
//    return _unTouchView;
//}
@end

