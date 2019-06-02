//
//  WXMPhotoPreviewController.m
//  ModuleDebugging
//
//  Created by edz on 2019/5/12.
//  Copyright © 2019年 wq. All rights reserved.
//
#import "WXMPhotoPreviewController.h"
#import "WXMPhotoPreviewCell.h"
#import "WXMPhotoConfiguration.h"
#import "WXMPreviewTopBar.h"
#import "WXMPreviewBottomBar.h"
#import "WXMPhotoTransitions.h"
#import "WXMPhotoVideoCell.h"

@interface WXMPhotoPreviewController ()
<UICollectionViewDelegate, UICollectionViewDataSource,WXMPreviewCellProtocol,
WXMPreviewToolbarProtocol,UINavigationControllerDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, weak) UINavigationController *weakNavigationVC;
@property (nonatomic, strong) UIScrollView *transitionScrollView;
@property (nonatomic, strong) WXMPreviewTopBar *topBarView;
@property (nonatomic, strong) WXMPreviewBottomBar *bottomBarView;

@property (readwrite, nonatomic) UIStatusBarStyle lastStatusBarStyle;
@property (nonatomic, assign) BOOL statusBarHidden;
@property (nonatomic, assign) BOOL showToolbar;
@property (nonatomic, assign) NSInteger selectedIndex;
@end

@implementation WXMPhotoPreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithTitle:@"" style:0 target:nil action:nil];
    self.navigationItem.leftBarButtonItem = item;
    self.navigationController.delegate = self;
    
    self.weakNavigationVC = self.navigationController;
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1.0];
    if (self.windowImage) self.view.layer.contents = (id)self.windowImage.CGImage;
    if (self.windowView) [self.view addSubview:self.windowView];
    [self.view addSubview:self.collectionView];
    
    self.navigationController.navigationBar.translucent = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    UIColor * whiteColor = [[UIColor whiteColor] colorWithAlphaComponent:0.0];
    UIImage *imageN = [WXMPhotoAssistant wxmPhoto_imageWithColor:whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:imageN forBarMetrics:UIBarMetricsDefault];
    
    @try {
        UIViewController * firstVC = self.navigationController.viewControllers.firstObject;
        self.navigationController.interactivePopGestureRecognizer.delegate = (id)firstVC;
        UIGestureRecognizer * ges = self.navigationController.interactivePopGestureRecognizer;
        [ges requireGestureRecognizerToFail:_collectionView.panGestureRecognizer];
    } @catch (NSException *exception) {} @finally {};
    
    /** 导航栏 */
    [self.view addSubview:self.topBarView];
    [self.view addSubview:self.bottomBarView];
    
    /** 滚动到选中行 */
    if (_dataSource.count <= 1) self.collectionView.alwaysBounceHorizontal = YES;
    if (_dataSource.count <= _indexPath.row) return;
    self.selectedIndex = self.indexPath.row;
    [self wxm_setBottomBarViewrealByte];
    NSIndexPath * index = [NSIndexPath indexPathForRow:self.indexPath.row inSection:0];
    UICollectionViewScrollPosition position = UICollectionViewScrollPositionCenteredHorizontally;
    [self.collectionView scrollToItemAtIndexPath:index atScrollPosition:position animated:NO];
}
#pragma mark _____________________________________________UICollectionView dataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WXMPhotoAsset *asset = self.dataSource[indexPath.row];
    UICollectionView *cv = collectionView;
    UICollectionViewCell * cell = nil;
    
    if (asset.mediaType == WXMPHAssetMediaTypeVideo) {
        cell = [cv dequeueReusableCellWithReuseIdentifier:@"aCell" forIndexPath:indexPath];
        ((WXMPhotoVideoCell *)cell).delegate = self;
        ((WXMPhotoVideoCell *)cell).photoAsset = asset;
    } else {
        cell = [cv dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
        ((WXMPhotoPreviewCell *)cell).delegate = self;
        ((WXMPhotoPreviewCell *)cell).photoAsset = asset;
    }
    return cell;
}

