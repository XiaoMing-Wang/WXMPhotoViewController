//
//  WXMPhotoDetailViewController.m
//  ModuleDebugging
//
//  Created by edz on 2019/5/6.
//  Copyright © 2019年 wq. All rights reserved.
//
#import <objc/runtime.h>
#import "WXMPhotoManager.h"
#import "WXMPhotoListCell.h"
#import "WXMDictionary_Array.h"
#import "WXMPhotoRecordModel.h"
#import "WXMResourceAssistant.h"
#import "WXMPhotoConfiguration.h"
#import "WXMPhotoDetailToolbar.h"
#import "WXMPhotoDetailTitleBar.h"
#import "WXMPhotoCollectionCell.h"
#import "WXMPhotoViewController.h"
#import "WXMPhotoShapeController.h"
#import "WXMPhotoPreviewController.h"
#import "WXMPhotoDetailViewController.h"

@interface WXMPhotoDetailViewController () <UICollectionViewDelegate, WXMDetailTitleBarProtocol, UICollectionViewDataSource, WXMDetailToolbarProtocol, WXMPhotoCollectionCellDelegate, WXMPhotoPreviewRefreshDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

/** 下部分工具栏 */
@property (nonatomic, strong) WXMPhotoDetailToolbar *toolbar;

/** 选择相册栏 */
@property (nonatomic, strong) WXMPhotoDetailTitleBar *titleBar;

/** 选择相册控制器 */
@property (nonatomic, strong) WXMPhotoViewController *listController;

/** 当前选中类型 */
@property (nonatomic, assign) WXMPhotoMediaType chooseType;

/** 数据源 */
@property (nonatomic, strong) WXMPhotoList *phoneList;
@property (nonatomic, strong) NSMutableArray *dataSource;

/** 存储被标记的图片model <WXMPhotoRecordModel *> */
@property (nonatomic, strong) WXMDictionary_Array *dictionaryArray;

/** 识别gif */
@property (nonatomic, assign) BOOL allowRecogGIF;

@end

@implementation WXMPhotoDetailViewController

/** 默认设置 */
- (instancetype)init {
    if (self = [super init]) {
        _exitPreview = YES;
        _showVideo = YES;
        _canSelectedVideo = YES;
        _needUnpack = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.titleView = self.titleBar;
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    UIImage *imageN = [WXMPhotoUIAssistant photoImageWithColor:WXMBarColor];
    [self.navigationController.navigationBar setBackgroundImage:imageN forBarMetrics:0];
    
    self.view.clipsToBounds = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collectionView];
    
    /** 选择相册控制器 */
    [self.view addSubview:self.listController.view];
    if (WXMPhotoShowDetailToolbar && (self.photoType == WXMPhotoDetailTypeMultiSelect || self.photoType == WXMPhotoDetailTypeHybrid)) {
        [self.view insertSubview:self.toolbar belowSubview:self.listController.view];
        self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, self.toolbar.height - WXMPhoto_SafeHeight + 5, 0);
    } else {
        self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    
    /** 进来加载最近项目相册 */
    self.navigationItem.leftBarButtonItem = [WXMPhotoUIAssistant createButtonItem:@"取消" target:self action:@selector(dismissViewController)];
    [[WXMPhotoManager sharedInstance] getAllPicturesListBlock:^(NSArray<WXMPhotoList *> *allList) {
        [self getPreviewAlbumWithPhotoList:WXMPhotoManager.sharedInstance.firstPhotoList];
    }];
}

