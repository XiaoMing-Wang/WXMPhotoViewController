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
    
    self.showToolbar = YES;
    self.weakNavigationVC = self.navigationController;
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1.0];
    if (self.wxm_windowView) [self.view addSubview:self.wxm_windowView];
    if (self.wxm_contentView) [self.view addSubview:self.wxm_contentView];
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

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WXMPhotoAsset *asset = self.dataSource[indexPath.row];
    UICollectionView *cv = collectionView;
    UICollectionViewCell * cell = nil;
    
    if (asset.mediaType == WXMPHAssetMediaTypeVideo && self.showVideo) {
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
    
    /** 设置原图大小 */
    [self wxm_setBottomBarViewrealByte];
}

/** 获取当前图片的data大小 */
- (void)wxm_setBottomBarViewrealByte {
    WXMPhotoAsset *asset = self.dataSource[self.selectedIndex];
    BOOL video = (asset.mediaType == WXMPHAssetMediaTypeVideo && self.showVideo);
    CGFloat bytes = asset.bytes;
    if (bytes < 20) {
        bytes = [WXMPhotoAssistant wxm_getOriginalSize:asset.asset];
        asset.bytes = bytes;
    }
    NSString * realByte = [NSString stringWithFormat:@"%.1fM", bytes / (1024 * 1024)];
    if (bytes / (1024 * 1024) < 0.1f) {
        realByte = [NSString stringWithFormat:@"%.0fk", (bytes / (1024))];
    }
    [self.bottomBarView setRealImageByte:realByte video:video];
}

#pragma mark _____________________________________________ cell回调代理

/** cell回调代理 */
- (void)wxm_respondsToTapSingle {
    self.showToolbar = !self.showToolbar;
    self.topBarView.hidden = self.bottomBarView.hidden = !self.showToolbar;
    [UIApplication sharedApplication].statusBarHidden = self.topBarView.hidden;
    if (self.topBarView.hidden == NO) self.topBarView.alpha = 1;
    if (self.bottomBarView.hidden == NO) self.bottomBarView.alpha = 1;
}

/** 手势滑动代理回调 */
- (void)wxm_respondsBeginDragCell {
    if (self.dragCallback) {
        self.wxm_contentView = self.dragCallback();
        self.wxm_contentView.maskView = self.maskBottomView;
        [self.view insertSubview:self.wxm_contentView aboveSubview:self.wxm_windowView];
    }
    
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
        [self.wxm_contentView removeFromSuperview];
    } else {
        self.transitionScrollView = jump;
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark 回调

/** 设置topview bottomBarView 属性 */
- (void)wxm_setUpTopView:(NSInteger)location {
    NSString * indexString = @(location).stringValue;
    self.topBarView.signModel = [self.signObj objectForKey:indexString];
    self.bottomBarView.seletedIdx = location;
}

/** 上工具栏回调 */
- (void)wxm_touchTopLeftItem {
    self.navigationController.delegate = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

/** 上工具栏回调 */
- (void)wxm_touchTopRightItem:(WXMPhotoSignModel *)obj {
    if (self.signObj.count >= WXMMultiSelectMax && !obj) {
        [self wxm_showAlertController];
        return;
    }
    
    /** 勾选回掉 */
    if (self.signCallback)  {
        self.signObj = self.signCallback(self.selectedIndex);
        [self wxm_setUpTopView:self.selectedIndex];
        [self.bottomBarView setSignObj:self.signObj removeIdx:obj.rank];
    }
}

/** 下工具栏回调 */
- (void)wxm_touchButtomDidSelectItem:(NSIndexPath *)idx {
    UICollectionViewScrollPosition position = UICollectionViewScrollPositionCenteredHorizontally;
    [self.collectionView scrollToItemAtIndexPath:idx atScrollPosition:position animated:NO];
    [self wxm_setUpTopView:idx.row];
    self.selectedIndex = idx.row;
    dispatch_async(dispatch_get_main_queue(), ^{
        CATransition *transition = [CATransition animation];
        transition.duration = 0.175;
        transition.type = kCATransitionFade;
        [self.collectionView.layer addAnimation:transition forKey:@"animations"];
    });
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

#pragma mark --------------------- 回调图片

/** 回调单张图片 */
- (void)wxm_singlePhotoSendImage {
    WXMPhotoAsset *asset = self.dataSource[self.selectedIndex];
    WXMPhotoManager * man = [WXMPhotoManager sharedInstance];
    CGSize size = CGSizeZero;
    if (!self.bottomBarView.isOriginalImage) {
        size = CGSizeMake(WXMPhoto_Width * 2, WXMPhoto_Width * 2 * asset.aspectRatio);
        if (!CGSizeEqualToSize(WXMDefaultSize, CGSizeZero)) size = WXMDefaultSize;
    }
    
    void (^resultBlocks)(UIImage*) = ^(UIImage * image) {
        SEL singleSEL = @selector(wxm_singlePhotoAlbumWithImage:);
        if (self.results) self.results(image);
        if (self.delegate && [self.delegate respondsToSelector:singleSEL]) {
            [self.delegate wxm_singlePhotoAlbumWithImage:image];
        }
    };
    
    /** 256 * 256 */
    if (_photoType == WXMPhotoDetailTypeGetPhoto_256) {
        size = CGSizeMake(256, 256);
        [man getPicturesByAsset:asset.asset synchronous:YES original:NO assetSize:size
                     resizeMode:PHImageRequestOptionsResizeModeExact
                   deliveryMode:PHImageRequestOptionsDeliveryModeHighQualityFormat
                     completion:^(UIImage *AssetImage) {
                         resultBlocks(AssetImage);
                     }];
    }
    
    /** 单选大图 */
    if (_photoType == WXMPhotoDetailTypeGetPhoto) {
        [man wxm_synchronousGetPictures:asset.asset size:size completion:^(UIImage *image) {
            resultBlocks(image);
        }];
    }
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
    [self.wxm_windowView removeFromSuperview];
    NSLog(@"释放 %@",NSStringFromClass(self.class));
}

- (WXMPreviewTopBar *)topBarView {
    if (!_topBarView)  {
        _topBarView = [[WXMPreviewTopBar alloc] initWithFrame:CGRectZero];
        _topBarView.delegate = self;
        if (_previewType == WXMPhotoPreviewTypeSingle) {
            _topBarView.showRightButton = NO;
        }
    }
    return _topBarView;
}

- (WXMPreviewBottomBar *)bottomBarView {
    if (!_bottomBarView) {
        _bottomBarView = [[WXMPreviewBottomBar alloc] initWithFrame:CGRectZero];
        [_bottomBarView setSignObj:self.signObj removeIdx:-1];
        _bottomBarView.delegate = self;
        if (self.isOriginalImage) [_bottomBarView setOriginalImage];
        if (_photoType == WXMPhotoDetailTypeGetPhoto_256) {
            _bottomBarView.showOriginalButton = NO;
        }
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

- (UIView *)maskBottomView {
    UIView * maskBottom = [UIView new];
    maskBottom.size = CGSizeMake(WXMPhoto_Width, WXMPhoto_Height - WXMPhoto_BarHeight);
    maskBottom.top = WXMPhoto_BarHeight;
    maskBottom.backgroundColor = [UIColor blackColor];
    return maskBottom;
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

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC {
    if (operation == UINavigationControllerOperationPop) {
        return [WXMPhotoTransitions photoTransitionsWithType:WXMPhotoTransitionsTypePop];
    }
    return nil;
}
@end
