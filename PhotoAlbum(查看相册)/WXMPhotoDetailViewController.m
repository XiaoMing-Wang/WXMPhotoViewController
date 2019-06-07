//
//  WXMPhotoDetailViewController.m
//  ModuleDebugging
//
//  Created by edz on 2019/5/6.
//  Copyright © 2019年 wq. All rights reserved.
//
#define kMargin 2.5
#define kCount 4
#define kScaleRatio 3.0
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

@interface WXMPhotoDetailViewController ()
<UICollectionViewDelegate, UICollectionViewDataSource, WXMPhotoSignProtocol>

@property (nonatomic, strong) UICollectionView *collectionView;

/** 数据源 */
@property (nonatomic, strong) NSMutableArray *dataSource;

/** 存储被标记的图片model */
@property (nonatomic, strong) WXMDictionary_Array *signObj;

@property (nonatomic, assign) BOOL sign;
@property (nonatomic, assign) BOOL refresh;

/** 是否显示白色遮罩 */
@property (nonatomic, assign) BOOL wxm_showWhiteMasing;
@end

@implementation WXMPhotoDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = @[].mutableCopy;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.title = self.phoneList.title;
    self.navigationController.navigationBar.translucent = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    [self.view addSubview:self.collectionView];
    
    /** 获取图片 */
    [self wxm_getDisplayImages];
    SEL sel = @selector(dismissViewController);
    UIBarButtonItem *item = [WXMPhotoAssistant wxm_createButtonItem:@"完成" target:self action:sel];
    self.navigationItem.rightBarButtonItem = item;
}

/** 获取2倍像素的图片 */
- (void)wxm_getDisplayImages {
    PHAssetCollection *asset = _phoneList.assetCollection;
    WXMPhotoManager *manager = [WXMPhotoManager sharedInstance];
    NSArray *arrayAll = [manager wxm_getAssetsInAssetCollection:asset ascending:YES];
    [arrayAll enumerateObjectsUsingBlock:^(PHAsset * obj, NSUInteger idx, BOOL * stop) {
        WXMPhotoAsset *asset = [WXMPhotoAsset new];
        asset.asset = obj;
        [self.dataSource addObject:asset];
    }];
    
    /** 滚动到最后 */
    [self.collectionView reloadData];
    if (_dataSource.count <= 1) return;
    UICollectionViewScrollPosition position = UICollectionViewScrollPositionCenteredVertically;
    NSIndexPath * index = [NSIndexPath indexPathForRow:_dataSource.count - 1 inSection:0];
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
    WXMPhotoCollectionCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:ip];
    cell.photoType = self.photoType;
    cell.photoAsset = self.dataSource[indexPath.row];
    
    /** 多选模式 */
    if (self.photoType == WXMPhotoDetailTypeMultiSelect) {
        NSString *indexString = @(indexPath.row).stringValue;
        WXMPhotoSignModel *signModel = [self.signObj objectForKey:indexString];
        [cell setDelegate:self indexPath:indexPath signModel:signModel showMask:self.wxm_showWhiteMasing];
    }
    return cell;
}

