//
//  WXMPhotoPreviewCell.m
//  ModuleDebugging
//
//  Created by edz on 2019/5/12.
//  Copyright © 2019年 wq. All rights reserved.
//

#import "WXMPhotoPreviewCell.h"
#import "WXMDirectionPanGestureRecognizer.h"
#import "WXMPhotoConfiguration.h"
#import <objc/runtime.h>
#import "WXMPhotoImageView.h"
#import "WXMPhotoGIFImage.h"
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wunguarded-availability"

@interface WXMPhotoPreviewCell () <UIScrollViewDelegate,UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIView *blackView;
@property (nonatomic, strong) UIScrollView *contentScrollView;
@property (nonatomic, strong) PHLivePhotoView *livePhotoView;
@property (nonatomic, strong) WXMPhotoImageView *imageView;
@property (nonatomic, strong) WXMDirectionPanGestureRecognizer *recognizer;
@property (nonatomic, assign) int32_t currentRequestID;
@property (nonatomic, assign) BOOL isPlayLivePhoto;

/** 距离原点的比例 */
@property (nonatomic, assign) CGFloat wxm_x;
@property (nonatomic, assign) CGFloat wxm_y;
@property (nonatomic, assign) CGFloat wxm_zoomScale;
@property (nonatomic, assign) CGPoint wxm_lastPoint;
@end
#pragma clang diagnostic pop

@implementation WXMPhotoPreviewCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) [self setupInterface];
    return self;
}

