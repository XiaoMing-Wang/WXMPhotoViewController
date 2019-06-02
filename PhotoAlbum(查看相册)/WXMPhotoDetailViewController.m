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

@interface WXMPhotoDetailViewController ()
<UICollectionViewDelegate, UICollectionViewDataSource, WXMPhotoSignProtocol>

@property (nonatomic, strong) UICollectionView *collectionView;

/** 数据源 */
@property (nonatomic, strong) NSMutableArray *dataSource;

/** 存储被标记的图片model */
@property (nonatomic, strong) NSMutableDictionary *signDictionary;

@property (nonatomic, assign) BOOL sign;
@property (nonatomic, assign) BOOL refresh;
@end

@implementation WXMPhotoDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.exitPreview = YES;
    
    self.dataSource = @[].mutableCopy;
    self.signDictionary = @{}.mutableCopy;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.title = self.phoneList.title;
    self.navigationController.navigationBar.translucent = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    [self.view addSubview:self.collectionView];
    [self wxm_getDisplayImages];  /** 获取图片 */
    
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
        BOOL respond = (self.signDictionary.allKeys.count < WXMMultiSelectMax);
        WXMPhotoSignModel *signModel = [self.signDictionary objectForKey:indexString];
        [cell setDelegate:self indexPath:indexPath signModel:signModel respond:respond];
    }
    return cell;
}

/** 点击事件 */
- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    WXMPhotoManager * manager = [WXMPhotoManager sharedInstance];
    CGSize size = CGSizeZero;
    WXMPhotoAsset *phsset = self.dataSource[indexPath.row];
    PHAsset *asset = phsset.asset;
    CGFloat scale = [UIScreen mainScreen].scale;
    NSString *indexString = @(indexPath.row).stringValue;
    BOOL respond = (self.signDictionary.allKeys.count < WXMMultiSelectMax);
    WXMPhotoCollectionCell *cell = (WXMPhotoCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    
    /** 单选原图 + 单选256 */
    if (_photoType == WXMPhotoDetailTypeGetPhoto || _photoType == WXMPhotoDetailTypeGetPhoto_256) {
        
        if (self.exitPreview) {
            size = CGSizeMake(WXMPhoto_Width * scale, WXMPhoto_Width * phsset.aspectRatio * scale);
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
    
    
    /** 获取256图片  */
     /** if (_photoType == WXMPhotoDetailTypeGetPhoto_256) {
      
    } */
    
    
    /** 多选 (点图标) */
    if (_photoType == WXMPhotoDetailTypeMultiSelect && self.sign) {
        self.sign = NO;
        size = CGSizeEqualToSize(self.expectSize, CGSizeZero) ? WXMDefaultSize : self.expectSize;
        [manager getPictures_customSize:asset synchronous:NO assetSize:size completion:^(UIImage *image) {
            phsset.bigImage = image;
            WXMPhotoSignModel *signModel = [WXMPhotoSignModel new];
            signModel.albumName = self.phoneList.title;
            signModel.rank = self.signDictionary.allKeys.count + 1;
            signModel.indexPath = indexPath;
            signModel.image = image;
            [self.signDictionary setObject:signModel forKey:indexString];
            if (self.signDictionary.allKeys.count>=WXMMultiSelectMax) [self.collectionView reloadData];
        }];
        return;
    }
    
    
    /** 多选 (点大图)) */
    if (_photoType == WXMPhotoDetailTypeMultiSelect && !self.sign) {
        if (respond == NO && cell.canRespond == NO) return;
        size = CGSizeMake(WXMPhoto_Width, WXMPhoto_Height);
        
        /** 先同步获取大图 否则跳界面会闪 */
        [manager getPictures_customSize:asset synchronous:YES assetSize:size completion:^(UIImage *image) {
            phsset.bigImage = image;
            WXMPhotoPreviewController * preview = [WXMPhotoPreviewController new];
            preview.dataSource = self.dataSource;
            preview.signDictionary = self.signDictionary;
            preview.indexPath = indexPath;
            preview.windowImage = [WXMPhotoAssistant wxmPhoto_makeViewImage:self.navigationController.view];
            [self.navigationController pushViewController:preview animated:YES];
            preview.callback = ^NSDictionary *(NSInteger index,NSInteger rank) {
                return [self previewCallBack:index rank:rank];
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
    WXMPhotoPreviewController * preview = [WXMPhotoPreviewController new];
    preview.dataSource = self.dataSource;
    preview.photoType = self.photoType;
    preview.delegate = self.delegate;
    preview.results = self.results;
    preview.resultArray = self.resultArray;
    preview.indexPath = index;
    preview.signDictionary = self.signDictionary;
    preview.windowImage = [WXMPhotoAssistant wxmPhoto_makeViewImage:self.navigationController.view];
    return preview;
}

/** 预览模式回调(不能立即刷新 刷新会导致转场动画时获取不到cell以及cell的位置) */
- (NSDictionary *)previewCallBack:(NSInteger)index rank:(NSInteger)rank{
    NSString *indexString = @(index).stringValue;
    self.refresh = YES;
    
    /** 取消选中 */
    if ([self.signDictionary.allKeys containsObject:indexString]) {
        [self.signDictionary removeObjectForKey:indexString];
        [self signDictionarySorting:rank];
        /** [self.collectionView reloadData]; */
    } else {
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        WXMPhotoAsset *phsset = self.dataSource[index];
        WXMPhotoSignModel *signModel = [WXMPhotoSignModel new];
        signModel.albumName = self.phoneList.title;
        signModel.rank = self.signDictionary.allKeys.count + 1;
        signModel.indexPath = indexPath;
        signModel.image = phsset.smallImage;
        [self.signDictionary setObject:signModel forKey:indexString];
        /** [self.collectionView reloadData]; */
    }
    return self.signDictionary;
}

/** 多选模式下的回调 */
- (NSInteger)touchWXMPhotoSignView:(NSIndexPath *)index selected:(BOOL)selected {
    if (selected) {
        self.sign = YES;
        [self collectionView:self.collectionView didSelectItemAtIndexPath:index];
    } else {
        self.sign = NO;
        NSString *indexString = @(index.row).stringValue;
        WXMPhotoSignModel *signModel = [self.signDictionary objectForKey:indexString];
        NSInteger rank = signModel.rank;
        [self.signDictionary removeObjectForKey:indexString];
        [self signDictionarySorting:rank];
        [self.collectionView reloadData];
    }
    return self.signDictionary.allKeys.count;
}

/** 重新排序 */
- (void)signDictionarySorting:(NSInteger)rank {
    [self.signDictionary enumerateKeysAndObjectsUsingBlock:^(id key, WXMPhotoSignModel* obj, BOOL *stop) {
        if (obj.rank >= rank) obj.rank -= 1;
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
        
        CGRect rect = CGRectMake(0,WXMPhoto_BarHeight,WXMPhoto_Width,WXMPhoto_Height-WXMPhoto_BarHeight);
        _collectionView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:flow];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.alwaysBounceVertical = YES;
        [_collectionView registerClass:[WXMPhotoCollectionCell class] forCellWithReuseIdentifier:@"cell"];
    }
    return _collectionView;
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
@end