/** 上一个复位 */
- (void)collectionView:(UICollectionView *)collectionView
  didEndDisplayingCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell respondsToSelector:@selector(originalAppearance)]) {
        [cell performSelector:@selector(originalAppearance)];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offY = scrollView.contentOffset.x;
    CGFloat index = offY / scrollView.frame.size.width;
    NSInteger location = self.selectedIndex;
    if (index >= self.selectedIndex + 0.5) location = self.selectedIndex + 1;
    else if (index <= self.selectedIndex - 0.5) location = self.selectedIndex - 1;
    else location = self.selectedIndex;
    [self wxm_setUpTopView:location];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat offY = scrollView.contentOffset.x;
    self.selectedIndex = offY / scrollView.frame.size.width;
    [self wxm_setUpTopView:self.selectedIndex];
    [self wxm_setBottomBarViewrealByte];
}

/** 获取当前图片的原始大小 */
- (void)wxm_setBottomBarViewrealByte {
    WXMPhotoAsset *asset = self.dataSource[self.selectedIndex];
    if (asset.mediaType == WXMPHAssetMediaTypeVideo) {
        
        self.bottomBarView.isShowOriginalButton = NO;
    } else {
        CGFloat bytes = asset.bytes;
        if (bytes < 100) {
            bytes = [WXMPhotoAssistant wxm_getOriginalSize:asset.asset];
            asset.bytes = bytes;
        }
        NSString * realByte =  [NSString stringWithFormat:@"%.2fM", bytes / (1024 * 1024)];
        [self.bottomBarView setRealImageByte:realByte];
        self.bottomBarView.isShowOriginalButton = YES;
    }
}

#pragma mark _____________________________________________ cell回调代理

/** cell回调代理 */
- (void)wxm_respondsToTapSingle {
    self.showToolbar = !self.showToolbar;
    self.topBarView.hidden = self.bottomBarView.hidden = self.showToolbar;
    [UIApplication sharedApplication].statusBarHidden = self.topBarView.hidden;
    if (self.topBarView.hidden == NO) self.topBarView.alpha = 1;
    if (self.bottomBarView.hidden == NO) self.bottomBarView.alpha = 1;
}

/**  */
- (void)wxm_respondsBeginDragCell {
    self.collectionView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    [self.topBarView setAccordingState:NO];
    [self.bottomBarView setAccordingState:NO];
    [UIApplication sharedApplication].statusBarStyle = self.lastStatusBarStyle;
    self.collectionView.scrollEnabled = NO;
}

- (void)wxm_respondsEndDragCell:(UIScrollView *)jump {
    if (jump == nil) {
        self.collectionView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1];
        [self.topBarView setAccordingState:YES];
        [self.bottomBarView setAccordingState:YES];
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        self.collectionView.scrollEnabled = YES;
        [UIApplication sharedApplication].statusBarHidden = NO;
    } else {
        self.transitionScrollView = jump;
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}
#pragma mark 回调

/** 工具栏回调 */
- (void)wxm_touchTopLeftItem {
    self.navigationController.delegate = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)wxm_touchTopRightItem:(WXMPhotoSignModel *)obj {
    if (self.signDictionary.allKeys.count >= WXMMultiSelectMax && !obj) {
        [self wxm_showAlertController];
        return;
    }
    
    if (self.callback)  {
        self.signDictionary = self.callback(self.selectedIndex,obj.rank).mutableCopy;
        [self wxm_setUpTopView:self.selectedIndex];
        self.bottomBarView.signDictionary = self.signDictionary;
    }
}

/** 完成按钮 */
- (void)wxm_touchButtomFinsh {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    if (_previewType == WXMPhotoPreviewTypeSingle) {
        [self wxm_singlePhotoSendImage];
    } else if (_previewType == WXMPhotoPreviewTypeMost) {
        [self wxm_morePhotoSendImage];
    }
}

/** 翻页 */
- (void)wxm_setUpTopView:(NSInteger)location {
    NSString * indexString = @(location).stringValue;
    self.topBarView.signModel = [self.signDictionary objectForKey:indexString];
    self.bottomBarView.seletedIdx = location;
}