/** 点击事件 */
- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize size = CGSizeZero;
    WXMPhotoManager * manager = [WXMPhotoManager sharedInstance];
    WXMPhotoAsset *phsset = self.dataSource[indexPath.row];
    PHAsset *asset = phsset.asset;
    NSString *indexString = @(indexPath.row).stringValue;
    BOOL respond = (self.signObj.count < WXMMultiSelectMax);
    WXMPhotoCollectionCell *cell = (WXMPhotoCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    
    /** 单选原图 + 单选256 */
    if (_photoType == WXMPhotoDetailTypeGetPhoto || _photoType == WXMPhotoDetailTypeGetPhoto_256) {
        if (self.exitPreview) {
            size = CGSizeMake(WXMPhoto_Width * 2, WXMPhoto_Width * phsset.aspectRatio * 2);
        } else if (_photoType == WXMPhotoDetailTypeGetPhoto_256 && !self.exitPreview) {
            size = CGSizeMake(256, 256);
        } else if (_photoType == WXMPhotoDetailTypeGetPhoto && !self.exitPreview) {
            size = CGSizeZero;
        }
        
        
        [manager wxm_synchronousGetPictures:asset size:size completion:^(UIImage *image) {
            if (self.exitPreview) {
                phsset.bigImage = image;
                WXMPhotoPreviewController *preview = [self wxm_getPreviewController:indexPath];
                preview.previewType = WXMPhotoPreviewTypeSingle;
                [self.navigationController pushViewController:preview animated:YES];
                return;
            }
            [self sendImage:image];
            [self dismissViewController];
        }];
    }
    
    
    /** 多选(点图标)  添加(取消在下面回调) */
    if (_photoType == WXMPhotoDetailTypeMultiSelect && self.sign) {
        self.sign = NO;
        size = CGSizeEqualToSize(self.expectSize, CGSizeZero) ? WXMDefaultSize : self.expectSize;
        [manager getPictures_customSize:asset synchronous:NO assetSize:size completion:^(UIImage *image) {
            WXMPhotoSignModel *signModel = [self wxm_signModel:indexPath signImage:image];
            [self.signObj setObject:signModel forKey:indexString];
            if (self.signObj.count >= WXMMultiSelectMax) [self wxm_reloadAllAvailableCell];
        }];
        return;
    }
    
    
    /** 先同步获取大图 否则跳界面会闪 */
    if (_photoType == WXMPhotoDetailTypeMultiSelect && !self.sign) {
        if (respond == NO && cell.userCanTouch == NO) return;
        size = CGSizeMake(WXMPhoto_Width * 2, WXMPhoto_Width * phsset.aspectRatio * 2);
        [manager wxm_synchronousGetPictures:asset size:size completion:^(UIImage *image) {
            phsset.bigImage = image;
            WXMPhotoPreviewController *preview = [self wxm_getPreviewController:indexPath];
            preview.previewType = WXMPhotoPreviewTypeMost;
            [self.navigationController pushViewController:preview animated:YES];
            preview.signCallback = ^WXMDictionary_Array *(NSInteger index) {
                return [self previewCallBack:index];
            };
        }];
    }
    
    
    /** 裁剪框 */
    if (_photoType == WXMPhotoDetailTypeTailoring) {
        [manager getPictures_original:asset synchronous:YES completion:^(UIImage *image) {
            WXMPhotoShapeController *shape = [WXMPhotoShapeController new];
            shape.shapeImage = image;
            [self.navigationController pushViewController:shape animated:YES];
        }];
    }
    
}

/** 预览控制器 */
- (WXMPhotoPreviewController *)wxm_getPreviewController:(NSIndexPath *)index {
    @autoreleasepool {
        WXMPhotoPreviewController * preview = [WXMPhotoPreviewController new];
        preview.dataSource = self.dataSource;
        preview.photoType = self.photoType;
        preview.delegate = self.delegate;
        preview.results = self.results;
        preview.resultArray = self.resultArray;
        preview.indexPath = index;
        preview.signObj = self.signObj;
        preview.wxm_windowView = [WXMPhotoAssistant wxmPhoto_snapViewImage:self.navigationController.view];
        preview.dragCallback = ^UIView *{
            return [WXMPhotoAssistant wxmPhoto_snapViewImage:self.view];
        };
        return preview;
    }
}

/** 刷新所有显示的cell */
- (void)wxm_reloadAllAvailableCell {
    self.wxm_showWhiteMasing = (self.signObj.count >= WXMMultiSelectMax);
    
    /** visibleCells collectionView新的刷新机制会生成新的cell导致不能刷新 */
    [self.collectionView.subviews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[WXMPhotoCollectionCell class]]) {
            WXMPhotoCollectionCell * cell = (WXMPhotoCollectionCell *)obj;
            if (self.wxm_showWhiteMasing) {
                NSString *indexString = @(cell.indexPath.row).stringValue;
                BOOL use = [self.signObj.allKeys containsObject:indexString];
                [cell setUserCanTouch:use animation:YES];
            } else {
                [cell setUserCanTouch:YES animation:YES];
            }
        }
    }];    
}

/** 生成标记对象 */
- (WXMPhotoSignModel *)wxm_signModel:(NSIndexPath *)idx signImage:(UIImage *)image {
    WXMPhotoSignModel *signModel = [WXMPhotoSignModel new];
    signModel.albumName = self.phoneList.title;
    signModel.rank = self.signObj.count + 1;
    signModel.indexPath = idx;
    signModel.image = image;
    return signModel;
}

