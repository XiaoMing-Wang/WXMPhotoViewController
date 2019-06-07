//
//  WXMPhotoVideoCell.m
//  Multi-project-coordination
//
//  Created by wq on 2019/6/2.
//  Copyright © 2019年 wxm. All rights reserved.
//
#define KNotificationCenter [NSNotificationCenter defaultCenter]
#import "WXMDirectionPanGestureRecognizer.h"
#import "WXMPhotoConfiguration.h"
#import <objc/runtime.h>
#import "WXMPhotoImageView.h"
#import "WXMPhotoGIFImage.h"
#import "WXMPhotoVideoCell.h"
@interface WXMPhotoVideoCell ()
@property (nonatomic, strong) UIScrollView *contentScrollView;
@property (nonatomic, strong) WXMPhotoImageView *imageView;
@property (nonatomic, strong) UIImageView *playIcon;
@property (nonatomic, strong) UIView *wxm_blackView;
@property (nonatomic, strong) WXMDirectionPanGestureRecognizer *recognizer;

/** 播放器 */
@property (strong, nonatomic) AVPlayer *wxm_avPlayer;
@property (strong, nonatomic) AVPlayerItem *wxm_item;
@property (strong, nonatomic) AVPlayerLayer *wxm_playerLayer;
/** @property (nonatomic, assign) BOOL wxm_isPlaying;; */

/** 距离原点的比例 */
@property (nonatomic, assign) CGFloat wxm_x;
@property (nonatomic, assign) CGFloat wxm_y;
@property (nonatomic, assign) CGFloat wxm_zoomScale;
@property (nonatomic, assign) CGPoint wxm_lastPoint;
@end

@implementation WXMPhotoVideoCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) [self setupInterface];
    return self;
}

/** 初始化界面 */
- (void)setupInterface {
    CGFloat w = WXMPhoto_Width;
    CGFloat h = WXMPhoto_Height;
    _contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    _contentScrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    _contentScrollView.showsHorizontalScrollIndicator = NO;
    _contentScrollView.showsVerticalScrollIndicator = NO;
    _contentScrollView.alwaysBounceHorizontal = NO;
    _contentScrollView.alwaysBounceVertical = NO;
    _contentScrollView.layer.masksToBounds = NO;
    _contentScrollView.scrollEnabled = NO;
    
    _imageView = [[WXMPhotoImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    _imageView.size = CGSizeMake(WXMPhoto_Width, WXMPhoto_Height);
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.layer.masksToBounds = YES;
    _imageView.backgroundColor = [UIColor blackColor];
    _imageView.userInteractionEnabled = YES;
    [_contentScrollView addSubview:_imageView];
    
    _playIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"phoro_play"]];
    _playIcon.size = WXMPhotoVideoSignSize;
    _playIcon.contentMode = UIViewContentModeScaleAspectFit;
    _playIcon.userInteractionEnabled = NO;
    [_imageView addSubview:_playIcon];
    
    [self.contentView addSubview:self.wxm_blackView];
    [self.contentView addSubview:_contentScrollView];
    [self wxm_addTapGestureRecognizer];
    
    [KNotificationCenter addObserver:self selector:@selector(wxm_runAgain) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [KNotificationCenter addObserver:self selector:@selector(enterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    [KNotificationCenter addObserver:self selector:@selector(enterBackground) name:UIApplicationWillResignActiveNotification object:nil];
}

/** 添加三个手势 */
- (void)wxm_addTapGestureRecognizer {
    UITapGestureRecognizer *tapSingle = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondsToTapSingle:)];
    tapSingle.numberOfTapsRequired = 1;
    
    _recognizer = [[WXMDirectionPanGestureRecognizer alloc] initWithTarget:self  action:@selector(wxm_handlePan:)];
    _recognizer->_direction = DirectionPanGestureRecognizerBottom;
    _recognizer.maximumNumberOfTouches = 1;
    
    [tapSingle requireGestureRecognizerToFail:_recognizer];
    [_contentScrollView addGestureRecognizer:tapSingle];
    [_contentScrollView addGestureRecognizer:_recognizer];
}


/** 设置image位置 */
- (void)setLocation:(CGFloat)scale {
    self.imageView.frame = CGRectMake(0, 0, _contentScrollView.width, _contentScrollView.width * scale);
    self.imageView.center = CGPointMake(_contentScrollView.width / 2, _contentScrollView.height / 2);
    self.playIcon.layoutCenterSupView = YES;
}

/** 设置图片Video */
- (void)setPhotoAsset:(WXMPhotoAsset *)photoAsset {
    @autoreleasepool {
        _photoAsset = photoAsset;
        CGFloat screenWidth  = WXMPhoto_Width * 2.0;
        WXMPhotoManager *man = [WXMPhotoManager sharedInstance];
        if (self.photoAsset.aspectRatio <= 0) {
            _photoAsset.aspectRatio = (CGFloat)photoAsset.asset.pixelHeight / (CGFloat)photoAsset.asset.pixelWidth * 1.0;
        }
        CGFloat imageHeight = self.photoAsset.aspectRatio * screenWidth;
        
        if (photoAsset.bigImage) {
            self.imageView.image = photoAsset.bigImage;
            [self setLocation:self.photoAsset.aspectRatio];
        } else {
            PHAsset *asset = photoAsset.asset;
            CGSize size = CGSizeMake(screenWidth, imageHeight);
            [man getPictures_customSize:asset synchronous:NO assetSize:size completion:^(UIImage *image) {
                photoAsset.bigImage = image;
                [self setLocation:self.photoAsset.aspectRatio];
                self.imageView.image = image;
            }];
        }
    }
}

/** 设置frame*/
- (void)setFrame:(CGRect)frame {
    frame.origin.x = -WXMPhotoPreviewSpace / 2;
    frame.size.width = [UIScreen mainScreen].bounds.size.width + WXMPhotoPreviewSpace;
    [super setFrame:frame];
}

/** 还原 */
- (void)originalAppearance {
    [self wxm_removeAvPlayer];
}

/** 单击 */
- (void)respondsToTapSingle:(UITapGestureRecognizer *)tap {
    self.playIcon.hidden  ? [self wxm_avPlayStopPlay] : [self wxm_avPlayStartPlay];
    if (self.delegate && [self.delegate respondsToSelector:@selector(wxm_respondsToTapSingle)]) {
        [self.delegate wxm_respondsToTapSingle];
    }
}

/** 开始播放视频 */
- (void)wxm_avPlayStartPlay {
  @autoreleasepool {
      
      void (^playBlock)(NSURL *url) = ^(NSURL *url) {
          if (!self.wxm_avPlayer) {
              self.wxm_item = [AVPlayerItem playerItemWithURL:url];
              self.wxm_avPlayer = [AVPlayer playerWithPlayerItem:self.wxm_item];
              self.wxm_playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.wxm_avPlayer];
              self.wxm_playerLayer.frame = self.contentScrollView.frame;
              [self.imageView.layer insertSublayer:self.wxm_playerLayer atIndex:0];
          }
          self.playIcon.hidden = YES;
          [self.wxm_avPlayer play];
      };
      
      if (self.photoAsset.videoUrl) playBlock(_photoAsset.videoUrl);
      if (!self.photoAsset.videoUrl) {
          WXMPhotoManager *man = [WXMPhotoManager sharedInstance];
          [man getVideoByAsset:_photoAsset.asset completion:^(NSURL *url, NSData * data) {
              self.photoAsset.videoUrl = url;
              playBlock(self.photoAsset.videoUrl);
          }];
      }
  }
}