/**< 获取两倍像素的图片 */
- (void)getPreviewAlbumWithPhotoList:(WXMPhotoList *)photoList {
    if ([photoList.title isEqualToString:self.phoneList.title] && self.phoneList) return;
       
    self.dataSource = @[].mutableCopy;
    self.phoneList = photoList;
    self.titleBar.title = photoList.title;
    self.toolbar.albumName = self.titleBar.title;
    self.toolbar.dictionaryArray = self.dictionaryArray;
    
    PHAssetCollection *asset = self.phoneList.assetCollection;
    NSArray <PHAsset *>*phAssets = [[WXMPhotoManager sharedInstance] getAssetsInAssetCollection:asset ascending:YES];
    [phAssets enumerateObjectsUsingBlock:^(PHAsset *obj, NSUInteger idx, BOOL *stop) {
        WXMPhotoAsset *asset = [WXMPhotoAsset new];
        asset.asset = obj;
        [self.dataSource addObject:asset];
    }];
        
    /** 滚动到最后 */
    [self.collectionView setContentOffsetY:0];
    [self.collectionView reloadData];
    if (self.dataSource.count <= 1) return;
    UICollectionViewScrollPosition position = UICollectionViewScrollPositionCenteredVertically;
    NSIndexPath *index = [NSIndexPath indexPathForRow:self.dataSource.count - 1 inSection:0];
    [self.collectionView scrollToItemAtIndexPath:index atScrollPosition:position animated:NO];
}


#pragma mark  UICollectionView
- (NSInteger)collectionView:(UICollectionView *)collection numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WXMPhotoCollectionCell *cell = cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    WXMPhotoAsset *photoAsset = [self.dataSource objectAtIndex:indexPath.row];
    cell.photoAsset = photoAsset;
    
    /**< 是否显示勾选框 */
    cell.displayCheckBox = [self displayCheckBox:photoAsset];
    
    /**< 是否显示视频 NO会显示为视频第一帧 */
    cell.showVideo = self.showVideo;
    
    /**< 是否可以被点击 否显示白屏 */
    [cell setUserCanTouch:[self judgeCellCanTouch:cell] animation:NO];
    
    /**< 多选代理 */
    if (self.photoType == WXMPhotoDetailTypeMultiSelect || self.photoType == WXMPhotoDetailTypeHybrid || self.photoType == WXMPhotoDetailTypeSingleType) {
        
        /**< 设置代理 */
        NSString *localIdentifier = photoAsset.asset.localIdentifier;
        WXMPhotoRecordModel *recordModel = [self.dictionaryArray objectForKey:localIdentifier];;
        recordModel.recordIndexPath = indexPath;
        cell.delegate = self;
        cell.recordModel = recordModel;
        
    } else {
        
        /**< 不是多选和混合不显示gif和视频长度 */
        [cell hideSign];
    }

    return cell;
}

/** 点击事件 */
- (void)collectionView:(UICollectionView *)collection didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    WXMPhotoAsset *phsset = self.dataSource[indexPath.row];
    WXMPhotoCollectionCell *cell = nil;
    cell = (WXMPhotoCollectionCell *) [collection cellForItemAtIndexPath:indexPath];
    CGSize size = CGSizeZero;

    /** 单选原图 + 单选256 + 单选自定义大小 */
    if (_photoType == WXMPhotoDetailTypeGetPhoto ||
        _photoType == WXMPhotoDetailTypeGetPhoto_256 ||
        _photoType == WXMPhotoDetailTypeGetPhotoCustomSize) {
        
        if (self.exitPreview) {
            
            size = CGSizeMake(WXMPhoto_Width * 2, WXMPhoto_Width * phsset.aspectRatio * 2);
            if (size.height * 4 < WXMPhoto_Height) size = PHImageManagerMaximumSize;
            
        } else if (_photoType == WXMPhotoDetailTypeGetPhoto_256 && !self.exitPreview) {
            
            size = CGSizeMake(256, 256);
            
        } else if (_photoType == WXMPhotoDetailTypeGetPhoto && !self.exitPreview) {
            
            size = PHImageManagerMaximumSize;
        }
        
        [self getImagePreview:phsset size:size callback:^(UIImage *image) {
            if (self.exitPreview) {
                phsset.cacheImage = image;
                WXMPhotoPreviewController *preview = [self getPreviewController:indexPath];
                preview.previewType = WXMPhotoPreviewTypeSingle;
                [self.navigationController pushViewController:preview animated:YES];
            } else {
                [self sendImageWithPhotoAsset:phsset coverImage:image];
            }
        }];
    }

    /** 先同步获取大图 否则跳界面会闪 */
    if (_photoType == WXMPhotoDetailTypeMultiSelect || _photoType == WXMPhotoDetailTypeHybrid || _photoType == WXMPhotoDetailTypeSingleType) {
        size = CGSizeMake(WXMPhoto_Width * 2.0, WXMPhoto_Width * phsset.aspectRatio * 2.0);
        [self getImagePreview:phsset size:size callback:^(UIImage *image) {
            phsset.cacheImage = image;
            WXMPhotoPreviewController *preview = [self getPreviewController:indexPath];
            preview.previewType = WXMPhotoPreviewTypeMost;
            [self.navigationController pushViewController:preview animated:YES];
        }];
    }

    /** 裁剪框 */
    if (_photoType == WXMPhotoDetailTypeTailoring) {
        CGFloat width = (WXMPhoto_Width - WXMPhotoCropBoxMargin * 2);
        CGFloat height = width * phsset.aspectRatio;
        if (phsset.aspectRatio < 1.0) {
            height = width;
            width = height / phsset.aspectRatio * 1.0;
        }

        size = CGSizeMake(width * 3, height * 3);
        if (WXMPhotoCropUseOriginal) size = PHImageManagerMaximumSize;
        [self getImagePreview:phsset size:size callback:^(UIImage *image) {
            WXMPhotoShapeController *shape = [WXMPhotoShapeController new];
            shape.delegate = self.delegate;
            shape.shapeImage = image;
            shape.expectSize = self.expectSize;
            [self.navigationController pushViewController:shape animated:YES];
        }];
    }
}

