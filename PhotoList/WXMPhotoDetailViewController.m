//
//  WXMPhotoDetailViewController.m
//  ModuleDebugging
//
//  Created by edz on 2019/5/6.
//  Copyright © 2019年 wq. All rights reserved.
//

#define imageWidth ([UIScreen mainScreen].bounds.size.width - (kCount - 1) * kMargin) / kCount
#define maxRow ceil(([UIScreen mainScreen].bounds.size.height - 64) / (imageWidth))
#import "WXMPhotoDetailViewController.h"
#import "WXMPhotoManager.h"
#import "WXMPhotoListCell.h"
#import "WXMPhotoCollectionCell.h"
#import "WXMPhotoSignModel.h"
#import "WXMPhotoConfiguration.h"
#import "WXMPhotoPreviewController.h"
#import "WXMPhotoShapeController.h"
#import "WXMDictionary_Array.h"
#import <objc/runtime.h>
#import "WXMPhotoDetailToolbar.h"
#import "WXMResourceAssistant.h"

@interface WXMPhotoDetailViewController ()
<UICollectionViewDelegate,
UICollectionViewDataSource,
WXMPhotoSignProtocol,
WXMDetailToolbarProtocol>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) WXMPhotoDetailToolbar *toolbar;
@property (nonatomic, assign) WXMPhotoMediaType chooseType;

/** 数据源 */
@property (nonatomic, strong) NSMutableArray *dataSource;

/** 存储被标记的图片model */
@property (nonatomic, strong) WXMDictionary_Array *signObj;
@property (nonatomic, assign) BOOL sign;
@property (nonatomic, assign) BOOL preview;
@property (nonatomic, assign) NSUInteger markNumber;
@end

@implementation WXMPhotoDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.title = self.phoneList.title;
    self.navigationController.navigationBar.translucent = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    [self.view addSubview:self.collectionView];
    if (WXMPhotoShowDetailToolbar && self.photoType == WXMPhotoDetailTypeMultiSelect) {
        [self.view addSubview:self.toolbar];
        self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, self.toolbar.height + 10, 0);
    }
    
    /** 获取图片 */
    [self checkDisplayImages];
    self.navigationItem.rightBarButtonItem = [WXMPhotoAssistant
                                              wxm_createButtonItem:@"取消"
                                              target:self
                                              action:@selector(dismissViewController)];
}

/** 获取2x像素的图片 */
- (void)checkDisplayImages {
    self.dataSource = @[].mutableCopy;
    PHAssetCollection *asset = self.phoneList.assetCollection;
    WXMPhotoManager *manager = [WXMPhotoManager sharedInstance];
    NSArray *arrayAll = [manager getAssetsInAssetCollection:asset ascending:YES];
    [arrayAll enumerateObjectsUsingBlock:^(PHAsset *obj, NSUInteger idx, BOOL *stop) {
        WXMPhotoAsset *asset = [WXMPhotoAsset new];
        asset.asset = obj;
        [self.dataSource addObject:asset];
    }];
    
    /** 滚动到最后 */
    [self.collectionView reloadData];
    if (self.dataSource.count <= 1) return;
    UICollectionViewScrollPosition position = UICollectionViewScrollPositionCenteredVertically;
    NSIndexPath * index = [NSIndexPath indexPathForRow:self.dataSource.count - 1 inSection:0];
    [self.collectionView scrollToItemAtIndexPath:index atScrollPosition:position animated:NO];
}


#pragma mark _____________________________________________UICollectionView dataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WXMPhotoCollectionCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.showVideo = (self.showVideo);
    cell.photoType = self.photoType;
    cell.photoAsset = self.dataSource[indexPath.row];
    
    /** 多选模式 */
    if (self.photoType == WXMPhotoDetailTypeMultiSelect) {
        NSString *indexString = @(indexPath.row).stringValue;
        WXMPhotoSignModel *signModel = [self.signObj objectForKey:indexString];
        
        /** 查看当前cell是否被选中 */
        BOOL available = [self wxm_judgeCellCanTouch:cell index:indexPath];
        if (self.canSelectedVideo == NO &&
            cell.photoAsset.mediaType == WXMPHAssetMediaTypeVideo) {
            available = NO;
        }
        [cell setDelegate:self indexPath:indexPath signModel:signModel available:available];
    }
    return cell;
}