/** 初始化界面 */
- (void)setupInterface {
    CGFloat w = [UIScreen mainScreen].bounds.size.width ;
    CGFloat h = [UIScreen mainScreen].bounds.size.height;
    self.contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    self.contentScrollView.delegate = self;
    self.contentScrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.contentScrollView.showsHorizontalScrollIndicator = NO;
    self.contentScrollView.showsVerticalScrollIndicator = NO;
    self.contentScrollView.alwaysBounceHorizontal = NO;
    self.contentScrollView.alwaysBounceVertical = NO;
    self.contentScrollView.layer.masksToBounds = NO;
    
    self.imageView = [[WXMPhotoImageView alloc] initWithFrame:CGRectMake(0, 0, w, 0)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.layer.masksToBounds = YES;
    self.imageView.backgroundColor = [UIColor blackColor];
    self.imageView.userInteractionEnabled = NO;
    
    [self.contentView addSubview:self.blackView];
    [self.contentView addSubview:_contentScrollView];
    [self.contentScrollView addSubview:_imageView];
    [self.contentScrollView setMinimumZoomScale:1.0];
    [self.contentScrollView setMaximumZoomScale:2.5f];
    [self addTapGestureRecognizer];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wimplicit-retain-self"

/** 设置图片 GIF */
- (void)setPhotoAsset:(WXMPhotoAsset *)photoAsset {
    @autoreleasepool {
        
        _photoAsset = photoAsset;
        __weak __typeof(self) self_weak = self;
        CGFloat screenWidth  = WXMPhoto_Width * 2.0;
        WXMPhotoManager *man = [WXMPhotoManager sharedInstance];
        if (_photoAsset.aspectRatio <= 0) {
            _photoAsset.aspectRatio =
            (CGFloat)photoAsset.asset.pixelHeight /
            (CGFloat)photoAsset.asset.pixelWidth * 1.0;
        }
        CGFloat imageHeight = _photoAsset.aspectRatio * screenWidth;
                
        /** GIF */
        if (photoAsset.mediaType == WXMPHAssetMediaTypePhotoGif) {
            [man getGIFByAsset:photoAsset.asset completion:^(NSData *data) {
                [self_weak setLocation:_photoAsset.aspectRatio];
                self_weak.imageView.image = [WXMPhotoGIFImage imageWithData:data];
            }];
        } else {
            
            /** 有缓存加载缓存  */
            if (photoAsset.cacheImage) {
                self_weak.imageView.image = photoAsset.cacheImage;
                photoAsset.cacheImage = nil;
                [self_weak setLocation:_photoAsset.aspectRatio];
                return;
            }
            
            PHAsset *asset = photoAsset.asset;
            CGSize size = CGSizeMake(screenWidth, imageHeight);
            
            /** 很长的横图 需要获取原图 不然放大很模糊.. */
            if (imageHeight * 3 < WXMPhoto_Height) size = PHImageManagerMaximumSize;
            if (self.currentRequestID) [man cancelRequestWithID:self.currentRequestID];
            
            /** 自定义转场需要当前图片 */
            /** 所以先加载图片 在上面覆盖livephoto */
            int32_t ids = [man getPictures_customSize:asset synchronous:NO assetSize:size completion:^(UIImage *image) {
                self_weak.imageView.image = image;
                [self_weak setLocation:_photoAsset.aspectRatio];
            }];
            
            
            /** livephoto */
            if (_livePhotoView) self.livePhotoView.hidden = YES;
            if (photoAsset.mediaType == WXMPHAssetMediaTypeLivePhoto &&WXMPhotoShowLivePhto) {
                if (@available(iOS 9.1, *)) {
                    
                    self.livePhotoView.hidden = NO;
                    self.livePhotoView.livePhoto = nil;
                    [self.imageView addSubview:self.livePhotoView];
                    [man getLivePhotoByAsset:asset
                                    liveSize:size
                                  completion:^(PHLivePhoto *livePhoto)
                     {
                        self_weak.livePhotoView.livePhoto = livePhoto;
                        [self_weak setLocation:_photoAsset.aspectRatio];
                    }];
                }
            }
            
            self.currentRequestID = ids;
            _photoAsset.requestID = ids;
        }
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
    [_contentScrollView setZoomScale:1.0 animated:NO];
    if (_livePhotoView)  [_livePhotoView stopPlayback];
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
    self.imageView.frame = CGRectMake(0, 0, WXMPhoto_Width, WXMPhoto_Width * scale);
    self.imageView.center = CGPointMake(cw / 2, ch / 2);
    self.livePhotoView.frame = self.imageView.bounds;
    
    self.contentScrollView.maximumZoomScale = 2.5;
    if (self.imageView.height * self.contentScrollView.maximumZoomScale < WXMPhoto_Height) {
        CGFloat maxZoomScale = WXMPhoto_Height / self.imageView.height;
        self.contentScrollView.maximumZoomScale = maxZoomScale;
    }
}

/** 设置frame*/
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
    if (height > sHeight) imageViewFrame.origin.y = 0;
    else imageViewFrame.origin.y = (sHeight - height) / 2.0;
    
    if (width > sWidth) imageViewFrame.origin.x = 0;
    else imageViewFrame.origin.x = (sWidth - width) / 2.0;
    self.imageView.frame = imageViewFrame;
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
    _recognizer = [[WXMDirectionPanGestureRecognizer alloc] initWithTarget:self action:handle];
    _recognizer->_direction = DirectionPanGestureRecognizerBottom;
    _recognizer.maximumNumberOfTouches = 1;
    
    [tapSingle requireGestureRecognizerToFail:tapDouble];
    [tapSingle requireGestureRecognizerToFail:_recognizer];
    [tapDouble requireGestureRecognizerToFail:_recognizer];
    
    [_contentScrollView addGestureRecognizer:tapSingle];
    [_contentScrollView addGestureRecognizer:tapDouble];
    [_contentScrollView addGestureRecognizer:_recognizer];
}

/** 单击 */
- (void)respondsToTapSingle:(UITapGestureRecognizer *)tap {
    if ([self.delegate respondsToSelector:@selector(wxm_respondsToTapSingle)]) {
        [self.delegate wxm_respondsToTapSingle];
    }
}

/** 双击 */
- (void)respondsToTapDouble:(UITapGestureRecognizer *)tap {
    UIScrollView *scrollView = self.contentScrollView;
    UIView *zoomView = [self viewForZoomingInScrollView:scrollView];
    CGPoint point = [tap locationInView:zoomView];
    if (!CGRectContainsPoint(zoomView.bounds, point)) return;
    if (scrollView.zoomScale == scrollView.maximumZoomScale) {
        [scrollView setZoomScale:1 animated:YES];
    } else {
        [scrollView zoomToRect:CGRectMake(point.x, point.y, 1, 1) animated:YES];
    }
}

/** 设置手势顺序 */
- (void)setColleRecognizer:(UIPanGestureRecognizer *)colleRecognizer {
    _colleRecognizer = colleRecognizer;
    @try {
        [_recognizer requireGestureRecognizerToFail:_colleRecognizer];
    } @catch (NSException *exception) {} @finally {}
}

/** 滑动 */
/** 这里采用的判断是 在图片缩小过程中 手指的点始终距离图片的xy顶点是view真实大小(view一直在缩小)的固定比例 */
- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    [recognizer.view.superview bringSubviewToFront:recognizer.view];
    CGPoint center = recognizer.view.center;
    CGPoint translation = [recognizer translationInView:self];  /** 位移 */
    CGFloat wxm_centery = center.y + translation.y;             /** y轴位移 */
    CGFloat recognizer_W = recognizer.view.frame.size.width;
    CGFloat recognizer_H = recognizer.view.frame.size.height;
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [recognizer locationInView:self];
        self.wxm_x = point.x / recognizer_W;
        self.wxm_y = point.y / recognizer_H;
        self.wxm_lastPoint = recognizer.view.center;
        if (self.delegate && [self.delegate respondsToSelector:@selector(wxm_respondsBeginDragCell)]) {
            [self.delegate wxm_respondsBeginDragCell];
        }
        
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat displacement = wxm_centery - self.wxm_lastPoint.y;
        CGFloat proportion = 1;
        CGFloat scaleAlpha = 1;
        if (displacement <= 0) proportion = 1;
        else {
            CGFloat maxH = WXMPhoto_Height * 1.25;
            CGFloat scale = displacement / maxH;
            scaleAlpha = 1 - (displacement / (WXMPhoto_Height * 0.6));
            proportion = MAX(1 - scale, WXMPhotoMinification);
            if (displacement <= 0) scaleAlpha = 1;
        }
        self.blackView.alpha = scaleAlpha;
        recognizer.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, proportion, proportion);
        
        CGPoint point_XY = [recognizer locationInView:self];
        CGFloat distance_x = recognizer_W * _wxm_x;
        CGFloat distance_y = recognizer_H * _wxm_y;
        CGRect rect = recognizer.view.frame;
        rect.origin.x = point_XY.x - distance_x;
        rect.origin.y = point_XY.y - distance_y;
        recognizer.view.frame = rect;
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded ||
        recognizer.state == UIGestureRecognizerStateCancelled) {
        CGPoint velocity = [recognizer velocityInView:self];  /** 速度 */
        BOOL cancle = (velocity.y < 5 || self.blackView.alpha >= 1);
        if (cancle) {
            [UIView animateWithDuration:0.35 animations:^{
                recognizer.view.transform = CGAffineTransformIdentity;
                recognizer.view.center = self.wxm_lastPoint;
                self.blackView.alpha = 1;
            } completion:^(BOOL finished) {
                if ([self.delegate respondsToSelector:@selector(wxm_respondsEndDragCell:)]) {
                    [self.delegate wxm_respondsEndDragCell:nil];
                }
            }];
        } else {
            _contentScrollView.userInteractionEnabled = NO;
            if ([self.delegate respondsToSelector:@selector(wxm_respondsEndDragCell:)]) {
                [self.delegate wxm_respondsEndDragCell:self.contentScrollView];
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

