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
#import "WXMResourceAssistant.h"

@interface WXMPhotoPreviewController () <UICollectionViewDelegate,UICollectionViewDataSource,
WXMPreviewCellProtocol, WXMPreviewToolbarProtocol, UINavigationControllerDelegate>

@property (nonatomic, weak) UINavigationController *weakNavigationVC;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIScrollView *transitionScrollView;
@property (nonatomic, strong) WXMPreviewTopBar *topBarView;
@property (nonatomic, strong) WXMPreviewBottomBar *bottomBarView;

@property (nonatomic, assign) UIStatusBarStyle lastStatusBarStyle;
@property (nonatomic, assign) BOOL statusBarHidden;
@property (nonatomic, assign) BOOL showToolbar;
@property (nonatomic, assign) NSInteger selectedIndex;
@end

@implementation WXMPhotoPreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.delegate = self;
    self.navigationController.navigationBar.translucent = YES;
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1.0];
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem new];
    
    self.showToolbar = YES;
    self.weakNavigationVC = self.navigationController;
    if (self.wp_windowView) [self.view addSubview:self.wp_windowView];
    if (self.wp_contentView) [self.view addSubview:self.wp_contentView];
    
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    UIColor *whiteColor = [[UIColor whiteColor] colorWithAlphaComponent:0.0];
    UIImage *image = [WXMPhotoAssistant wxmPhoto_imageWithColor:whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:0];
    
    @try {
        UIViewController * firstVC = self.navigationController.viewControllers.firstObject;
        self.navigationController.interactivePopGestureRecognizer.delegate = (id)firstVC;
        UIGestureRecognizer * ges = self.navigationController.interactivePopGestureRecognizer;
        [ges requireGestureRecognizerToFail:_collectionView.panGestureRecognizer];
    } @catch (NSException *exception) {} @finally {};
    
    /** 导航栏 */
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.topBarView];
    [self.view addSubview:self.bottomBarView];
    
    /** 滚动到选中行 */
    if (_dataSource.count <= 1) self.collectionView.alwaysBounceHorizontal = YES;
    if (_dataSource.count <= _indexPath.row) return;
    self.selectedIndex = self.indexPath.row;
    NSIndexPath * index = [NSIndexPath indexPathForRow:self.indexPath.row inSection:0];
    UICollectionViewScrollPosition posi = UICollectionViewScrollPositionCenteredHorizontally;
    [self.collectionView scrollToItemAtIndexPath:index atScrollPosition:posi animated:NO];
    
    dispatch_time_t time_t = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.08 * NSEC_PER_SEC));
    dispatch_after(time_t, dispatch_get_main_queue() , ^{
        
        /** 播放livePhoto */
        [self playLivePhotoOrVideo];
        
        /** 计算原图大小 */
        [self wp_setBottomBarViewrealByte];
    });
    
}

#pragma mark UICollectionView dataSource
#pragma mark UICollectionView dataSource
#pragma mark UICollectionView dataSource

- (NSInteger)collectionView:(UICollectionView *)collection numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WXMPhotoAsset *asset = self.dataSource[indexPath.row];
    UICollectionView *collection = collectionView;
    UICollectionViewCell * cell = nil;
    if (asset.mediaType == WXMPHAssetMediaTypeVideo && self.showVideo) {
        cell = [collection dequeueReusableCellWithReuseIdentifier:@"aCell" forIndexPath:indexPath];
        ((WXMPhotoVideoCell *)cell).delegate = self;
        ((WXMPhotoVideoCell *)cell).photoAsset = asset;
    } else {
        cell = [collection dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
        ((WXMPhotoPreviewCell *)cell).delegate = self;
        ((WXMPhotoPreviewCell *)cell).photoAsset = asset;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView
  didEndDisplayingCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(originalAppearance)]) {
        [cell performSelector:@selector(originalAppearance)];
    }
}

#pragma mark  滑动计算
#pragma mark  滑动计算
#pragma mark  滑动计算

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offY = scrollView.contentOffset.x;
    CGFloat index = offY / scrollView.frame.size.width;
    NSInteger location = self.selectedIndex;
    if (index >= self.selectedIndex + 0.5) location = self.selectedIndex + 1;
    else if (index <= self.selectedIndex - 0.5) location = self.selectedIndex - 1;
    else location = self.selectedIndex;
    
    /** 设置topView bottomView显示 */
    [self wp_setUpTopView:location];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat offY = scrollView.contentOffset.x;
    self.selectedIndex = offY / scrollView.width;

    /** 设置topView bottomView显示 */
    [self wp_setUpTopView:self.selectedIndex];

    /** 设置原图大小 */
    [self wp_setBottomBarViewrealByte];
    
    if (self.dataSource.count < self.selectedIndex) return;
    
    /** 播放livePhoto */
    [self playLivePhotoOrVideo];
}