/** 点击事件 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    __weak __typeof(self) self_weak = self;
    WXMPhotoManager * man = [WXMPhotoManager sharedInstance];
    WXMPhotoAsset *phsset = self.dataSource[indexPath.row];
    WXMPhotoCollectionCell *cell = nil;
    cell = (WXMPhotoCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];

    CGSize size = CGSizeZero;
    PHAsset *asset = phsset.asset;
    NSString *indexString = @(indexPath.row).stringValue;
    if (CGSizeEqualToSize(self.expectSize, CGSizeZero) && self.sign == NO) {
        self.expectSize = CGSizeMake(WXMPhoto_Width*2,WXMPhoto_Width*phsset.aspectRatio*2);
    }

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
        } else if (_photoType == WXMPhotoDetailTypeGetPhotoCustomSize && !self.exitPreview) {

            size = self.expectSize;
        }

        [man synchronousGetPictures:asset size:size completion:^(UIImage *image) {
            if (self.exitPreview) {
                WXMPhotoPreviewController *prev=[self_weak wxm_getPreviewController:indexPath];
                prev.previewType = WXMPhotoPreviewTypeSingle;
                [self_weak.navigationController pushViewController:prev animated:YES];
                return;
            }
            [self sendImage:image photoAsset:phsset];
        }];
    }


    /** 多选(点图标) 添加(取消在下面回调) */
    if (_photoType == WXMPhotoDetailTypeMultiSelect && self.sign) {
        self.sign = NO;
        size = CGSizeMake(WXMPhotoPreviewImageWH * 2, WXMPhotoPreviewImageWH * 2);
        
        [man getPictures_customSize:asset
                        synchronous:NO
                          assetSize:size
                         completion:^(UIImage *image) {
            WXMPhotoSignModel *signModel = [self wxm_signModel:indexPath signImage:image];
            signModel.mediaType = phsset.mediaType;
            
            [self.signObj setObject:signModel forKey:indexString];
            self.toolbar.signObj = self.signObj;
                   
            NSInteger maxCount = self.maxSelectImagesCount;
            if (self.chooseType == WXMPHAssetMediaTypeVideo) {
                maxCount = self.maxSelectVideoCount;
            }
            
            /** 个数超过个数  或者选择第一个的时候把其他类型筛选掉 */
            if (self.signObj.count >= maxCount ||
                (!WXMPhotoChooseVideo_Photo && self.signObj.count == 1)) {
                [self wxm_reloadAllAvailableCell];
            }
        }];
        return;
    }


    /** 先同步获取大图 否则跳界面会闪 */
    if (_photoType == WXMPhotoDetailTypeMultiSelect && !self.sign) {
        if (cell.userCanTouch == NO && !self.preview) return;
        size = CGSizeMake(WXMPhoto_Width * 2.0, WXMPhoto_Width * phsset.aspectRatio * 2.0);
        [man synchronousGetPictures:asset size:size completion:^(UIImage *image) {

            self.preview = NO;
            phsset.cacheImage = image;
            WXMPhotoPreviewController *preview = [self wxm_getPreviewController:indexPath];
            preview.previewType = WXMPhotoPreviewTypeMost;
            preview.signCallback = ^WXMDictionary_Array *(NSInteger index) {
                return [self previewCallBack:index];
            };
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
       
        size = CGSizeMake(width * 4, height * 4);
        if (WXMPhotoCropUseOriginal) size = PHImageManagerMaximumSize;
        [man synchronousGetPictures:asset size:size completion:^(UIImage *image) {
            WXMPhotoShapeController *shape = [WXMPhotoShapeController new];
            shape.delegate = self_weak.delegate;
            shape.shapeImage = image;
            shape.expectSize = self_weak.expectSize;
            [self_weak.navigationController pushViewController:shape animated:YES];
        }];
    }
}

/** 预览控制器 */
- (WXMPhotoPreviewController *)wxm_getPreviewController:(NSIndexPath *)index {
    WXMPhotoPreviewController * preview = [WXMPhotoPreviewController new];
    preview.dataSource = self.dataSource;
    preview.expectSize = self.expectSize;
    preview.photoType = self.photoType;
    preview.delegate = self.delegate;
    preview.indexPath = index;
    preview.signObj = self.signObj;
    preview.showVideo = self.showVideo;
    preview.isOriginalImage = self.toolbar.isOriginalImage;
    preview.selectedMaxCount = self.maxSelectImagesCount;
    if (self.chooseType == WXMPHAssetMediaTypeVideo) {
        preview.selectedMaxCount = self.maxSelectVideoCount;
    }
    
    UIView * snapView = self.navigationController.view;
    preview.wxm_windowView = [WXMPhotoAssistant wxmPhoto_snapViewImage:snapView];
    preview.dragCallback = ^UIView *{
        return [WXMPhotoAssistant wxmPhoto_snapViewImage:self.view];
    };
    return preview;
}

/** 刷新所有显示的cell */
- (void)wxm_reloadAllAvailableCell {
    [self.toolbar setOriginalEnabled:YES];
    if (self.chooseType == WXMPHAssetMediaTypeVideo && !WXMPhotoChooseVideo_Photo) {
        [self.toolbar setOriginalEnabled:NO];
    }
    
    /** visibleCells collectionView新的刷新机制会生成新的cell导致不能刷新 */
    NSArray *arrays = self.collectionView.subviews;
    [arrays enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop){
        if ([obj isKindOfClass:[WXMPhotoCollectionCell class]]) {
            WXMPhotoCollectionCell * cell = (WXMPhotoCollectionCell *)obj;
            BOOL available = [self wxm_judgeCellCanTouch:cell index:cell.indexPath];
            [cell setUserCanTouch:available animation:YES];
        }
    }];
}

