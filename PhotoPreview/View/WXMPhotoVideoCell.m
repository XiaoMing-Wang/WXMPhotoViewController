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
@property (nonatomic, strong) UIView *wp_blackView;
@property (nonatomic, strong) WXMDirectionPanGestureRecognizer *recognizer;

/** 播放器 */
@property (strong, nonatomic) AVPlayer *wp_avPlayer;
@property (strong, nonatomic) AVPlayerItem *wp_item;
@property (strong, nonatomic) AVPlayerLayer *wp_playerLayer;

/** 距离原点的比例 */
@property (nonatomic, assign) CGFloat wp_x;
@property (nonatomic, assign) CGFloat wp_y;
@property (nonatomic, assign) CGFloat wp_zoomScale;
@property (nonatomic, assign) CGPoint wp_lastPoint;

@property (nonatomic, assign) int32_t currentRequestID;
@end

@implementation WXMPhotoVideoCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) [self initializationInterface];
    return self;
}

/** 初始化界面 */
- (void)initializationInterface {
    CGFloat w = WXMPhoto_Width;
    CGFloat h = WXMPhoto_Height;
    self.contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    self.contentScrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.contentScrollView.showsHorizontalScrollIndicator = NO;
    self.contentScrollView.showsVerticalScrollIndicator = NO;
    self.contentScrollView.alwaysBounceHorizontal = NO;
    self.contentScrollView.alwaysBounceVertical = NO;
    self.contentScrollView.layer.masksToBounds = NO;
    self.contentScrollView.scrollEnabled = NO;
    
    self.imageView = [[WXMPhotoImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.imageView.size = CGSizeMake(WXMPhoto_Width, WXMPhoto_Height);
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.layer.masksToBounds = YES;
    self.imageView.backgroundColor = [UIColor blackColor];
    self.imageView.userInteractionEnabled = YES;
    [self.contentScrollView addSubview:self.imageView];
    
    self.playIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"phoro_play"]];
    self.playIcon.size = WXMPhotoVideoSignSize;
    self.playIcon.contentMode = UIViewContentModeScaleAspectFit;
    self.playIcon.userInteractionEnabled = NO;
    [self.imageView addSubview:self.playIcon];
    
    [self.contentView addSubview:self.wp_blackView];
    [self.contentView addSubview:self.contentScrollView];
    [self wp_addTapGestureRecognizer];
    
    
    [KNotificationCenter addObserver:self
                            selector:@selector(enterForeground)
                                name:UIApplicationWillEnterForegroundNotification
                              object:nil];
    
    [KNotificationCenter addObserver:self
                            selector:@selector(enterBackground)
                                name:UIApplicationWillResignActiveNotification
                              object:nil];
}

/** 添加三个手势 */
- (void)wp_addTapGestureRecognizer {
    SEL selTap = @selector(respondsToTapSingle:);
    UITapGestureRecognizer *tapSingle = nil;
    tapSingle = [[UITapGestureRecognizer alloc] initWithTarget:self action:selTap];
    tapSingle.numberOfTapsRequired = 1;
    
    SEL handle = @selector(wp_handlePan:);
    self.recognizer = [[WXMDirectionPanGestureRecognizer alloc] initWithTarget:self action:handle];
    self.recognizer->_direction = DirectionPanGestureRecognizerBottom;
    self.recognizer.maximumNumberOfTouches = 1;
    
    [tapSingle requireGestureRecognizerToFail:self.recognizer];
    [self.contentScrollView addGestureRecognizer:tapSingle];
    [self.contentScrollView addGestureRecognizer:self.recognizer];
}


/** 设置image位置 */
- (void)setLocation:(CGFloat)scale {
    CGFloat width = self.contentScrollView.width;
    CGFloat height = width * scale;
    self.imageView.frame = CGRectMake(0, 0, width, height);
    self.imageView.center = CGPointMake(width / 2, self.contentScrollView.height / 2);
    self.playIcon.layoutCenterSupView = YES;
}