/** 获取预览图片 */
- (void)getImagePreview:(WXMPhotoAsset *)asset size:(CGSize)size callback:(void(^)(UIImage *))callback {
    [[WXMPhotoManager sharedInstance] synchronousGetPictures:asset.asset size:size completion:callback];
}

/** 预览控制器 */
- (WXMPhotoPreviewController *)getPreviewController:(NSIndexPath *)index {
    WXMPhotoPreviewController * preview = [WXMPhotoPreviewController new];
    preview.dataSource = self.dataSource;
    preview.photoType = self.photoType;
    preview.delegate = self.delegate;
    preview.indexPath = index;
    preview.refreshDelegate = self;
    preview.dictionaryArray = self.dictionaryArray;
    preview.showVideo = self.showVideo;
    preview.isOriginalImage = self.toolbar.isOriginalImage;
    preview.realSelectCount = [self realSelectCount];
    preview.realSelectVideo = [self maxSelectVideoCount];
    preview.recordAlbumName = self.titleBar.title;
    UIView * snapView = self.navigationController.view;
    preview.wp_windowView = [WXMPhotoUIAssistant photoSnapViewImage:snapView];
    return preview;
}

#pragma mark -----------------------WXMPhotoPreviewController deleagte

/** 刷新相册详情界面 不能用reload */
- (void)wp_reloadPhotoDetailViewController {
    [self reloadAllAvailableCell];
    self.toolbar.dictionaryArray = self.dictionaryArray;
}

/** 获取截图 */
- (UIView *)wp_getScreenshotsPhotoDetailViewController {
    return [WXMPhotoUIAssistant photoSnapViewImage:self.view];
}

/** 刷新所有显示的cell */
- (void)reloadAllAvailableCell {
    [self.toolbar setOriginalEnabled:YES];
    if (self.chooseType == WXMPHAssetMediaTypeVideo && !self.chooseVideoWithPhoto) {
        [self.toolbar setOriginalEnabled:NO];
    }

    /** visibleCells collectionView新的刷新机制会生成新的cell导致不能刷新 */
    NSArray *arrays = self.collectionView.subviews;
    [arrays enumerateObjectsUsingBlock:^(UIView *subView, NSUInteger idx, BOOL *stop){
        if ([subView isKindOfClass:[WXMPhotoCollectionCell class]]) {
            WXMPhotoCollectionCell *cell = (WXMPhotoCollectionCell *)subView;
            NSString *localIdentifier = cell.photoAsset.asset.localIdentifier;
            [cell setUserCanTouch:[self judgeCellCanTouch:cell] animation:YES];
            cell.recordModel = [self.dictionaryArray objectForKey:localIdentifier];
        }
    }];
}

#pragma mark --------- WXMPhotoDetailToolbar 点击toobar回调
#pragma mark --------- WXMPhotoDetailToolbar 点击toobar回调
#pragma mark --------- WXMPhotoDetailToolbar 点击toobar回调

