//
//  WXMPhotoShapeController.m
//  ModuleDebugging
//
//  Created by edz on 2019/5/17.
//  Copyright © 2019年 wq. All rights reserved.
//
#import "WXMResourceAssistant.h"
#import "WXMPhotoShapeController.h"
#import "WXMPhotoConfiguration.h"
#import "TOCropView.h"
#import "TOCropToolbar.h"
#import "UIView+WXMPhoto.h"
#import "UIImage+WXMPhoto.h"

@interface WXMPhotoShapeController () <TOCropViewDelegate>
@property (nonatomic, weak) UINavigationController *weakNavigationVC;
@property (nonatomic, strong) TOCropView *cropView;
@property (nonatomic, strong) TOCropToolbar *cropToolbar;
@end

@implementation WXMPhotoShapeController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithTitle:@"" style:0 target:nil action:nil];
    self.navigationItem.leftBarButtonItem = item;
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    UIColor * whiteColor = [[UIColor whiteColor] colorWithAlphaComponent:0.0];
    UIImage *imageN = [WXMPhotoAssistant wxmPhoto_imageWithColor:whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:imageN
                                                  forBarMetrics:UIBarMetricsDefault];
    
    self.navigationController.navigationBar.translucent = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor blackColor];
    self.view.clipsToBounds = YES;
    [self initializationInterface];
}

/** */
- (void)initializationInterface {
    __weak __typeof(self) weakself = self;
    _cropView = [[TOCropView alloc] initWithImage:self.shapeImage];
    _cropView.frame = (CGRect){0,0,WXMPhoto_Width,WXMPhoto_Height - 44};
    _cropView.aspectRatioLockEnabled = YES;
    _cropView.resetAspectRatioEnabled = NO;
    _cropView.aspectRatio = CGSizeMake(1, 1);
    _cropView.delegate = self;
    
    CGFloat y = WXMPhoto_Height - 44.0f;
    _cropToolbar = [[TOCropToolbar alloc] initWithFrame:CGRectMake(0, y, WXMPhoto_Width, 44.0f)];
    _cropToolbar.clampButtonHidden = YES;
    _cropToolbar.doneTextButtonTitle = @"确定";
    _cropToolbar.cancelTextButtonTitle = @"取消";
    [_cropToolbar.doneIconButton wxm_setEnlargeEdgeWithTop:10 left:15 right:15 bottom:10];
    [_cropToolbar.cancelIconButton wxm_setEnlargeEdgeWithTop:10 left:15 right:15 bottom:10];
    
    _cropToolbar.cancelButtonTapped = ^{ [weakself popViewController]; };
    _cropToolbar.doneButtonTapped = ^{ [weakself dismissViewController]; };
    _cropToolbar.rotateCounterclockwiseButtonTapped = ^{ [weakself rotateCropViewCounterclockwise];};
    _cropToolbar.rotateClockwiseButtonTapped = ^{ [weakself rotateCropViewClockwise]; };
    _cropToolbar.resetButtonTapped = ^{ [weakself resetCropViewLayout]; };
    
    CALayer *line = [CALayer layer];
    line.frame = CGRectMake(0, 0, WXMPhoto_Width, 0.5);
    line.backgroundColor = [WXMPhoto_RGBColor(235, 235, 235) colorWithAlphaComponent:0.2].CGColor;
    [_cropToolbar.layer addSublayer:line];
    
    [self.view addSubview:_cropView];
    [self.view addSubview:_cropToolbar];
}

- (void)rotateCropViewCounterclockwise {
    [self.cropView rotateImageNinetyDegreesAnimated:YES clockwise:NO];
}

- (void)rotateCropViewClockwise {
    [self.cropView rotateImageNinetyDegreesAnimated:YES clockwise:YES];
}

- (void)resetCropViewLayout {
    [self.cropView resetLayoutToDefaultAnimated:NO];
    self.cropView.aspectRatioLockEnabled = YES;
    self.cropView.aspectRatio = CGSizeMake(1, 1);
}

- (void)popViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dismissViewController {
    CGRect cropFrame = self.cropView.imageCropFrame;
    NSInteger angle = self.cropView.angle;
    UIImage *cropImage = [self.cropView.image croppedImageWithFrame:cropFrame
                                                              angle:angle
                                                       circularClip:NO];
    [WXMResourceAssistant sendCoverImage:cropImage delegate:self.delegate];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Crop View Delegates -
- (void)cropViewDidBecomeResettable:(TOCropView *)cropView {
    _cropToolbar.resetButtonEnabled = YES;
}

- (void)cropViewDidBecomeNonResettable:(TOCropView *)cropView {
    _cropToolbar.resetButtonEnabled = NO;
}


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.weakNavigationVC = self.navigationController;
    self.weakNavigationVC.interactivePopGestureRecognizer.enabled = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.navigationController.navigationBar.userInteractionEnabled = NO;
    });
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.weakNavigationVC.interactivePopGestureRecognizer.enabled = YES;
}

- (void)dealloc {
    UIColor * whiteColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0];
    UIImage *imageN = [WXMPhotoAssistant wxmPhoto_imageWithColor:whiteColor];
    [self.weakNavigationVC.navigationBar setBackgroundImage:imageN forBarMetrics:UIBarMetricsDefault];
}
#pragma clang diagnostic pop

@end