#pragma mark --------- WXMPhotoDetailToolbar 点击toobar回调

/** 预览按钮 */
- (void)wxm_touchPreviewControl {
    self.sign = NO;
    self.preview = YES;
    WXMPhotoSignModel *signModel = self.signObj.lastObject;
    [self collectionView:_collectionView didSelectItemAtIndexPath:signModel.indexPath];
}

/** 回调 */
- (void)wxm_touchDismissViewController {
    CGSize size = self.expectSize;
    
    if (self.toolbar.isOriginalImage) size = PHImageManagerMaximumSize;
    NSMutableArray * array = @[].mutableCopy;
    [self.signObj enumerateObjectsUsingBlock:^(WXMPhotoSignModel* obj,NSUInteger idx,BOOL stop){
        WXMPhotoAsset *phsset = self.dataSource[obj.indexPath.row];
        if (phsset) [array addObject:phsset];
    }];
    
    [WXMResourceAssistant sendMoreResource:array
                                 coverSize:size
                                  delegate:self.delegate
                               isShowVideo:self.showVideo
                                isShowLoad:YES
                            viewController:self.navigationController];
}

#pragma mark 在下一个界面(预览)选中取消的回调

/** 预览模式回调(不能立即刷新 刷新会导致转场动画时获取不到cell以及cell的位置) */
- (WXMDictionary_Array *)previewCallBack:(NSInteger)index {
    NSString *indexString = @(index).stringValue;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    NSInteger maxCount = self.maxSelectImagesCount;
    if (self.chooseType == WXMPHAssetMediaTypeVideo) maxCount = self.maxSelectVideoCount;
    BOOL isFull = (self.signObj.count >= maxCount);
    WXMPhotoCollectionCell *cell =
    (WXMPhotoCollectionCell *) [self.collectionView cellForItemAtIndexPath:indexPath];
    
    /** 取消选中 */
    if ([self.signObj.allKeys containsObject:indexString]) {
        [self.signObj removeObjectForKey:indexString];
        [cell signButtonSelected:NO];
        [self wxm_signDictionarySorting];              /** 重新排名 */
        if (isFull) [self wxm_reloadAllAvailableCell]; /** 刷新遮罩 */
        if (self.signObj.count == 0 && (!WXMPhotoChooseVideo_Photo)) {
            [self wxm_reloadAllAvailableCell];
        }
        
    /** 选中 */
    } else {
        WXMPhotoAsset *phsset = self.dataSource[index];
        WXMPhotoSignModel* signModel = [self wxm_signModel:indexPath signImage:nil];
        signModel.mediaType = phsset.mediaType;
        
        [self.signObj setObject:signModel forKey:indexString];
        cell.signModel = signModel;
        [cell signButtonSelected:YES];
        if (self.signObj.count >= maxCount) [self wxm_reloadAllAvailableCell];
        if (self.signObj.count == 1 && !WXMPhotoChooseVideo_Photo) {
            [self wxm_reloadAllAvailableCell];
        }
    }
    
    self.toolbar.signObj = self.signObj;
    return self.signObj;
}

#pragma mark -----------------------判断cell是否可以点击 返回NO显示白色遮罩

