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
#import "WXMPreviewTop.h"
#import "WXMPreviewBottom.h"
#import "WXMPhotoTransitions.h"


@interface WXMPhotoPreviewController ()<UICollectionViewDelegate, UICollectionViewDataSource,WXMPreviewCellProtocol,WXMPreviewToolbarProtocol,UINavigationControllerDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, weak) UINavigationController *weakNavigationVC;
@property (nonatomic, strong) UIScrollView *transitionScrollView;
@property (nonatomic, strong) WXMPreviewTop *topView;
@property (nonatomic, strong) WXMPreviewBottom *bottomView;

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
    [self.view addSubview:self.topView];
    [self.view addSubview:self.bottomView];
    
    /**  */
    if (_dataSource.count <= 1) self.collectionView.alwaysBounceHorizontal = YES;
    if (_dataSource.count <= _indexPath.row) return;
    self.selectedIndex = self.indexPath.row;
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
    UICollectionView *cv = collectionView;
    NSIndexPath *ip = indexPath;
    WXMPhotoPreviewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:ip];
    cell.delegate = self;
    cell.photoAsset = self.dataSource[indexPath.row];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView
  didEndDisplayingCell:(WXMPhotoPreviewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    [cell originalAppearance];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offY = scrollView.contentOffset.x;
    CGFloat index = offY / scrollView.frame.size.width;
    NSInteger location = self.selectedIndex;
    if (index >= self.selectedIndex + 0.5) location = self.selectedIndex + 1;
    else if (index <= self.selectedIndex - 0.5) location = self.selectedIndex - 1;
    else location = self.selectedIndex;
    [self setUpTopView:location];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat offY = scrollView.contentOffset.x;
    self.selectedIndex = offY / scrollView.frame.size.width;
    [self setUpTopView:self.selectedIndex];
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
    }
    return _collectionView;
}
#pragma mark _____________________________________________ cell回调代理

/** cell回调代理 */
- (void)wxm_respondsToTapSingle {
    self.showToolbar = !self.showToolbar;
    self.topView.hidden = self.bottomView.hidden = self.showToolbar;
    [UIApplication sharedApplication].statusBarHidden = self.topView.hidden;
    if (self.topView.hidden == NO) self.topView.alpha = 1;
    if (self.bottomView.hidden == NO) self.bottomView.alpha = 1;
}
/**  */
- (void)wxm_respondsBeginDragCell {
    self.collectionView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    [self.topView setAccordingState:NO];
    [self.bottomView setAccordingState:NO];
    [UIApplication sharedApplication].statusBarStyle = self.lastStatusBarStyle;
    self.collectionView.scrollEnabled = NO;
}
- (void)wxm_respondsEndDragCell:(UIScrollView *)jump {
    if (jump == nil) {
        self.collectionView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1];
        [self.topView setAccordingState:YES];
        [self.bottomView setAccordingState:YES];
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        self.collectionView.scrollEnabled = YES;
        [UIApplication sharedApplication].statusBarHidden = NO;
    } else {
        self.transitionScrollView = jump;
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}
/** 工具栏回调 */
- (void)wxm_touchTopLeftItem {
    self.navigationController.delegate = nil;
    [self.navigationController popViewControllerAnimated:YES];
}
/** 完成按钮 */
- (void)wxm_touchButtomFinsh {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (void)wxm_touchTopRightItem:(WXMPhotoSignModel *)obj {
    if (self.signDictionary.allKeys.count >= WXMMultiSelectMax && !obj) {
        [self showAlertController];
        return;
    }
    
    if (self.callback)  {
        self.signDictionary = self.callback(self.selectedIndex,obj.rank).mutableCopy;
        [self setUpTopView:self.selectedIndex];
        self.bottomView.signDictionary = self.signDictionary;
    }
}
/** */
- (void)setUpTopView:(NSInteger)location {
    NSString * indexString = @(location).stringValue;
    self.topView.signModel = [self.signDictionary objectForKey:indexString];
    self.bottomView.seletedIdx = location;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.lastStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    UIColor * whiteColor = [[UIColor whiteColor] colorWithAlphaComponent:0.0];
    UIImage * image = [WXMPhotoAssistant wxmPhoto_imageWithColor:whiteColor];
    [self.weakNavigationVC.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    UIColor * whiteColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0];
    UIImage * image = [WXMPhotoAssistant wxmPhoto_imageWithColor:whiteColor];
    [self.weakNavigationVC.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
    self.topView.showLeft = NO;
    [UIApplication sharedApplication].statusBarStyle = self.lastStatusBarStyle;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.topView.showLeft = YES;
    dispatch_queue_t queue = dispatch_get_main_queue();
    [UIApplication sharedApplication].statusBarHidden = self.topView.hidden;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)),queue, ^{
        self.navigationController.navigationBar.userInteractionEnabled = NO;
    });
}
- (WXMPreviewTop *)topView {
    if (!_topView)  {
        _topView = [[WXMPreviewTop alloc] initWithFrame:CGRectZero];
        _topView.delegate = self;
    }
    return _topView;
}
- (WXMPreviewBottom *)bottomView {
    if (!_bottomView) {
        _bottomView = [[WXMPreviewBottom alloc] initWithFrame:CGRectZero];
        _bottomView.signDictionary = self.signDictionary;
        _bottomView.delegate = self;
    }
    return _bottomView;
}

/** 提示框 */
- (void)showAlertController {
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