/** 预览按钮 */
- (void)wp_touchPreviewControl {
    WXMPhotoRecordModel *recordModel = self.dictionaryArray.lastObject;
    [self collectionView:_collectionView didSelectItemAtIndexPath:recordModel.recordIndexPath];
}

/** 回调 */
- (void)wp_touchDismissViewController {
    NSMutableArray *array = @[].mutableCopy;
    [_dictionaryArray enumerateObjectsUsingBlock:^(WXMPhotoRecordModel *obj, NSUInteger idx, BOOL stop) {
        if (obj.recordAsset) [array addObject:obj.recordAsset];
    }];
    
    [WXMResourceAssistant sendMoreResource:array
                                  delegate:self.delegate
                               isShowVideo:self.showVideo
                                isShowLoad:YES
                            viewController:self.navigationController];
}

#pragma mark -----------------------------------  点击标题

/** 展示标题控制器 */
- (void)wp_touchTitleBarWithUnfold:(BOOL)display {
    if (display) {
        [self.listController showPhotoListController];
    } else {
        [self.titleBar reductionArrowView];
        [self.listController hiddenPhotoListController];
    }
}

/** 选中相册 */
- (void)wp_changePhotoList:(WXMPhotoList *)photoList {
    [self.titleBar reductionArrowView];
    [self getPreviewAlbumWithPhotoList:photoList];
}

#pragma mark ----------------------------------- 回调资源

/** 发送资源 */
- (void)sendImageWithPhotoAsset:(WXMPhotoAsset *)asset coverImage:(UIImage *)coverImage {
    BOOL showLoad = (self.photoType == WXMPhotoDetailTypeGetPhoto);
    if (self.toolbar.isOriginalImage) showLoad = YES;
    [WXMResourceAssistant sendResource:asset
                            coverImage:coverImage
                              delegate:self.delegate
                            isShowLoad:showLoad
                        viewController:self.navigationController];
}

#pragma mark ----------------------------------- 点击选择框

- (void)wp_photoCollectionCellCheckBox:(WXMPhotoCollectionCell *)cell selected:(BOOL)selected {
    
    /** return; */
    
    @synchronized (self) {
        NSInteger maxCount = [self realSelectCount];
        BOOL isFull = (self.dictionaryArray.count >= maxCount);
        
        /**< 删除 */
        if (selected) {
            
            [cell refreshRanking:nil animation:NO];
            [self refreshRanking:cell.photoAsset.asset.localIdentifier];
            [self.dictionaryArray removeObjectForKey:cell.photoAsset.asset.localIdentifier];
            
            if (isFull) [self reloadAllAvailableCell]; /** 刷新遮罩 */
            if (self.dictionaryArray.count == 0&&(!WXMPhotoChooseVideo_Photo || !self.chooseVideoWithPhoto)) {
                [self reloadAllAvailableCell];
            }
            
        /**< 添加 */
        } else {
            
            /**< 判断资源合法  */
            if (![self legalResources:cell]) return;
            NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
            WXMPhotoRecordModel *recordModel = [WXMPhotoRecordModel new];
            recordModel.recordAlbumName = self.phoneList.title;
            recordModel.recordAsset = cell.photoAsset;
            recordModel.recordRank = (self.dictionaryArray.count + 1);
            recordModel.recordIndexPath = indexPath;
            recordModel.mediaType = cell.photoAsset.mediaType;
            [cell refreshRanking:recordModel animation:YES];
            [self.dictionaryArray setObject:recordModel forKey:cell.photoAsset.asset.localIdentifier];
            
            if (self.dictionaryArray.count >= maxCount) [self reloadAllAvailableCell];
            if (self.dictionaryArray.count == 1 && (!WXMPhotoChooseVideo_Photo || !self.chooseVideoWithPhoto)) {
                [self reloadAllAvailableCell];
            }
        }
        
        /** 同步数量 */
        self.toolbar.dictionaryArray = self.dictionaryArray;
    }
}

