//
//  WXMPreviewBottom.m
//  ModuleDebugging
//
//  Created by edz on 2019/5/13.
//  Copyright © 2019年 wq. All rights reserved.
//
#import "UIImage+WXMPhoto.h"
#import "WXMPreviewBottomBar.h"
#import "WXMPhotoRecordModel.h"
#import "WXMPhotoConfiguration.h"
#import "WXMBottomBarCollectionViewCell.h"

@interface WXMPreviewBottomBar ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *photoView;
@property (nonatomic, strong) UIView *finshView;
@property (nonatomic, strong) UIButton *originalButton;
@property (nonatomic, strong) UIButton *finishButton;
@property (nonatomic, strong) UIView *line;

@property (nonatomic, assign) BOOL isAnimation;
@property (nonatomic, assign, readwrite) BOOL isOriginalImage;
@property (nonatomic, assign) NSInteger lastSeleIdx;
@property (nonatomic, strong) NSIndexPath *lastIndexPath;
@property (nonatomic, strong) WXMDictionary_Array *allDictionaryArray;
@end

@implementation WXMPreviewBottomBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) [self initializationInterface];
    return self;
}

/** 初始化界面 */
- (void)initializationInterface {
    CGFloat h = 125;
    CGFloat y = WXMPhoto_Height - h - (kIPhoneX ? 35 : 0);
    self.frame = CGRectMake(0, y, WXMPhoto_Width, h);
    self.lastSeleIdx = -1;
    
    /** 上半部分预览 */
    self.photoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WXMPhoto_Width, 80)];
    self.photoView.backgroundColor = WXMPhotoPreviewbarColor;
    self.photoView.alpha = 0;
    [self.photoView addSubview:self.collectionView];
    
    /** 下半部分按钮 */
    CGFloat finH = h - 80 + (kIPhoneX ? 35 : 0);
    self.finshView = [[UIView alloc] initWithFrame:CGRectMake(0, 80, WXMPhoto_Width, finH)];
    self.finshView.backgroundColor = self.photoView.backgroundColor;
    
    self.line = [[UIView alloc] initWithFrame:CGRectMake(0, 80 - 0.5, WXMPhoto_Width, 0.5)];
    self.line.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.25];
    self.line.alpha = 0;
    
    self.collectionView.layoutCenterSupView = NO;
    [self addSubview:self.photoView];
    [self addSubview:self.finshView];
    [self addSubview:self.line];
    [self wp_setUpFinshView];
}

/** finshView */
- (void)wp_setUpFinshView {
    CGFloat height = 30;
    CGFloat heightFinash = 45;
    self.originalButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, height)];
    self.originalButton.tag = 100;
    
    UIImage *deImage = [UIImage imageNamed:@"photo_orwhite_de"];
    UIImage *seImage = [UIImage imageNamed:@"photo_orwhite_se"];
    [self.originalButton setImage:deImage forState:UIControlStateNormal];
    [self.originalButton setImage:seImage forState:UIControlStateSelected];
    [self.originalButton setTitle:@"  原图(0.00M)" forState:UIControlStateNormal];
    self.originalButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.originalButton.titleLabel.font = [UIFont systemFontOfSize:13];
    self.originalButton.left = 15;
    self.originalButton.hidden = !WXMPhotoSelectOriginal;
    self.originalButton.centerY = heightFinash / 2;
    [self.originalButton wp_setEnlargeEdgeWithTop:5 left:10 right:-120 bottom:0];
    [self.originalButton wp_addTarget:self action:@selector(originalTouchEvents:)];
    
    UIImage *images = [UIImage imageFromColor:WXMSelectedColor];
    UIImage *diaBleimages = [UIImage imageFromColor:WXMDisAbleColor];
    self.finishButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, height)];
    self.finishButton.layoutRight = 15;
    self.finishButton.centerY = heightFinash / 2 + 2;
    self.finishButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.finishButton setTitle:@"完成" forState:UIControlStateNormal];
    [self.finishButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.finishButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [self.finishButton setBackgroundImage:images forState:UIControlStateNormal];
    [self.finishButton setBackgroundImage:diaBleimages forState:UIControlStateDisabled];
    [self.finishButton wp_addTarget:self action:@selector(finishTouchEvents)];
    self.finishButton.layer.cornerRadius = 4;
    self.finishButton.layer.masksToBounds = YES;
    
    [self.finshView addSubview:self.originalButton];
    [self.finshView addSubview:self.finishButton];
}