/** 返回NO显示白色遮罩  */
- (BOOL)wxm_judgeCellCanTouch:(WXMPhotoCollectionCell *)cell index:(NSIndexPath *)index {
    NSInteger count = self.signObj.count;
    NSString *indexString = @(index.row).stringValue;
    if (cell.photoAsset.mediaType == WXMPHAssetMediaTypeVideo && !self.canSelectedVideo) {
        return NO;
    }
        
    /** 视频超过时长的 */
    if (cell.photoAsset.mediaType == WXMPHAssetMediaTypeVideo &&
        cell.photoAsset.asset.duration > WXMPhotoLimitVideoTime &&
        WXMPhotoLimitVideoTime > 0) return NO;
    
    
    /** 个数不够或者已经被勾选  */
    if (count <= 0) return YES;
    if ([self.signObj.allKeys containsObject:indexString]) return YES;
    
    /** 支持同时选视频和图片 */
    if (WXMPhotoChooseVideo_Photo) {
        return (count < self.maxSelectImagesCount);
    } else {  /** 不支持同时 */
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

#pragma mark 点击绿色小勾的回调

/** 多选模式下的回调 */
- (NSInteger)touchWXMPhotoSignView:(NSIndexPath *)index selected:(BOOL)selected {
    
    /** 勾选一个 */
    if (selected) {
        self.markNumber += 1;
        self.sign = YES;
        [self collectionView:self.collectionView didSelectItemAtIndexPath:index];
        
    /** 取消勾选一个 */
    } else {
        
        self.sign = NO;
        NSInteger maxCount = self.maxSelectImagesCount;
        if (self.chooseType == WXMPHAssetMediaTypeVideo){
            maxCount = self.maxSelectVideoCount;
        }
        
        BOOL isFull = (self.signObj.count >= maxCount);
        NSString *key = @(index.row).stringValue;
                
        [self.signObj removeObjectForKey:key];
        [self wxm_signDictionarySorting];
        
        self.markNumber = self.signObj.count;
        if ((self.signObj.count == 0 && !WXMPhotoChooseVideo_Photo) || isFull) {
            [self wxm_reloadAllAvailableCell];
        }
    }
    
   
    self.toolbar.signObj = self.signObj;
    return self.markNumber;
}

/** 可选最大数量 */
- (NSInteger)wxm_maxCountPhotoNumber {
    if (self.chooseType == WXMPHAssetMediaTypeVideo) return self.maxSelectVideoCount;
    return self.maxSelectImagesCount;
}


#pragma mark --------------- 取消一个后面的需要重新排序

/** 刷新rank和cell的标号 */
- (void)wxm_signDictionarySorting {
    [self.signObj enumerateKeysAndObjectsUsingBlock:^(NSString *key, WXMPhotoSignModel *obj, BOOL *stop) {
        NSInteger row = key.integerValue;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        WXMPhotoCollectionCell *cell =
        (WXMPhotoCollectionCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        obj.rank = ([self.signObj indexOfObject:obj] + 1);
        [cell refreshRankingWithSignModel:obj];
    }];
}

/** 不能点击回调 */
- (void)wxm_cantTouchWXMPhotoSignView:(WXMPhotoMediaType)mediaType {
    NSString * title = @"";
    NSInteger count = self.signObj.count;
    BOOL isVideo = (mediaType == WXMPHAssetMediaTypeVideo);
    
    /** 支持同时选 */
    if (WXMPhotoChooseVideo_Photo && self.showVideo) {
        if (count >= WXMMultiSelectVideoMax) {
            title = [NSString stringWithFormat:@"您最多可以选择%d个资源",WXMMultiSelectVideoMax];
        }
        
    /** 不支持同时选 */
    } else {
        
        if (isVideo) {
            title = [NSString stringWithFormat:@"暂不支持超过%d秒的视频",WXMPhotoLimitVideoTime];
        }
        
        if (self.chooseType == WXMPHAssetMediaTypeVideo && self.showVideo && isVideo){
            NSInteger index = self.maxSelectVideoCount;
            title = [NSString stringWithFormat:@"您最多可以选择%ld个视频",index];
        } else if(self.chooseType == WXMPHAssetMediaTypeVideo && self.showVideo && !isVideo){
            title = @"选择视频时不能选择图片";
        } else if(self.chooseType == WXMPHAssetMediaTypeImage && isVideo){
            title = @"选择图片时不能选择视频";
        } else if(self.chooseType == WXMPHAssetMediaTypeImage && !isVideo){
            NSInteger index = self.maxSelectImagesCount;
            title = [NSString stringWithFormat:@"您最多可以选择%ld张图片",index];
        }
    }
    
    if (mediaType == WXMPHAssetMediaTypeVideo &&
        !self.canSelectedVideo && count == 0) {
        title = @"暂时不能选择视频";
    }
        
    if (title.length <= 1) return;
    [WXMPhotoAssistant showAlertViewControllerWithTitle:title
                                                message:@""
                                                 cancel:@"知道了"
                                            otherAction:nil
                                          completeBlock:nil];
}


#pragma mark ----------------------------------- 生成标记对象

/** 生成标记对象 */
- (WXMPhotoSignModel *)wxm_signModel:(NSIndexPath *)idx signImage:(UIImage *)image {
    WXMPhotoSignModel *signModel = [WXMPhotoSignModel new];
    signModel.albumName = self.phoneList.title;
    signModel.rank = self.signObj.count + 1;
    signModel.indexPath = idx;
    signModel.image = image;
    return signModel;
}

#pragma mark ----------------------------------- 回调资源

/** 发送资源 */
- (void)sendImage:(UIImage *)image photoAsset:(WXMPhotoAsset *)asset {
    BOOL showLoad = (self.photoType == WXMPhotoDetailTypeGetPhoto);
    if (self.toolbar.isOriginalImage) showLoad = YES;
    [WXMResourceAssistant sendResource:asset
                            coverImage:image
                              delegate:self.delegate
                           isShowVideo:self.showVideo
                            isShowLoad:showLoad
                        viewController:self.navigationController];
}

/** 图片最大张数 */
- (NSInteger)maxSelectImagesCount{
    if (self.multiSelectMax > 0) return self.multiSelectMax;
    return WXMMultiSelectMax;
}

/** 视频选择最大 */
- (NSInteger)maxSelectVideoCount{
    if (self.multiSelectVideoMax > 0) return self.multiSelectVideoMax;
    return WXMMultiSelectVideoMax;
}

- (void)dismissViewController {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
        flow.itemSize = CGSizeMake(imageWidth, imageWidth);
        flow.minimumLineSpacing = kMargin;
        flow.minimumInteritemSpacing = kMargin;
        
        CGRect re = WXMPhoto_SRect;
        Class cellClass = [WXMPhotoCollectionCell class];
        _collectionView = [[UICollectionView alloc] initWithFrame:re collectionViewLayout:flow];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.alwaysBounceVertical = YES;
        [_collectionView registerClass:cellClass forCellWithReuseIdentifier:@"cell"];
    }
    return _collectionView;
}

- (WXMPhotoDetailToolbar *)toolbar {
    if (!_toolbar) {
        _toolbar = [[WXMPhotoDetailToolbar alloc] initWithFrame:CGRectZero];
        _toolbar.detailDelegate = self;
    }
    return _toolbar;
}

/** 数组指点二合一 */
- (WXMDictionary_Array *)signObj {
    if (!_signObj) {
        _signObj = [[WXMDictionary_Array alloc] init];
        _signObj.maxCount = self.maxSelectImagesCount;
        if (self.chooseType == WXMPHAssetMediaTypeVideo) {
            _signObj.maxCount = self.maxSelectVideoCount;
        }
    }
    return _signObj;
}

/** 目前选中的资源的类型 */
- (WXMPhotoMediaType)chooseType {
    if (self.signObj.count == 0) return WXMPHAssetMediaTypeNone;
    if (self.signObj.count > 0) {
        WXMPhotoSignModel * signModel = self.signObj.firstObject;
        if (signModel.mediaType == WXMPHAssetMediaTypeVideo) {
            return WXMPHAssetMediaTypeVideo;
        }
    }
    return WXMPHAssetMediaTypeImage;
}

- (BOOL)showVideo {
    if (self.photoType == WXMPhotoDetailTypeGetPhoto_256 ||
        self.photoType == WXMPhotoDetailTypeTailoring) {
        _showVideo = NO;
    }
    return _showVideo;
}

- (UICollectionView *)transitionCollectionView {
    if (_collectionView) return _collectionView;
    return nil;
}

- (void)dealloc {
#if DEBUG
    NSLog(@"释放 %@",NSStringFromClass(self.class));
#endif
}

@end