/** 播放livephoto */
- (void)playLivePhotoOrVideo {
    if (self.dataSource.count < self.selectedIndex) return;
    NSIndexPath *index = [NSIndexPath indexPathForRow:self.selectedIndex inSection:0];
    UITableViewCell * cell = nil;
    cell = (UITableViewCell *) [self.collectionView cellForItemAtIndexPath:index];
    if ([cell isKindOfClass:WXMPhotoPreviewCell.class] && WXMPhotoShowLivePhto) {
        [((WXMPhotoPreviewCell *)cell) startPlayLivePhoto];
    } else if ([cell isKindOfClass:WXMPhotoVideoCell.class] && WXMPhotoAutomaticVideo) {
        [((WXMPhotoVideoCell *)cell) wp_avPlayStartPlay:YES];
        [self wp_respondsToTapSingle:YES];
    }
}

/** 获取当前图片的和视频的data大小 */
- (void)wp_setBottomBarViewrealByte {
    if (WXMPhotoSelectOriginal) {
        WXMPhotoAsset *asset = self.dataSource[self.selectedIndex];
        BOOL video = (asset.mediaType == WXMPHAssetMediaTypeVideo && self.showVideo);
        CGFloat bytes = asset.bytes;
        if (bytes < 20 && !(asset.mediaType == WXMPHAssetMediaTypeVideo && !self.showVideo)) {
            bytes = [WXMPhotoAssistant wp_getOriginalSize:asset.asset];
            asset.bytes = bytes;
        }
        
        /** 资源是视频时不显示视频 */
        if(asset.mediaType == WXMPHAssetMediaTypeVideo && !self.showVideo && bytes < 20) {
            NSIndexPath *index = [NSIndexPath indexPathForRow:self.selectedIndex inSection:0];
            UITableViewCell * cell = nil;
            cell = (UITableViewCell *) [self.collectionView cellForItemAtIndexPath:index];
            if ([cell isKindOfClass:WXMPhotoPreviewCell.class]) {
                UIImage *image = ((WXMPhotoPreviewCell *) cell).currentImage;
                NSData *data = UIImageJPEGRepresentation(image, 0.75);
                bytes = data.length;
                asset.bytes = data.length;
            }
        }
        
        NSString * realByte = [NSString stringWithFormat:@"%.1fM", bytes / (1024 * 1024)];
        if (bytes / (1024 * 1024) < 0.1f) {
            realByte = [NSString stringWithFormat:@"%.0fk", (bytes / (1024))];
        }
        [self.bottomBarView setRealImageByte:realByte video:video];
    }
}

#pragma mark  cell回调代理
#pragma mark  cell回调代理
#pragma mark  cell回调代理

/** cell回调代理 单击回调 */
- (void)wp_respondsToTapSingle:(BOOL)plays {
    if (plays && !self.showToolbar) return;
    self.showToolbar = !self.showToolbar;
    self.topBarView.hidden = self.bottomBarView.hidden = !self.showToolbar;
    if (self.topBarView.hidden == NO) self.topBarView.alpha = 1;
    if (self.bottomBarView.hidden == NO) self.bottomBarView.alpha = 1;
}

/** 手势滑动代理回调 开始 */
- (void)wp_respondsBeginDragCell {
    if ([self.refreshDelegate respondsToSelector:@selector(wp_getScreenshotsPhotoDetailViewController)]) {
        self.wp_contentView = [self.refreshDelegate wp_getScreenshotsPhotoDetailViewController];
        self.wp_contentView.maskView = self.maskBottomView;
        [self.view insertSubview:self.wp_contentView aboveSubview:self.wp_windowView];
    }
    
    self.collectionView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    [self.topBarView setAccordingState:NO];
    [self.bottomBarView setAccordingState:NO];
    [UIApplication sharedApplication].statusBarStyle = self.lastStatusBarStyle;
    self.collectionView.scrollEnabled = NO;
}

