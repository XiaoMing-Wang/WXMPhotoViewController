//
//  WXMPhotoShapeController.m
//  ModuleDebugging
//
//  Created by edz on 2019/5/17.
//  Copyright © 2019年 wq. All rights reserved.
//

#import "WXMPhotoShapeController.h"
#import "WXMPhotoConfiguration.h"
#import "WXMScanAssistant.h"
#import "WXMPhotoOverlayView.h"
#import "WXMPhotoCropView.h"

@interface WXMPhotoShapeController ()
@property(nonatomic, weak) UINavigationController *weakNavigationVC;

@end

@implementation WXMPhotoShapeController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithTitle:@"" style:0 target:nil action:nil];
//    self.navigationItem.leftBarButtonItem = item;
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    UIColor * whiteColor = [[UIColor whiteColor] colorWithAlphaComponent:0.0];
    UIImage *imageN = [WXMPhotoAssistant wxmPhoto_imageWithColor:whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:imageN forBarMetrics:UIBarMetricsDefault];
    
    self.navigationController.navigationBar.translucent = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor blackColor];
    self.view.clipsToBounds = YES;

    WXMPhotoCropView * cropView = [[WXMPhotoCropView alloc] initWithImage:self.shapeImage];
    
    [self.view addSubview:cropView];
//    [self.view addSubview:self.touchView];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.weakNavigationVC = self.navigationController;
    self.weakNavigationVC.interactivePopGestureRecognizer.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        self.navigationController.navigationBar.userInteractionEnabled = NO;
    });
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.weakNavigationVC.interactivePopGestureRecognizer.enabled = YES;
}


@end

