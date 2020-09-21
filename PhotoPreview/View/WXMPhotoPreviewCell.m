//
//  WXMPhotoPreviewCell.m
//  ModuleDebugging
//
//  Created by edz on 2019/5/12.
//  Copyright © 2019年 wq. All rights reserved.
//

#import "WXMPhotoPreviewCell.h"
#import "WXMPhotoDirectionPan.h"
#import "WXMPhotoConfiguration.h"
#import <objc/runtime.h>
#import "WXMPhotoImageView.h"
#import "WXMPhotoGIFImage.h"
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wunguarded-availability"

@interface WXMPhotoPreviewCell () <UIScrollViewDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIView *blackView;
@property (nonatomic, strong) UIScrollView *contentScrollView;
@property (nonatomic, strong) PHLivePhotoView *livePhotoView;
@property (nonatomic, strong) WXMPhotoImageView *imageView;
@property (nonatomic, strong) WXMPhotoDirectionPan *recognizer;
@property (nonatomic, assign) CGRect imageRect;
@property (nonatomic, assign) int32_t currentRequestID;
@property (nonatomic, assign) BOOL isPlayLivePhoto;

@property (nonatomic, assign) CGFloat offX;
@property (nonatomic, assign) CGFloat offY;
@property (nonatomic, assign) CGPoint lastPoint;
@end
#pragma clang diagnostic pop

@implementation WXMPhotoPreviewCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) [self initializationInterface];
    return self;
}