/** 手势滑动代理回调 结束 */
- (void)wp_respondsEndDragCell:(UIScrollView *)jump {
    if (jump == nil) {
        self.collectionView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1];
        if (self.showToolbar) [self.topBarView setAccordingState:YES];
        if (self.showToolbar) [self.bottomBarView setAccordingState:YES];
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        self.collectionView.scrollEnabled = YES;
        [self.wp_contentView removeFromSuperview];
    } else {
        self.transitionScrollView = jump;
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark 设置topview bottomBarView 属性
#pragma mark 设置topview bottomBarView 属性
#pragma mark 设置topview bottomBarView 属性

/** 设置topview bottomBarView 属性 */
- (void)wp_setUpTopView:(NSInteger)location {
    WXMPhotoAsset *asset = self.dataSource[location];
    WXMPhotoRecordModel *recordModel = [self.dictionaryArray objectForKey:asset.asset.localIdentifier];
    self.topBarView.recordModel = recordModel;
    self.bottomBarView.recordModel = recordModel;
    
    /** 视频不显示右按钮 */
    self.topBarView.showRightButton = YES;
    if (self.realSelectVideo == 1 && asset.mediaType == WXMPHAssetMediaTypeVideo) {
        self.topBarView.showRightButton = NO;
    }
  
    /** 不支持同时选视频图片修改显示文字 */
    if (self.chooseVideoWithPhoto == NO) {
        WXMPhotoAsset *asset = self.dataSource[location];
        [self.topBarView setChooseType:self.chooseType asset:asset];
    }
}

#pragma mark  ---------------------------- 上工具栏回调
#pragma mark  ---------------------------- 上工具栏回调
#pragma mark  ---------------------------- 上工具栏回调

/** 上工具栏回调 左按钮 */
- (void)wp_touchTopLeftItem {
    self.navigationController.delegate = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

/** 上工具栏回调 右按钮 */
- (void)wp_touchTopRightItem:(WXMPhotoRecordModel *)recordModel {
    
    /** 新增一个 */
    if (recordModel == nil) {
        if (self.dictionaryArray.count >= self.realSelectCount) {
            NSLog(@"%@",@"xxxxxxxxxxxx");
            return;
        }
        
        [self addPhotoRecordModel];
        [self.bottomBarView addPhotoRecordModel:self.dictionaryArray];
        [self wp_setUpTopView:self.selectedIndex];
                           
    } else {

        /** 删除后重新排名 */
        [self refreshRanking:recordModel.recordAsset.asset.localIdentifier];
        [self.dictionaryArray removeObjectForKey:recordModel.recordAsset.asset.localIdentifier];
        [self.bottomBarView deletePhotoRecordModel:self.dictionaryArray];
        [self wp_setUpTopView:self.selectedIndex];
    }
    
    /** 同步数据 */
    if ([self.refreshDelegate respondsToSelector:@selector(wp_reloadPhotoDetailViewController)]) {
        [self.refreshDelegate wp_reloadPhotoDetailViewController];
    }
}

/** 添加一个WXMPhotoRecordModel */
- (void)addPhotoRecordModel {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.selectedIndex inSection:0];
    WXMPhotoAsset *asset = self.dataSource[self.selectedIndex];
    WXMPhotoRecordModel *recordModel = [WXMPhotoRecordModel new];
    recordModel.recordAsset = asset;
    recordModel.recordRank = (self.dictionaryArray.count + 1);
    recordModel.recordIndexPath = indexPath;
    recordModel.mediaType = asset.mediaType;
    [self.dictionaryArray setObject:recordModel forKey:asset.asset.localIdentifier];
}


/** 重新刷新排名 */
- (void)refreshRanking:(NSString *)localIdentifier {
    WXMPhotoRecordModel *delete = [self.dictionaryArray objectForKey:localIdentifier];
    if (!delete) return;
    for (WXMPhotoRecordModel *recordModel in self.dictionaryArray.allValues) {
        if (delete == recordModel) continue;
        if (recordModel.recordRank > delete.recordRank) {
            recordModel.recordRank = MAX(recordModel.recordRank - 1, 1);
        }
    }
}


/** 下工具栏回调 */
- (void)wp_touchButtomDidSelectItem:(NSIndexPath *)idexPath {
    UICollectionViewScrollPosition position = UICollectionViewScrollPositionCenteredHorizontally;
    [self.collectionView scrollToItemAtIndexPath:idexPath atScrollPosition:position animated:NO];
    [self wp_setUpTopView:idexPath.row];
    self.selectedIndex = idexPath.row;
    dispatch_async(dispatch_get_main_queue(), ^{
        CATransition *transition = [CATransition animation];
        transition.duration = 0.175;
        transition.type = kCATransitionFade;
        [self.collectionView.layer addAnimation:transition forKey:@"animations"];
        [self wp_setBottomBarViewrealByte];
    });
}

/** 完成按钮 */
- (void)wp_touchButtomFinsh {
    if (_previewType == WXMPhotoPreviewTypeSingle) {
        [self wp_singlePhotoSendImage];
    } else if (_previewType == WXMPhotoPreviewTypeMost) {
        [self wp_morePhotoSendImage];
    }
}

#pragma mark  回调图片
#pragma mark  回调图片
#pragma mark  回调图片

/** 回调单张图片 */
- (void)wp_singlePhotoSendImage {
    WXMPhotoAsset *asset = self.dataSource[self.selectedIndex];
    if (self.photoType == WXMPhotoDetailTypeGetPhoto_256 ||
        self.photoType == WXMPhotoDetailTypeGetPhoto ||
        self.photoType == WXMPhotoDetailTypeGetPhotoCustomSize) {
        CGSize size = CGSizeZero;
        if (self.photoType == WXMPhotoDetailTypeGetPhoto) size = PHImageManagerMaximumSize;
        if (self.photoType == WXMPhotoDetailTypeGetPhoto_256) size = CGSizeMake(256, 256);
        /** if (self.photoType == WXMPhotoDetailTypeGetPhotoCustomSize) size = self.expectSize; */
        if (self.bottomBarView.isOriginalImage == YES) size = PHImageManagerMaximumSize;
        [WXMResourceAssistant sendResource:asset
                                 coverSize:size
                                  delegate:self.delegate
                               isShowVideo:self.showVideo
                                isShowLoad:(self.photoType == WXMPhotoDetailTypeGetPhoto)
                            viewController:self.navigationController];
    }
}

/** 回调多张图片 */
- (void)wp_morePhotoSendImage {
    
    if (self.dictionaryArray.count == 0) [self addPhotoRecordModel];
    
    NSMutableArray * array = @[].mutableCopy;
    [self.dictionaryArray enumerateObjectsUsingBlock:^(WXMPhotoRecordModel*obj,NSUInteger idx,BOOL stop) {
        if (obj.recordAsset) [array addObject:obj.recordAsset];
    }];
    [WXMResourceAssistant sendMoreResource:array
                                  delegate:self.delegate
                               isShowVideo:self.showVideo
                                isShowLoad:YES
                            viewController:self.navigationController];
}

/** 用户第一张选择的类型 */
- (WXMPhotoMediaType)chooseType {
    if (self.dictionaryArray.count == 0) return WXMPHAssetMediaTypeNone;
    WXMPhotoRecordModel *recordModel = self.dictionaryArray.firstObject;
    if (recordModel.mediaType == WXMPHAssetMediaTypeVideo) return WXMPHAssetMediaTypeVideo;
    return WXMPHAssetMediaTypeImage;
}

#pragma mark 设置
#pragma mark 设置
#pragma mark 设置

/** 导航栏 */
- (WXMPreviewTopBar *)topBarView {
    if (!_topBarView)  {
        _topBarView = [[WXMPreviewTopBar alloc] initWithFrame:CGRectZero];
        _topBarView.delegate = self;
        
        /** 单选 */
        if (_previewType == WXMPhotoPreviewTypeSingle) _topBarView.showRightButton = NO;
    }
    return _topBarView;
}

/** 工具栏 */
- (WXMPreviewBottomBar *)bottomBarView {
    if (!_bottomBarView) {
        _bottomBarView = [[WXMPreviewBottomBar alloc] initWithFrame:CGRectZero];
        _bottomBarView.delegate = self;
        [_bottomBarView loadDictionaryArray:self.dictionaryArray];
        if (_isOriginalImage) [_bottomBarView setOriginalImage];
        if (_photoType == WXMPhotoDetailTypeGetPhoto_256 ||
            _photoType == WXMPhotoDetailTypeGetPhoto) {
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

#pragma mark 动画用
#pragma mark 动画用
#pragma mark 动画用

- (UIView *)maskBottomView {
    UIView * maskBottom = [UIView new];
    maskBottom.size = CGSizeMake(WXMPhoto_Width, WXMPhoto_Height - WXMPhoto_BarHeight);
    maskBottom.top = WXMPhoto_BarHeight;
    maskBottom.backgroundColor = [UIColor blackColor];
    return maskBottom;
}

- (UIScrollView *)transitionScrollerView {
    return self.transitionScrollView;
}

- (NSInteger)transitionIndex {
    return self.selectedIndex;
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *) navigation animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    if (operation == UINavigationControllerOperationPop) {
        return [WXMPhotoTransitions photoTransitionsWithType:WXMPhotoTransitionsTypePop];
    }
    return nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.topBarView.showLeftButton = NO;
    [UIApplication sharedApplication].statusBarStyle = self.lastStatusBarStyle;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.topBarView.showLeftButton = YES;
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)),queue, ^{
        self.navigationController.navigationBar.userInteractionEnabled = NO;
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.lastStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    UIColor * whiteColor = [[UIColor whiteColor] colorWithAlphaComponent:0.0];
    UIImage * image = [WXMPhotoAssistant wxmPhoto_imageWithColor:whiteColor];
    UIBarMetrics metr = UIBarMetricsDefault;
    [self.weakNavigationVC.navigationBar setBackgroundImage:image forBarMetrics:metr];
}

- (void)dealloc {
    UIColor *whiteColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0];
    UIImage *image = [WXMPhotoAssistant wxmPhoto_imageWithColor:whiteColor];
    UIBarMetrics metr = UIBarMetricsDefault;
    [self.weakNavigationVC.navigationBar setBackgroundImage:image forBarMetrics:metr];
    [self.wp_windowView removeFromSuperview];
    NSLog(@"释放 %@",NSStringFromClass(self.class));
}

@end