/** 暂停 */
- (void)wxm_avPlayStopPlay {
    self.playIcon.hidden = NO;
    if (self.wxm_avPlayer) [self.wxm_avPlayer pause];
}

/** 滑动 */
- (void)wxm_handlePan:(UIPanGestureRecognizer *)recognizer {
    [recognizer.view.superview bringSubviewToFront:recognizer.view];
    CGPoint center = recognizer.view.center;
    CGPoint translation = [recognizer translationInView:self];  /** 位移 */
    CGFloat wxm_centery = center.y + translation.y;           /** y轴位移 */
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
        self.wxm_blackView.alpha = scaleAlpha;
        recognizer.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, proportion, proportion);
        
        CGPoint point_XY = [recognizer locationInView:self];
        CGFloat distance_x = recognizer_W * _wxm_x;
        CGFloat distance_y = recognizer_H * _wxm_y;
        CGRect rect = recognizer.view.frame;
        rect.origin.x = point_XY.x - distance_x;
        rect.origin.y = point_XY.y - distance_y;
        recognizer.view.frame = rect;
        /** [recognizer setTranslation:CGPointZero inView:self]; */
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded ||
        recognizer.state == UIGestureRecognizerStateCancelled) {
        CGPoint velocity = [recognizer velocityInView:self];  /** 速度 */
        BOOL cancle = (velocity.y < 0 || self.wxm_blackView.alpha >= 1);
        if (cancle) {
            [UIView animateWithDuration:0.35 animations:^{
                recognizer.view.transform = CGAffineTransformIdentity;
                recognizer.view.center = self.wxm_lastPoint;
                self.wxm_blackView.alpha = 1;
            } completion:^(BOOL finished) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(wxm_respondsEndDragCell:)]) {
                    [self.delegate wxm_respondsEndDragCell:nil];
                }
            }];
        } else {
            [self wxm_removeAvPlayer];
            self.contentScrollView.userInteractionEnabled = NO;
            if (self.delegate && [self.delegate respondsToSelector:@selector(wxm_respondsEndDragCell:)]) {
                [self.delegate wxm_respondsEndDragCell:self.contentScrollView];
            }
        }
    }
}

/** 黑色遮罩 */
- (UIView *)wxm_blackView {
    if (!_wxm_blackView)  {
        _wxm_blackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WXMPhoto_Width, WXMPhoto_Height)];
        _wxm_blackView.backgroundColor = [UIColor blackColor];
        objc_setAssociatedObject(_contentScrollView, @"black",_wxm_blackView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return _wxm_blackView;
}

- (void)wxm_runAgain {
    [self.wxm_item seekToTime:kCMTimeZero];
    [self.wxm_avPlayer play];
}

- (void)enterBackground {
    NSLog(@"进入后台");
    if (self.wxm_avPlayer && !self.playIcon.hidden) [self.wxm_avPlayer pause];
}

- (void)enterForeground {
    NSLog(@"进入前台");
    if (self.playIcon.hidden) [self wxm_avPlayStartPlay];
}

- (void)wxm_removeAvPlayer {
    @try {
        [self.wxm_avPlayer pause];
        [self.wxm_avPlayer setRate:0];
        self.wxm_item = nil;
        self.wxm_avPlayer = nil;
        [self.wxm_playerLayer removeFromSuperlayer];
        self.playIcon.hidden = NO;
        [KNotificationCenter removeObserver:self];
    } @catch (NSException *exception) { } @finally { }
}

- (void)dealloc {
    NSLog(@"释放wxm_playerLayer");
    [self wxm_removeAvPlayer];
}
@end