- (void)initializationInterface {
    self.contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, WXMPhoto_Width, WXMPhoto_Height)];
    self.contentScrollView.delegate = self;
    self.contentScrollView.showsHorizontalScrollIndicator = NO;
    self.contentScrollView.showsVerticalScrollIndicator = NO;
    self.contentScrollView.alwaysBounceHorizontal = NO;
    self.contentScrollView.alwaysBounceVertical = NO;
    self.contentScrollView.layer.masksToBounds = NO;
    self.contentScrollView.contentInsetBottom = WXMPhoto_SafeHeight;
    if (@available(iOS 13.0, *)) {
        self.contentScrollView.automaticallyAdjustsScrollIndicatorInsets = NO;
    }
    
    if (@available(iOS 11.0, *)) {
        self.contentScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    self.imageView = [[WXMPhotoImageView alloc] initWithFrame:CGRectMake(0, 0, WXMPhoto_Width, 0)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.layer.masksToBounds = YES;
    self.imageView.backgroundColor = [UIColor blackColor];
    self.imageView.userInteractionEnabled = NO;
    
    [self.contentView addSubview:self.blackView];
    [self.contentView addSubview:self.contentScrollView];
    [self.contentScrollView addSubview:self.imageView];
    [self.contentScrollView setMinimumZoomScale:1.0];
    [self.contentScrollView setMaximumZoomScale:2.5f];
    [self addTapGestureRecognizer];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wimplicit-retain-self"

/** 设置图片 GIF */
- (void)setPhotoAsset:(WXMPhotoAsset *)photoAsset {
    _photoAsset = photoAsset;
     
    CGFloat screenWidth  = WXMPhoto_Width * 2.0;
    if (_photoAsset.aspectRatio <= 0) {
        CGFloat h = (CGFloat) photoAsset.asset.pixelHeight;
        CGFloat w = (CGFloat) photoAsset.asset.pixelWidth;
        _photoAsset.aspectRatio = h / w * 1.0;
    }
    CGFloat imageHeight = _photoAsset.aspectRatio * screenWidth;
    
    /** GIF */
    if (photoAsset.mediaType == WXMPHAssetMediaTypePhotoGif && _supportGIF) {
        
        [[WXMPhotoManager sharedInstance] getGIFByAsset:photoAsset.asset completion:^(NSData *imageData) {
            [self setLocation:_photoAsset.aspectRatio];
            self.imageView.image = [WXMPhotoGIFImage imageWithData:imageData];
        }];
        
    } else {
        
        /** 有缓存加载缓存  */
        if (photoAsset.cacheImage) {
            self.imageView.image = photoAsset.cacheImage;
            [self setLocation:_photoAsset.aspectRatio];
            photoAsset.cacheImage = nil;
            return;
        }
        
        PHAsset *asset = photoAsset.asset;
        CGSize size = CGSizeMake(screenWidth, imageHeight);
        
        /** 很长的横图 需要获取原图 不然放大很模糊.. */
        if (imageHeight * 3 < WXMPhoto_Height) size = PHImageManagerMaximumSize;
        if (self.currentRequestID) [[WXMPhotoManager sharedInstance] cancelRequestWithID:self.currentRequestID];
        
        /** 自定义转场需要当前图片 */
        /** 所以先加载图片 在上面覆盖livephoto */
        int32_t ids = [[WXMPhotoManager sharedInstance] getPicturesCustomSize:asset synchronous:NO assetSize:size completion:^(UIImage *image) {
            @autoreleasepool {
                self.imageView.image = image;
            }
            [self setLocation:_photoAsset.aspectRatio];
        }];
        
        
        /** livephoto */
        if (_livePhotoView) self.livePhotoView.hidden = YES;
        if (photoAsset.mediaType == WXMPHAssetMediaTypeLivePhoto && WXMPhotoShowLivePhto) {
            self.livePhotoView.hidden = NO;
            self.livePhotoView.livePhoto = nil;
            [self.imageView addSubview:self.livePhotoView];
            [[WXMPhotoManager sharedInstance] getLivePhotoByAsset:asset liveSize:size completion:^(PHLivePhoto *livePhoto) {
                self.livePhotoView.livePhoto = livePhoto;
                [self setLocation:_photoAsset.aspectRatio];
            }];
        }
        
        self.currentRequestID = ids;
        _photoAsset.requestID = ids;
    }
}

#pragma clang diagnostic pop
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wunguarded-availability"

/** 开始播放livephoto */
- (void)startPlayLivePhoto {
    if (_livePhotoView && _isPlayLivePhoto == NO) {
        _isPlayLivePhoto = YES;
        [_livePhotoView stopPlayback];
        [_livePhotoView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleHint];
    }
}

/** 还原 */
- (void)originalAppearance {
    _isPlayLivePhoto = NO;
    [self.contentScrollView setZoomScale:1.0 animated:NO];
    self.imageView.frame = self.imageRect;
    if (_livePhotoView)  [_livePhotoView stopPlayback];
    self.recognizer.enabled = (self.imageView.height <= WXMPhoto_Height);
}

#pragma clang diagnostic pop

/** 获取当前image */
- (UIImage *)currentImage {
    return self.imageView.image;
}

/** 设置image位置 */
- (void)setLocation:(CGFloat)scale {
    CGFloat cw = self.contentScrollView.frame.size.width;
    CGFloat ch = self.contentScrollView.frame.size.height;
    
    [self.contentScrollView setZoomScale:1.0 animated:NO];
    self.imageView.frame = CGRectMake(0, 0, WXMPhoto_Width, WXMPhoto_Width * scale);
    self.imageView.center = CGPointMake(cw / 2, ch / 2);
    if ((WXMPhoto_Width * scale) > WXMPhoto_Height) self.imageView.top = 0;
    self.livePhotoView.frame = self.imageView.bounds;
    self.imageRect = self.imageView.frame;
    
    self.contentScrollView.contentSizeHeight = self.imageView.height;
    self.contentScrollView.maximumZoomScale = 2.5;
    if (self.imageView.height * self.contentScrollView.maximumZoomScale < WXMPhoto_Height) {
        CGFloat maxZoomScale = WXMPhoto_Height / self.imageView.height;
        self.contentScrollView.maximumZoomScale = maxZoomScale;
    }
}

- (void)setFrame:(CGRect)frame {
    frame.origin.x = -WXMPhotoPreviewSpace / 2;
    frame.size.width = [UIScreen mainScreen].bounds.size.width + WXMPhotoPreviewSpace;
    [super setFrame:frame];
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGRect imageViewFrame = self.imageView.frame;
    CGFloat width = imageViewFrame.size.width;
    CGFloat height = imageViewFrame.size.height;
    CGFloat sHeight = scrollView.bounds.size.height;
    CGFloat sWidth = scrollView.bounds.size.width;
    if (height >= sHeight) imageViewFrame.origin.y = 0;
    else imageViewFrame.origin.y = (sHeight - height) / 2.0;
    
    if (width >= sWidth) imageViewFrame.origin.x = 0;
    else imageViewFrame.origin.x = (sWidth - width) / 2.0;
    self.imageView.frame = imageViewFrame;
    self.imageView.userInteractionEnabled = NO;
    self.recognizer.enabled = (scrollView.zoomScale <= 1);
    if (scrollView.zoomScale <= 1) {
        scrollView.contentSize = CGSizeMake(0, scrollView.contentSize.height);
    }
}

/** 添加手势 */
- (void)addTapGestureRecognizer {
    SEL selTap = @selector(respondsToTapSingle:);
    UITapGestureRecognizer *tapSingle = nil;
    tapSingle = [[UITapGestureRecognizer alloc] initWithTarget:self action:selTap];
    tapSingle.numberOfTapsRequired = 1;
    
    SEL doubleTap = @selector(respondsToTapDouble:);
    UITapGestureRecognizer *tapDouble = nil;
    tapDouble = [[UITapGestureRecognizer alloc] initWithTarget:self action:doubleTap];
    tapDouble.numberOfTapsRequired = 2;
    
    SEL handle = @selector(handlePan:);
    _recognizer = [[WXMPhotoDirectionPan alloc] initWithTarget:self action:handle];
    _recognizer->_direction = DirectionPanGestureRecognizerBottom;
    _recognizer.maximumNumberOfTouches = 1;
    _recognizer.delegate = self;
    
    [tapSingle requireGestureRecognizerToFail:tapDouble];
    [tapSingle requireGestureRecognizerToFail:_recognizer];
    [tapDouble requireGestureRecognizerToFail:_recognizer];
    
    [_contentScrollView addGestureRecognizer:tapSingle];
    [_contentScrollView addGestureRecognizer:tapDouble];
    [_contentScrollView addGestureRecognizer:_recognizer];
}

/** 单击 */
- (void)respondsToTapSingle:(UITapGestureRecognizer *)tap {
    if ([self.delegate respondsToSelector:@selector(wp_respondsToTapSingle:)]) {
        [self.delegate wp_respondsToTapSingle:NO];
    }
}

/** 双击 */
- (void)respondsToTapDouble:(UITapGestureRecognizer *)tap {
    UIScrollView *scrollView = self.contentScrollView;
    UIView *zoomView = [self viewForZoomingInScrollView:scrollView];
    CGPoint point = [tap locationInView:zoomView];
    if (!CGRectContainsPoint(zoomView.bounds, point)) return;
    if (scrollView.zoomScale > 1) {
        [scrollView setZoomScale:1.0 animated:YES];
    } else {
        [scrollView zoomToRect:CGRectMake(point.x, point.y, 1, 1) animated:YES];
    }
}

/** 设置手势顺序 比colleview的等级低 */
- (void)setColleRecognizer:(UIPanGestureRecognizer *)colleRecognizer {
    _colleRecognizer = colleRecognizer;
    @try {
        [_contentScrollView.panGestureRecognizer requireGestureRecognizerToFail:_colleRecognizer];
        [_recognizer requireGestureRecognizerToFail:_colleRecognizer];
    } @catch (NSException *exception) {} @finally {}
}


/** 滑动 */
/** 这里采用的判断是 在图片缩小过程中 手指的点始终距离图片的xy顶点是view真实大小(view一直在缩小)的固定比例 */
- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    [recognizer.view.superview bringSubviewToFront:recognizer.view];
    CGPoint center = recognizer.view.center;
    CGPoint location = [recognizer locationInView:self];
      
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.lastPoint = recognizer.view.center;
        self.offX = (WXMPhoto_Width / 2.0) - location.x;
        self.offY = (WXMPhoto_Height / 2.0) - location.y;
        if (self.delegate && [self.delegate respondsToSelector:@selector(wp_respondsBeginDragCell)]) {
            [self.delegate wp_respondsBeginDragCell];
        }

    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat displacement = center.y - self.lastPoint.y;
        CGFloat proportion = 1;
        CGFloat scaleAlpha = 1;
        if (displacement <= 0)  {
            proportion = 1;
        } else {
            CGFloat scale = displacement / (WXMPhoto_Height * 0.80);
            scaleAlpha = 1 - (displacement / (WXMPhoto_Height * 0.6));
            proportion = MAX(1 - scale, WXMPhotoMinification);
            if (displacement <= 0) scaleAlpha = 1;
        }
      
        CGFloat narrowProportion = recognizer.view.width / WXMPhoto_Width;
        CGFloat centerX = location.x + (self.offX * narrowProportion);
        CGFloat centerY = location.y + (self.offY * narrowProportion);
       
        self.blackView.alpha = scaleAlpha;
        recognizer.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, proportion, proportion);
        recognizer.view.center = CGPointMake(centerX, centerY);
        [recognizer setTranslation:CGPointZero inView:self];
    }

    if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {

        /** 速度 */
        CGPoint velocity = [recognizer velocityInView:self];
        BOOL cancle = (velocity.y < 5 || self.blackView.alpha >= 1);
        if (cancle) {

            [self.contentScrollView setZoomScale:1.01 animated:YES];
            [UIView animateWithDuration:0.35 animations:^{
                recognizer.view.transform = CGAffineTransformIdentity;
                recognizer.view.center = self.lastPoint;
                self.blackView.alpha = 1;
            } completion:^(BOOL finished) {
                [self.contentScrollView setZoomScale:1.0 animated:YES];
                if ([self.delegate respondsToSelector:@selector(wp_respondsEndDragCell:)]) {
                    [self.delegate wp_respondsEndDragCell:nil];
                }
            }];

        } else {
            _contentScrollView.userInteractionEnabled = NO;
            if ([self.delegate respondsToSelector:@selector(wp_respondsEndDragCell:)]) {
                [self.delegate wp_respondsEndDragCell:self.contentScrollView];
            }
        }
    }
}

- (UIView *)blackView {
    if (!_blackView)  {
        CGRect rect = CGRectMake(0, 0, WXMPhoto_Width, WXMPhoto_Height);
        _blackView = [[UIView alloc] initWithFrame:rect];
        _blackView.backgroundColor = [UIColor blackColor];
        objc_setAssociatedObject(_contentScrollView, @"black",_blackView, 1);
    }
    return _blackView;
}

- (PHLivePhotoView *)livePhotoView  API_AVAILABLE(ios(9.1)) {
    if (!_livePhotoView) {
        _livePhotoView = [[PHLivePhotoView alloc] init];
        _livePhotoView.userInteractionEnabled = NO;
        _livePhotoView.contentMode = UIViewContentModeScaleAspectFit;
        _livePhotoView.muted = WXMPhotoShowLivePhtoMuted;
    }
    return _livePhotoView;
}

- (void)dealloc {
    self.imageView.image = nil;
}

@end