#pragma mark 在下一个界面(预览)选中取消的回调
/** 预览模式回调(不能立即刷新 刷新会导致转场动画时获取不到cell以及cell的位置) */
- (WXMDictionary_Array *)previewCallBack:(NSInteger)index {
    NSString *indexString = @(index).stringValue;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    BOOL isFull = (self.signObj.count >= WXMMultiSelectMax);
    WXMPhotoCollectionCell *cell = (WXMPhotoCollectionCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    /** 取消选中 */
    if ([self.signObj.allKeys containsObject:indexString]) {
        [self.signObj removeObjectForKey:indexString];
        [cell signButtonSelected:NO];
        [self wxm_signDictionarySorting];              /** 重新排名 */
        if (isFull) [self wxm_reloadAllAvailableCell]; /** 刷新遮罩 */
        
    /** 选中 */
    } else {
        WXMPhotoAsset *phsset = self.dataSource[index];
        cell.signModel = [self wxm_signModel:indexPath signImage:phsset.bigImage];
        [self.signObj setObject:cell.signModel forKey:indexString];
        [cell signButtonSelected:YES];
        if (self.signObj.count >= WXMMultiSelectMax) [self wxm_reloadAllAvailableCell];
    }
    
    
    return self.signObj;
}

#pragma mark 点击绿色小勾的回调

/** 多选模式下的回调 */
- (NSInteger)touchWXMPhotoSignView:(NSIndexPath *)index selected:(BOOL)selected {
    
    /** 勾选一个 */
    if (selected) {
        self.sign = YES;
        [self collectionView:_collectionView didSelectItemAtIndexPath:index];
        
    /** 取消勾选一个 */
    } else {
        self.sign = NO;
        BOOL isFull = (self.signObj.count >= WXMMultiSelectMax);
        [self.signObj removeObjectForKey:@(index.row).stringValue];
        if (isFull) [self wxm_reloadAllAvailableCell];
        [self wxm_signDictionarySorting];
    }
    return self.signObj.allKeys.count;
}

/** 取消一个后面的需要重新排序 */
- (void)wxm_signDictionarySorting {
    [self.signObj enumerateKeysAndObjectsUsingBlock:^(NSString *key, WXMPhotoSignModel *obj, BOOL *stop) {
        NSInteger row = key.integerValue;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        WXMPhotoCollectionCell *cell = (WXMPhotoCollectionCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        obj.rank = [self.signObj indexOfObject:obj] + 1;
        [cell refreshRankingWithSignModel:obj];
    }];
}

/** 发送照片 */
- (void)sendImage:(UIImage *)image {
    SEL singleSEL = @selector(wxm_singlePhotoAlbumWithImage:);
    if (self.results) self.results(image);
    if (self.delegate && [self.delegate respondsToSelector:singleSEL]) {
        [self.delegate wxm_singlePhotoAlbumWithImage:image];
    }
}

/**  */
- (void)dismissViewController {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
        flow.itemSize = CGSizeMake(imageWidth, imageWidth);
        flow.minimumLineSpacing = kMargin;
        flow.minimumInteritemSpacing = kMargin;
        
        CGRect rect = {0,WXMPhoto_BarHeight,WXMPhoto_Width,WXMPhoto_Height-WXMPhoto_BarHeight};
        _collectionView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:flow];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.alwaysBounceVertical = YES;
        [_collectionView registerClass:[WXMPhotoCollectionCell class] forCellWithReuseIdentifier:@"cell"];
    }
    return _collectionView;
}

- (WXMDictionary_Array *)signObj {
    if (!_signObj) {
        _signObj = [[WXMDictionary_Array alloc] init];
        _signObj.maxCount = WXMMultiSelectMax;
    }
    return _signObj;
}

- (UICollectionView *)transitionCollectionView {
    if (_collectionView) return _collectionView;
    return nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.125 * NSEC_PER_SEC)), mainQueue, ^{
        if (self.refresh) [self.collectionView reloadData];
        self.refresh = NO;
    });
}

- (void)dealloc {
    NSLog(@"释放 %@",NSStringFromClass(self.class));
}
@end
