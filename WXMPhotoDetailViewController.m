//
//  WXMPhotoDetailViewController.m
//  ModuleDebugging
//
//  Created by edz on 2019/5/6.
//  Copyright © 2019年 wq. All rights reserved.
//
#define KWidth [UIScreen mainScreen].bounds.size.width
#define KHeight [UIScreen mainScreen].bounds.size.height
#define KIPHONE_X ((KHeight == 812.0f) ? YES : NO)
#define KBarHeight ((KIPHONE_X) ? 88.0f : 64.0f)
#define kMargin 2.5
#define kCount 4
#define kScaleRatio 3.0
#define imageWidth ([UIScreen mainScreen].bounds.size.width - (kCount - 1) * kMargin) / kCount
#define maxRow ceil(([UIScreen mainScreen].bounds.size.height - 64) / (imageWidth))
#import "WXMPhotoDetailViewController.h"
#import "WXMPhotoManager.h"
#import "WXMPhotoListCell.h"
#import "WXMPhotoSignModel.h"

@interface WXMPhotoDetailViewController () <
    UICollectionViewDelegate, UICollectionViewDataSource, WXMPhotoSignProtocol>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSMutableDictionary *signDictionary;
@property (nonatomic, assign) BOOL sign;
@end

@implementation WXMPhotoDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
    [self getDisplayImages];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:0 target:self
                                                            action:@selector(dismissViewController)];
    item.tintColor = WXMBarTitleColor;
    self.navigationItem.rightBarButtonItem = item;
}

/** 获取2倍像素的图片 */
- (void)getDisplayImages {
    PHAssetCollection *asset = _phoneList.assetCollection;
    NSArray *arrayAll = [[WXMPhotoManager sharedInstance] getAssetsInAssetCollection:asset ascending:YES];
    [arrayAll enumerateObjectsUsingBlock:^(PHAsset * obj, NSUInteger idx, BOOL * stop) {
        WXMPhotoAsset *asset = [WXMPhotoAsset new];
        asset.asset = obj;
        [self.dataSource addObject:asset];
    }];
    [self.collectionView reloadData];
    UICollectionViewScrollPosition position = UICollectionViewScrollPositionCenteredVertically;
    
    if (_dataSource.count <= 1) return;
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
    if (self.photoType == WXMPhotoDetailTypeMultiSelect) {
        NSString *indexString = @(indexPath.row).stringValue;
        BOOL respond = (self.signDictionary.allKeys.count < WXMMultiSelectMax);
        WXMPhotoSignModel *signModel = [self.signDictionary objectForKey:indexString];
        [cell setDelegate:self indexPath:indexPath signModel:signModel respond:respond];
    }
    return cell;
}
/** 点击事件 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    WXMPhotoManager * manager = [WXMPhotoManager sharedInstance];
    CGSize size = CGSizeZero;
    WXMPhotoAsset *phsset = self.dataSource[indexPath.row];
    PHAsset *asset = phsset.asset;
    NSString *indexString = @(indexPath.row).stringValue;
    
    /** 获取图片 */
    if (_photoType == WXMPhotoDetailTypeGetPhoto) {
        [manager getImageByAsset:asset makeResizeMode:PHImageRequestOptionsResizeModeExact isOriginal:YES completion:^(UIImage *assetImage) {
            [self sendImage:assetImage];
            [self dismissViewController];
        }];
    }
    
    /** 获取256图片  */
    if (_photoType == WXMPhotoDetailTypeGetPhoto_256) {
        size = CGSizeMake(256, 256);
        [manager getImageByAsset_Synchronous:asset size:size completion:^(UIImage * image) {
            [self sendImage:image];
            [self dismissViewController];
        }];
    }
    
    /** 多选 (点图标) */
    if (_photoType == WXMPhotoDetailTypeMultiSelect && self.sign) {
        self.sign = NO;
        size = CGSizeEqualToSize(self.expectSize, CGSizeZero) ? WXMDefaultSize : self.expectSize;
        [manager getImageByAsset_Asynchronous:asset size:size completion:^(UIImage * image) {
            WXMPhotoSignModel *signModel = [WXMPhotoSignModel new];
            signModel.albumName = self.phoneList.title;
            signModel.rank = self.signDictionary.allKeys.count + 1;
            signModel.indexPath = indexPath;
            signModel.image = image;
            [self.signDictionary setObject:signModel forKey:indexString];
            if (self.signDictionary.allKeys.count>=WXMMultiSelectMax) [self.collectionView reloadData];
        }];
    }
    
    
    /** 多选 (点大图)) */
    if (_photoType == WXMPhotoDetailTypeMultiSelect && !self.sign) {
        size = CGSizeEqualToSize(self.expectSize, CGSizeZero) ? WXMDefaultSize : self.expectSize;
        [manager getImageByAsset_Synchronous:asset size:size completion:^(UIImage * image) {
            
        }];
    }
    
    
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
        
        CGRect rect = CGRectMake(0, KBarHeight, KWidth, KHeight - KBarHeight);
        _collectionView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:flow];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.alwaysBounceVertical = YES;
        [_collectionView registerClass:[WXMPhotoCollectionCell class] forCellWithReuseIdentifier:@"cell"];
    }
    return _collectionView;
}
@end