/** 第一次加载 */
- (void)loadDictionaryArray:(WXMDictionary_Array *)dictionaryArray {
    WXMDictionary_Array *newDictionaryArray = [WXMDictionary_Array new];
    [dictionaryArray enumerateObjectsUsingBlock:^(WXMPhotoRecordModel* obj, NSUInteger idx, BOOL stop) {
        [newDictionaryArray addObject:obj];
    }];
    
    _allDictionaryArray = dictionaryArray;
    _dictionaryArray = newDictionaryArray;
    [self.collectionView reloadData];
    [self setFinashButtonCount:NO];
}

/** 新增一个 */
- (void)addPhotoRecordModel:(WXMDictionary_Array *)dictionaryArray {
    _dictionaryArray = dictionaryArray;
    UICollectionViewScrollPosition po = UICollectionViewScrollPositionCenteredHorizontally;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:dictionaryArray.count - 1 inSection:0];
    [_collectionView insertItemsAtIndexPaths:@[indexPath]];
    [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:po animated:YES];
    
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    cell.contentView.alpha = 0;
    cell.contentView.transform = CGAffineTransformMakeScale(.1, .1);
    [UIView animateWithDuration:0.35 animations:^{
        cell.contentView.alpha = 1;
        cell.contentView.transform = CGAffineTransformIdentity;
    }];
    [self setFinashButtonCount:(dictionaryArray.count == 1)];
}

/** 删除一个 */
- (void)deletePhotoRecordModel:(WXMDictionary_Array *)dictionaryArray {
    _dictionaryArray = dictionaryArray;
    CGFloat width = _collectionView.contentSizeWidth - WXMPhotoPreviewImageWH - 12;
    if (width < WXMPhoto_Width) {
        CGPoint point = CGPointMake(-_collectionView.contentInsetLeft, 0);
        [_collectionView setContentOffset:point animated:YES];
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(self.recordModel.recordRank - 1) inSection:0];
    [_collectionView deleteItemsAtIndexPaths:@[indexPath]];
    [self setFinashButtonCount:(dictionaryArray.count == 0)];
}

/** 滚动到那个记录的model */
- (void)setRecordModel:(WXMPhotoRecordModel *)recordModel {
    _recordModel = recordModel;
    WXMBottomBarCollectionViewCell *selectCell = nil;
    for (UIView *subView in self.collectionView.subviews) {
        if ([subView isKindOfClass:WXMBottomBarCollectionViewCell.class]) {
            WXMBottomBarCollectionViewCell * cell = (WXMBottomBarCollectionViewCell *)subView;
            cell.isSelected = (recordModel == cell.recordModel);
            if (cell.isSelected) selectCell = cell;
        }
    }
    
    UICollectionViewScrollPosition position = UICollectionViewScrollPositionCenteredHorizontally;
    if (selectCell == nil)  {
        NSInteger index = [self.dictionaryArray indexOfObject:recordModel];
        if (index < 0 || index >= self.dictionaryArray.count) return;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:position animated:NO];
    } else {
        NSIndexPath *indexPath = [_collectionView indexPathForCell:selectCell];
        [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:position animated:YES];
    }
}

/** 设置按钮 */
- (void)setFinashButtonCount:(BOOL)animations {
    NSString *title = self.allDictionaryArray.count ?
    [NSString stringWithFormat:@"完成(%ld)",self.allDictionaryArray.count] : @"完成";
    [self.finishButton setTitle:title forState:UIControlStateNormal];
    self.finishButton.width = (self.allDictionaryArray.count > 0) ? 70 : 60;
    self.finishButton.right = WXMPhoto_Width - 15;
    [UIView animateWithDuration:(animations ? 0.5 : 0) animations:^{
        self.line.alpha = (self.dictionaryArray.count > 0);
        self.photoView.alpha = (self.dictionaryArray.count > 0);
    }];
}