/** 异步赋值 数量特别多异步获取 */
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wimplicit-retain-self"

/** 设置图片Video */
- (void)setPhotoAsset:(WXMPhotoAsset *)photoAsset {
    _photoAsset = photoAsset;
    
    self.imageView.image = nil;
    CGFloat screenWidth  = WXMPhoto_Width * 2.0;
    WXMPhotoManager *manager = [WXMPhotoManager sharedInstance];
    if (_photoAsset.aspectRatio <= 0) {
        CGFloat h = (CGFloat) photoAsset.asset.pixelHeight;
        CGFloat w = (CGFloat) photoAsset.asset.pixelWidth;
        _photoAsset.aspectRatio = h / w * 1.0;
    }
    
    CGFloat imageHeight = photoAsset.aspectRatio * screenWidth;
    PHAsset *asset = photoAsset.asset;
    CGSize size = CGSizeMake(screenWidth, imageHeight);
    
    if (self.currentRequestID) [manager cancelRequestWithID:self.currentRequestID];
    int32_t ids = [manager getPicturesCustomSize:asset synchronous:NO assetSize:size completion:^(UIImage *image) {
        self.imageView.image = image;
        [self setLocation:_photoAsset.aspectRatio];
    }];
    
    self.currentRequestID = ids;
    _photoAsset.requestID = ids;
    
}

#pragma clang diagnostic pop

- (UIImage *)currentImage {
    return self.imageView.image;
}

/** 设置frame*/
- (void)setFrame:(CGRect)frame {
    frame.origin.x = -WXMPhotoPreviewSpace / 2;
    frame.size.width = [UIScreen mainScreen].bounds.size.width + WXMPhotoPreviewSpace;
    [super setFrame:frame];
}

/** 还原 */
- (void)originalAppearance {
    [self wp_removeAvPlayer];
}

/** 单击 */
- (void)respondsToTapSingle:(UITapGestureRecognizer *)tap {
    BOOL plays = !self.playIcon.hidden;
    self.playIcon.hidden  ? [self wp_avPlayStopPlay] : [self wp_avPlayStartPlay:YES];
    if ([self.delegate respondsToSelector:@selector(wp_respondsToTapSingle:)]) {
        [self.delegate wp_respondsToTapSingle:(plays)];
    }
}

/** 开始播放视频 */
- (void)wp_avPlayStartPlay:(bool)playImmediately {
    if (self.photoAsset.videoUrl) [self playVideos:playImmediately];
    if (!self.photoAsset.videoUrl) {
        WXMPhotoManager *manager = [WXMPhotoManager sharedInstance];
        [manager getVideoByAsset:self.photoAsset.asset completion:^(NSURL *url, NSData *data) {
            self.photoAsset.videoUrl = url;
            [self playVideos:playImmediately];
        }];
    }
}

- (void)playVideos:(bool)playImmediately {
    if (!self.wp_avPlayer) {
        self.wp_item = [AVPlayerItem playerItemWithURL:self.photoAsset.videoUrl];
        self.wp_avPlayer = [AVPlayer playerWithPlayerItem:self.wp_item];
        self.wp_playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.wp_avPlayer];
        self.wp_playerLayer.frame = self.imageView.bounds;
        [self.imageView.layer insertSublayer:self.wp_playerLayer atIndex:0];
        self.wp_playerLayer.hidden = YES;
        
        [KNotificationCenter addObserver:self
                                selector:@selector(wp_runAgain)
                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                  object:nil];
    }
    
    if (playImmediately) {
        self.playIcon.hidden = YES;
        self.wp_playerLayer.hidden = NO;
        [self.wp_avPlayer play];
    }
}

/** 暂停 */
- (void)wp_avPlayStopPlay {
    self.playIcon.hidden = NO;
    if (self.wp_avPlayer) [self.wp_avPlayer pause];
}

