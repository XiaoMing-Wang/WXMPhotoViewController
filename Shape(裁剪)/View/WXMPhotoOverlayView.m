//
//  WXMPhotoOverlayView.m
//  ModuleDebugging
//
//  Created by wq on 2019/5/18.
//  Copyright © 2019年 wq. All rights reserved.
//

#import "WXMPhotoOverlayView.h"

static const CGFloat WXMPhoto_CornerWidth = 20.0f;
@interface WXMPhotoOverlayView ()
/** 横竖线 */
@property(nonatomic, strong) NSArray *horizontalGridLines;
@property(nonatomic, strong) NSArray *verticalGridLines;

/** 四条外线 */
@property(nonatomic, strong) NSArray *outerLineViews;

/** 四个边角 */
@property(nonatomic, strong) NSArray *topLeftLineViews;
@property(nonatomic, strong) NSArray *bottomLeftLineViews;
@property(nonatomic, strong) NSArray *bottomRightLineViews;
@property(nonatomic, strong) NSArray *topRightLineViews;
@end
@implementation WXMPhotoOverlayView

/** 创建view */
- (UIView *)generateLine {
    UIView *lines = [[UIView alloc] initWithFrame:CGRectZero];
    lines.backgroundColor = [UIColor whiteColor];
    [self addSubview:lines];
    return lines;
}
/** 初始化 */
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) [self setupInterface];
    return self;
}
- (void)setupInterface {
    UIView * (^lineView)(void) = ^UIView *(void) {
        return [self generateLine];
    };

    /** 四条外线 */
    _outerLineViews =  @[lineView(), lineView(), lineView(), lineView()];
    
    /**  */
    _topLeftLineViews = @[lineView(), lineView()];
    _bottomLeftLineViews = @[lineView(), lineView()];
    _topRightLineViews = @[lineView(), lineView()];
    _bottomRightLineViews = @[lineView(), lineView()];

    self.displayHorizontalGridLines = YES;
    self.displayVerticalGridLines = YES;
    self.clipsToBounds = NO;
    
   
}



/**  */
- (void)layoutLines {
    CGSize boundsSize = self.bounds.size;
    
    //边线
    for (NSInteger i = 0; i < self.outerLineViews.count; i++) {
        UIView *lineView = self.outerLineViews[i];
        CGRect frame = CGRectZero;
        switch (i) {
            case 0: frame = (CGRect){0,-1.0f,boundsSize.width+2.0f, 1.0f}; break; //top
            case 1: frame = (CGRect){boundsSize.width,0.0f,1.0f,boundsSize.height}; break; //right
            case 2: frame = (CGRect){-1.0f,boundsSize.height,boundsSize.width+2.0f,1.0f}; break; //bottom
            case 3: frame = (CGRect){-1.0f,0,1.0f,boundsSize.height+1.0f}; break; //left
        }
        lineView.frame = frame;
    }
    
    /** 四个角*/
    NSArray *cornerLines = @[_topLeftLineViews, _topRightLineViews, _bottomRightLineViews, _bottomLeftLineViews];
    for (NSInteger i = 0; i < 4; i++) {
        NSArray *cornerLine = cornerLines[i];
        
        CGRect verticalFrame = CGRectZero, horizontalFrame = CGRectZero;
        switch (i) {
            case 0: //top left
                verticalFrame = (CGRect){-3.0f,-3.0f,3.0f,WXMPhoto_CornerWidth+3.0f};
                horizontalFrame = (CGRect){0,-3.0f,WXMPhoto_CornerWidth,3.0f};
                break;
            case 1: //top right
                verticalFrame = (CGRect){boundsSize.width,-3.0f,3.0f,WXMPhoto_CornerWidth+3.0f};
                horizontalFrame = (CGRect){boundsSize.width-WXMPhoto_CornerWidth,-3.0f,WXMPhoto_CornerWidth,3.0f};
                break;
            case 2: //bottom right
                verticalFrame = (CGRect){boundsSize.width,boundsSize.height-WXMPhoto_CornerWidth,3.0f,WXMPhoto_CornerWidth+3.0f};
                horizontalFrame = (CGRect){boundsSize.width-WXMPhoto_CornerWidth,boundsSize.height,WXMPhoto_CornerWidth,3.0f};
                break;
            case 3: //bottom left
                verticalFrame = (CGRect){-3.0f,boundsSize.height-WXMPhoto_CornerWidth,3.0f,WXMPhoto_CornerWidth};
                horizontalFrame = (CGRect){-3.0f,boundsSize.height,WXMPhoto_CornerWidth+3.0f,3.0f};
                break;
        }
        
        [cornerLine[0] setFrame:verticalFrame];
        [cornerLine[1] setFrame:horizontalFrame];
    }
    
    /** 横线 */
    CGFloat thickness = 1.0f / [[UIScreen mainScreen] scale];
    NSInteger numberOfLines = self.horizontalGridLines.count;
    CGFloat padding = (CGRectGetHeight(self.bounds) - (thickness*numberOfLines)) / (numberOfLines + 1);
    for (NSInteger i = 0; i < numberOfLines; i++) {
        UIView *lineView = self.horizontalGridLines[i];
        CGRect frame = CGRectZero;
        frame.size.height = thickness;
        frame.size.width = CGRectGetWidth(self.bounds);
        frame.origin.y = (padding * (i+1)) + (thickness * i);
        lineView.frame = frame;
    }
    
    /** 竖线 */
    numberOfLines = self.verticalGridLines.count;
    padding = (CGRectGetWidth(self.bounds) - (thickness*numberOfLines)) / (numberOfLines + 1);
    for (NSInteger i = 0; i < numberOfLines; i++) {
        UIView *lineView = self.verticalGridLines[i];
        CGRect frame = CGRectZero;
        frame.size.width = thickness;
        frame.size.height = CGRectGetHeight(self.bounds);
        frame.origin.x = (padding * (i+1)) + (thickness * i);
        lineView.frame = frame;
    }
}

/** 设置隐藏横竖线 */
- (void)setGridHidden:(BOOL)hidden animated:(BOOL)animated {
    _gridHidden = hidden;
    CGFloat duration = 0;
    if (animated) duration = hidden ? 0.35f : 0.2f ;
    [UIView animateWithDuration:duration animations:^{
        for (UIView *lineView in self.horizontalGridLines) {
            lineView.alpha = hidden ? 0.0f : 1.0f;
        }
        for (UIView *lineView in self.verticalGridLines) {
            lineView.alpha = hidden ? 0.0f : 1.0f;
        }
    }];
}

/** 显示隐藏横向网格 */
- (void)setDisplayHorizontalGridLines:(BOOL)displayHorizontalGridLines {
    _displayHorizontalGridLines = displayHorizontalGridLines;
    [self.horizontalGridLines makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (_displayHorizontalGridLines) self.horizontalGridLines = @[[self generateLine], [self generateLine]];
    else self.horizontalGridLines = @[];
    [self setNeedsDisplay];
}

/** 显示隐藏垂直网格 */
- (void)setDisplayVerticalGridLines:(BOOL)displayVerticalGridLines {
    _displayVerticalGridLines = displayVerticalGridLines;
    [self.verticalGridLines makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (_displayVerticalGridLines) self.verticalGridLines = @[[self generateLine], [self generateLine]];
    else self.verticalGridLines = @[];
    [self setNeedsDisplay];
}

- (void)setGridHidden:(BOOL)gridHidden {
    [self setGridHidden:gridHidden animated:NO];
}
/** 设置frame */
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    if (_outerLineViews) [self layoutLines];
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    if (_outerLineViews) [self layoutLines];
}


@end