/** 回调单张图片 */
- (void)wxm_singlePhotoSendImage {
    WXMPhotoAsset *asset = self.dataSource[self.selectedIndex];
    WXMPhotoManager * man = [WXMPhotoManager sharedInstance];
    CGSize size = CGSizeZero;
    if (_photoType == WXMPhotoDetailTypeGetPhoto_256) size = CGSizeMake(256, 256);
    [man wxm_synchronousGetPictures:asset.asset size:size completion:^(UIImage *image) {
        SEL singleSEL = @selector(wxm_singlePhotoAlbumWithImage:);
        if (self.results) self.results(image);
        if (self.delegate && [self.delegate respondsToSelector:singleSEL]) {
            [self.delegate wxm_singlePhotoAlbumWithImage:image];
        }
    }];
}

/** 回调多张图片 */
- (void)wxm_morePhotoSendImage {
    
}

#pragma mark 设置

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.lastStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    UIColor * whiteColor = [[UIColor whiteColor] colorWithAlphaComponent:0.0];
    UIImage * image = [WXMPhotoAssistant wxmPhoto_imageWithColor:whiteColor];
    [self.weakNavigationVC.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
    self.topBarView.showLeftButton = NO;
    [UIApplication sharedApplication].statusBarStyle = self.lastStatusBarStyle;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.topBarView.showLeftButton = YES;
    dispatch_queue_t queue = dispatch_get_main_queue();
    [UIApplication sharedApplication].statusBarHidden = self.topBarView.hidden;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)),queue, ^{
        self.navigationController.navigationBar.userInteractionEnabled = NO;
    });
}

- (void)dealloc {
    UIColor * whiteColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0];
    UIImage * image = [WXMPhotoAssistant wxmPhoto_imageWithColor:whiteColor];
    [self.weakNavigationVC.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    [self.windowView removeFromSuperview];
    self.windowView = nil;
    NSLog(@"释放 %@",NSStringFromClass(self.class));
}

- (WXMPreviewTopBar *)topBarView {
    if (!_topBarView)  {
        _topBarView = [[WXMPreviewTopBar alloc] initWithFrame:CGRectZero];
        _topBarView.delegate = self;
        if (_previewType == WXMPhotoPreviewTypeSingle) _topBarView.showRightButton = NO;
    }
    return _topBarView;
}

- (WXMPreviewBottomBar *)bottomBarView {
    if (!_bottomBarView) {
        _bottomBarView = [[WXMPreviewBottomBar alloc] initWithFrame:CGRectZero];
        _bottomBarView.signDictionary = self.signDictionary;
        _bottomBarView.delegate = self;
    }
    return _bottomBarView;
}

- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(WXMPhoto_Width + WXMPhotoPreviewSpace, WXMPhoto_Height);
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        
        CGRect rect = CGRectMake(0, 0, WXMPhoto_Width + WXMPhotoPreviewSpace, WXMPhoto_Height);
        _collectionView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor blackColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.pagingEnabled = YES;
        _collectionView.bounces = YES;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.alwaysBounceVertical = NO;
        [_collectionView registerClass:[WXMPhotoPreviewCell class] forCellWithReuseIdentifier:@"cell"];
        [_collectionView registerClass:[WXMPhotoVideoCell class] forCellWithReuseIdentifier:@"aCell"];
    }
    return _collectionView;
}

/** 提示框 */
- (void)wxm_showAlertController {
    NSString *title = [NSString stringWithFormat:@"您最多可以选择%d张图片",WXMMultiSelectMax];
    [WXMPhotoAssistant showAlertViewControllerWithTitle:title message:@"" cancel:@"知道了"
                                            otherAction:nil completeBlock:nil];
}

- (UIScrollView *)transitionScrollerView {
    return self.transitionScrollView;
}

- (NSInteger)transitionIndex {
    return self.selectedIndex;
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC {
    if (operation == UINavigationControllerOperationPop) {
        return [WXMPhotoTransitions photoTransitionsWithType:WXMPhotoTransitionsTypePop];
    }
    return nil;
}
@end