/** 滑动 */
- (void)wp_handlePan:(UIPanGestureRecognizer *)recognizer {
    [recognizer.view.superview bringSubviewToFront:recognizer.view];
    CGPoint center = recognizer.view.center;
    CGPoint translation = [recognizer translationInView:self];  /** 位移 */
    CGFloat wp_centery = center.y + translation.y;           /** y轴位移 */
    CGFloat recognizer_W = recognizer.view.frame.size.width;
    CGFloat recognizer_H = recognizer.view.frame.size.height;
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [recognizer locationInView:self];
        self.wp_x = point.x / recognizer_W;
        self.wp_y = point.y / recognizer_H;
        self.wp_lastPoint = recognizer.view.center;
        if ([self.delegate respondsToSelector:@selector(wp_respondsBeginDragCell)]) {
            [self.delegate wp_respondsBeginDragCell];
        }
        
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat displacement = wp_centery - self.wp_lastPoint.y;
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
        self.wp_blackView.alpha = scaleAlpha;
        recognizer.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, proportion, proportion);
        
        CGPoint point_XY = [recognizer locationInView:self];
        CGFloat distance_x = recognizer_W * _wp_x;
        CGFloat distance_y = recognizer_H * _wp_y;
        CGRect rect = recognizer.view.frame;
        rect.origin.x = point_XY.x - distance_x;
        rect.origin.y = point_XY.y - distance_y;
        recognizer.view.frame = rect;
        /** [recognizer setTranslation:CGPointZero inView:self]; */
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded ||
        recognizer.state == UIGestureRecognizerStateCancelled) {
        CGPoint velocity = [recognizer velocityInView:self];  /** 速度 */
        BOOL cancle = (velocity.y < 5 || self.wp_blackView.alpha >= 1);
        if (cancle) {
            [UIView animateWithDuration:0.35 animations:^{
                recognizer.view.transform = CGAffineTransformIdentity;
                recognizer.view.center = self.wp_lastPoint;
                self.wp_blackView.alpha = 1;
            } completion:^(BOOL finished) {
                if ([self.delegate respondsToSelector:@selector(wp_respondsEndDragCell:)]) {
                    [self.delegate wp_respondsEndDragCell:nil];
                }
            }];
        } else {
            [self wp_removeAvPlayer];
            self.contentScrollView.userInteractionEnabled = NO;
            if ([self.delegate respondsToSelector:@selector(wp_respondsEndDragCell:)]) {
                [self.delegate wp_respondsEndDragCell:self.contentScrollView];
            }
        }
    }
}

/** 黑色遮罩 */
- (UIView *)wp_blackView {
    if (!_wp_blackView)  {
        CGRect rect = CGRectMake(0, 0, WXMPhoto_Width, WXMPhoto_Height);
        _wp_blackView = [[UIView alloc] initWithFrame:rect];
        _wp_blackView.backgroundColor = [UIColor blackColor];
        objc_setAssociatedObject(_contentScrollView, @"black",_wp_blackView, 1);
    }
    return _wp_blackView;
}

- (void)wp_runAgain {
    [self.wp_item seekToTime:kCMTimeZero];
    [self.wp_avPlayer play];
}

- (void)enterBackground {
    NSLog(@"进入后台");
    if (self.wp_avPlayer && !self.playIcon.hidden) [self.wp_avPlayer pause];
}

- (void)enterForeground {
    NSLog(@"进入前台");
    if (self.playIcon.hidden) [self wp_avPlayStartPlay:YES];
}

- (void)wp_removeAvPlayer {
    @try {
        [self.wp_avPlayer pause];
        [self.wp_avPlayer setRate:0];
        self.wp_item = nil;
        self.wp_avPlayer = nil;
        [self.wp_playerLayer removeFromSuperlayer];
        self.playIcon.hidden = NO;
        [KNotificationCenter removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    } @catch (NSException *exception) { } @finally { }
}

- (void)dealloc {
    NSLog(@"释放wp_playerLayer");
    [self wp_removeAvPlayer];
}
@end