/** 显示资源文件的大小和类型 */
- (void)setRealImageByte:(NSString *)realImageByte video:(BOOL)video {
    _realImageByte = realImageByte;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *text = [NSString stringWithFormat:@"  原图 (%@)",realImageByte];
        if (video) {
            UIImage *veImage = [UIImage imageNamed:@"photo_videoOverlay19"];
            text = [NSString stringWithFormat:@"  视频 (%@)",realImageByte];
            [self.originalButton setImage:veImage forState:UIControlStateNormal];
            [self.originalButton setImage:veImage forState:UIControlStateSelected];
            self.originalButton.userInteractionEnabled = NO;
        } else {
            UIImage *deImage = [UIImage imageNamed:@"photo_orwhite_de"];
            UIImage *seImage = [UIImage imageNamed:@"photo_orwhite_se"];
            [self.originalButton setImage:deImage forState:UIControlStateNormal];
            [self.originalButton setImage:seImage forState:UIControlStateSelected];
            self.originalButton.userInteractionEnabled = YES;
        }
        [self.originalButton setTitle:text forState:UIControlStateNormal];
    });
}

- (void)setOriginalImage {
    self.originalButton.selected = YES;
    self.isOriginalImage = YES;
}

/** 原图选中 */
- (void)originalTouchEvents:(UIButton *)sender {
    sender.selected = !sender.selected;
    _isOriginalImage = sender.selected;
    [[NSNotificationCenter defaultCenter]
     postNotificationName:WXMPhoto_originalNoti object:@(_isOriginalImage).stringValue];
}

/** 完成按钮 */
- (void)finashButtonEnabled:(BOOL)enabled {
    _finishButton.enabled = enabled;
}

/** 完成按钮 */
- (void)finishTouchEvents {
    if (self.delegate && [self.delegate respondsToSelector:@selector(wp_touchButtomFinsh)]) {
        [self.delegate wp_touchButtomFinsh];
    }
}

/** 显示隐藏原图按钮 */
- (void)setShowOriginalButton:(BOOL)showOriginalButton{
    _showOriginalButton = showOriginalButton;
    self.originalButton.hidden = !showOriginalButton;
}

#pragma mark _____________________________________________UICollectionView dataSource
#pragma mark _____________________________________________UICollectionView dataSource
#pragma mark _____________________________________________UICollectionView dataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)sec {
    return self.dictionaryArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WXMBottomBarCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    WXMPhotoRecordModel *recordModel = [self.dictionaryArray objectAtIndex:indexPath.row];
    cell.recordModel = recordModel;
    cell.isSelected = (recordModel == self.recordModel);
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    WXMPhotoRecordModel *signModel = [self.dictionaryArray objectAtIndex:indexPath.row];
    
    /** 同一个相册的点击才会跳转 不同相册的没办法跳转 */
    if ([signModel.recordAlbumName isEqualToString: self.recordAlbumName])  {
        if (self.delegate && [self.delegate respondsToSelector:@selector(wp_touchButtomDidSelectItem:)]) {
            [self.delegate wp_touchButtomDidSelectItem:signModel.recordIndexPath];
        }
    } 
}

/** 显示隐藏 */
- (void)setAccordingState:(BOOL)state {
    if (state) self.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = state;
    }];
}

- (void)setSeletedIdx:(NSInteger)seletedIdx {
    _seletedIdx = seletedIdx;
    if (self.lastSeleIdx == -1) self.lastSeleIdx = seletedIdx;
    
    /** 翻页 */
    if (self.lastSeleIdx != seletedIdx) {
        [self.collectionView reloadData];
        self.lastSeleIdx = seletedIdx;
        WXMPhotoRecordModel *photoRecordModel = [self.dictionaryArray objectForKey:@(seletedIdx).stringValue];
        NSInteger idx = [self.dictionaryArray indexOfObject:photoRecordModel];
        UICollectionViewScrollPosition po = UICollectionViewScrollPositionCenteredHorizontally;
        if (idx >= 0) {
            NSIndexPath *inPath = [NSIndexPath indexPathForRow:idx inSection:0];
            [_collectionView scrollToItemAtIndexPath:inPath atScrollPosition:po animated:YES];
        }
    }
}

- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(WXMPhotoPreviewImageWH, WXMPhotoPreviewImageWH);
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        layout.minimumLineSpacing = 12;
        layout.minimumInteritemSpacing = 0;
        
        CGRect rect = CGRectMake(0, 0, WXMPhoto_Width, WXMPhotoPreviewImageWH);
        _collectionView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.bounces = YES;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.alwaysBounceVertical = NO;
        _collectionView.alwaysBounceHorizontal = YES;
        _collectionView.contentInset = UIEdgeInsetsMake(0, 10, 0, 10);
        [_collectionView registerClass:[WXMBottomBarCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    }
    return _collectionView;
}

@end