/** 重新刷新排名 */
- (void)refreshRanking:(NSString *)localIdentifier {
    WXMPhotoRecordModel *delete = [self.dictionaryArray objectForKey:localIdentifier];
    if (!delete) return;
    for (WXMPhotoRecordModel *recordModel in self.dictionaryArray.allValues) {
        if (delete == recordModel) continue;
        if (recordModel.recordRank > delete.recordRank) {
            recordModel.recordRank = MAX(recordModel.recordRank - 1, 1);
            NSIndexPath *index = recordModel.recordIndexPath;
            WXMPhotoCollectionCell *cell = (WXMPhotoCollectionCell *)[self.collectionView cellForItemAtIndexPath:index];
            [cell refreshRanking:recordModel animation:NO];
        }
    }
}

/** 判断资源(大小时长)合法 */
- (BOOL)legalResources:(WXMPhotoCollectionCell *)cell {
    if (self.unrestrictedmode) return YES;
    BOOL isVidelCell = cell.photoAsset.mediaType == WXMPHAssetMediaTypeVideo;
    if (isVidelCell && cell.photoAsset.asset.duration > WXMPhotoLimitVideoTime && WXMPhotoLimitVideoTime > 0) {
        NSString *message = [NSString stringWithFormat:@"不支持超过%d秒的视频", WXMPhotoLimitVideoTime];
        [WXMPhotoUIAssistant showAlertViewControllerWithTitle:message message:@"" cancel:@"确定" otherAction:nil completeBlock:nil];
        return NO;
    }
    
    BOOL isGIFCell = cell.photoAsset.mediaType == WXMPHAssetMediaTypePhotoGif;
    if (isGIFCell && WXMPhotoLimitGIFSize > 0) {
        CGFloat multipartfile = [WXMPhotoUIAssistant getOriginalMultipartfile:cell.photoAsset.asset];
        if (multipartfile > WXMPhotoLimitGIFSize){
            NSString *message = [NSString stringWithFormat:@"不支持超过%dM的动图", WXMPhotoLimitGIFSize];
            [WXMPhotoUIAssistant showAlertViewControllerWithTitle:message message:@"" cancel:@"确定" otherAction:nil completeBlock:nil];
            return NO;
        }
    }
        
    return YES;
}

/** 判断数量或者可选模式合法 */
- (BOOL)judgeCellCanTouch:(WXMPhotoCollectionCell *)cell {
    if (self.unrestrictedmode) return YES;
    
    /**< 不能选视频 */
    BOOL isVidelCell = cell.photoAsset.mediaType == WXMPHAssetMediaTypeVideo;
    if (isVidelCell && self.canSelectedVideo == NO) return NO;
    
    /**< 数量不够 */
    NSInteger count = self.dictionaryArray.count;
    NSString *localIdentifier = cell.photoAsset.asset.localIdentifier;
    WXMPhotoRecordModel *recordModel = [self.dictionaryArray objectForKey:localIdentifier];
    if (count <= 0 || recordModel != nil) return YES;
           
    /**< 支持同时选视频和图片 混合不做限制 */
    if (self.chooseVideoWithPhoto || self.photoType == WXMPhotoDetailTypeHybrid) {
        return (count < [self realSelectCount]);
        
    } else {
        
        /**< 不支持同时选视频和图片 */
        if (self.chooseType == WXMPHAssetMediaTypeVideo) {
            if (count >= self.maxSelectVideoCount) return NO;
            return (cell.photoAsset.mediaType == WXMPHAssetMediaTypeVideo);
        } else {
            if (count >= self.maxSelectImagesCount) return NO;
            return (cell.photoAsset.mediaType != WXMPHAssetMediaTypeVideo);
        }
    }
    
    return YES;
}

- (void)dismissViewController {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

/** collectionView  */
- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
        flow.itemSize = CGSizeMake(kImageWidth, kImageWidth);
        flow.minimumLineSpacing = kMargin;
        flow.minimumInteritemSpacing = kMargin;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:WXMPhoto_SRect collectionViewLayout:flow];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.alwaysBounceVertical = YES;
        [_collectionView registerClass:[WXMPhotoCollectionCell class] forCellWithReuseIdentifier:@"cell"];
    }
    return _collectionView;
}

/** 用户第一张选择的类型 */
- (WXMPhotoMediaType)chooseType {
    if (self.dictionaryArray.count == 0) return WXMPHAssetMediaTypeNone;
    WXMPhotoRecordModel *signModel = self.dictionaryArray.firstObject;
    if (signModel.mediaType == WXMPHAssetMediaTypeVideo) return WXMPHAssetMediaTypeVideo;
    return WXMPHAssetMediaTypeImage;
}

/** 是否显示勾选框 */
- (BOOL)displayCheckBox:(WXMPhotoAsset *)photoAsset {
    if (self.unrestrictedmode) return NO;
    
    /**< 混合不限制 */
    if (self.photoType == WXMPhotoDetailTypeHybrid)  return YES;
    
    /**< 只能选一个视频时不能勾选 其余可以 */
    if (photoAsset.mediaType == WXMPHAssetMediaTypeVideo && self.maxSelectVideoCount == 1) return NO;
    
    return YES;
}

/** 多选是否支持同时选图片和视频 */
- (BOOL)chooseVideoWithPhoto {
    if (self.unrestrictedmode) {
        _chooseVideoWithPhoto = NO;
    }
    return _chooseVideoWithPhoto && WXMPhotoChooseVideo_Photo;
}

/** 是否显示视频按钮 */
- (BOOL)showVideo {
    if (self.unrestrictedmode) {
        return NO;
    }
    return _showVideo;
}

/** 无限制模式 */
- (BOOL)unrestrictedmode {
    if (self.photoType == WXMPhotoDetailTypeGetPhoto ||
        self.photoType == WXMPhotoDetailTypeGetPhoto_256 ||
        self.photoType == WXMPhotoDetailTypeGetPhotoCustomSize ||
        self.photoType == WXMPhotoDetailTypeTailoring) {
        return YES;
    }
    return NO;
}

/** 实际上最大选择数量 */
- (NSInteger)realSelectCount {
    if (self.photoType == WXMPhotoDetailTypeHybrid) return self.maxSelectImagesCount;
    if (self.chooseVideoWithPhoto && WXMPhotoChooseVideo_Photo) {
        return MAX(self.maxSelectImagesCount, self.maxSelectVideoCount);
    }
    if (self.chooseType == WXMPHAssetMediaTypeVideo) return self.maxSelectVideoCount;
    return self.maxSelectImagesCount;
}

/** 选择图片最大张数 */
- (NSInteger)maxSelectImagesCount {
    if (self.multiSelectMax > 0) return self.multiSelectMax;
    return WXMMultiSelectMax;
}

/** 选择视频最大数量 */
- (NSInteger)maxSelectVideoCount {
    if (self.multiSelectVideoMax > 0) return self.multiSelectVideoMax;
    return WXMMultiSelectVideoMax;
}

/** 上部工具栏 */
- (WXMPhotoDetailTitleBar *)titleBar {
    if (!_titleBar) {
        _titleBar = [[WXMPhotoDetailTitleBar alloc] init];
        _titleBar.delegate = self;
    }
    return _titleBar;
}

/** 下部工具栏 */
- (WXMPhotoDetailToolbar *)toolbar {
    if (!_toolbar) {
        _toolbar = [[WXMPhotoDetailToolbar alloc] initWithFrame:CGRectZero];
        _toolbar.delegate = self;
    }
    return _toolbar;
}

/** 选择相册控制器 */
- (WXMPhotoViewController *)listController {
    if (!_listController) {
        _listController = [[WXMPhotoViewController alloc] init];
        _listController.delegate = self;
        [self addChildViewController:_listController];
    }
    return _listController;
}

/** 记录选择的资源对象 */
- (WXMDictionary_Array *)dictionaryArray {
    if (!_dictionaryArray) {
        _dictionaryArray = [[WXMDictionary_Array alloc] init];
        _dictionaryArray.maxCount = self.maxSelectImagesCount;
        if (self.chooseType == WXMPHAssetMediaTypeVideo) {
            _dictionaryArray.maxCount = self.maxSelectVideoCount;
        }
    }
    return _dictionaryArray;
}

- (UICollectionView *)transitionCollectionView {
    if (_collectionView) return self.collectionView;
    return nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)dealloc {
    NSLog(@"释放 %@",NSStringFromClass(self.class));
}

@end
