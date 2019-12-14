//
//  WXMPreviewBottom.m
//  ModuleDebugging
//
//  Created by edz on 2019/5/13.
//  Copyright © 2019年 wq. All rights reserved.
//
#import "WXMPhotoConfiguration.h"
#import "WXMPreviewBottomBar.h"
#import "WXMPhotoSignModel.h"

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
@end

@implementation WXMPreviewBottomBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) [self setupInterface];
    return self;
}

/** 初始化界面 */
- (void)setupInterface {
    CGFloat h = 125;
    CGFloat y = WXMPhoto_Height - h - (kDevice_Is_iPhoneX ? 35 : 0);
    self.frame = CGRectMake(0, y, WXMPhoto_Width, h);
    self.lastSeleIdx = -1;
    
    /** 上半部分预览 */
    _photoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WXMPhoto_Width, 80)];
    _photoView.backgroundColor = WXMPhotoPreviewbarColor;
    _photoView.alpha = 0;
    [_photoView addSubview:self.collectionView];
    
    /** 下半部分按钮 */
    CGFloat finH = h - 80 + (kDevice_Is_iPhoneX ? 35 : 0);
    _finshView = [[UIView alloc] initWithFrame:CGRectMake(0, 80, WXMPhoto_Width, finH)];
    _finshView.backgroundColor = _photoView.backgroundColor;
    
    _line = [[UIView alloc] initWithFrame:CGRectMake(0, 80 - 0.5, WXMPhoto_Width, 0.5)];
    _line.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.25];
    _line.alpha = 0;
    
    self.collectionView.layoutCenterSupView = NO;
    [self addSubview:_photoView];
    [self addSubview:_finshView];
    [self addSubview:_line];
    [self wxm_setUpFinshView];
}

/** finshView */
- (void)wxm_setUpFinshView {
    
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
    [self.originalButton wxm_setEnlargeEdgeWithTop:5 left:10 right:-120 bottom:0];
    [self.originalButton wxm_addTarget:self action:@selector(originalTouchEvents:)];
    
    self.finishButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, height)];
    self.finishButton.layoutRight = 15;
    self.finishButton.centerY = heightFinash / 2 + 2;
    self.finishButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.finishButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.finishButton setTitle:@"完成" forState:UIControlStateNormal];
    self.finishButton.backgroundColor = WXMSelectedColor;
    self.finishButton.layer.cornerRadius = 4;
    [self.finishButton wxm_addTarget:self action:@selector(finishTouchEvents)];
    
    [self.finshView addSubview:self.originalButton];
    [self.finshView addSubview:self.finishButton];
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
- (void)finishTouchEvents {
    if (self.delegate && [self.delegate respondsToSelector:@selector(wxm_touchButtomFinsh)]) {
        [self.delegate wxm_touchButtomFinsh];
    }
}

/** 显示隐藏原图按钮 */
- (void)setShowOriginalButton:(BOOL)showOriginalButton{
    _showOriginalButton = showOriginalButton;
    self.originalButton.hidden = !showOriginalButton;
}

/** 更新原图大小 */
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

/** 赋值 0=增加 >0删除 -1刷新 */
- (void)setSignObj:(WXMDictionary_Array *)signObj removeIdx:(NSInteger)idx {
    _signObj = signObj;
    NSString *title = signObj.count ?
    [NSString stringWithFormat:@"完成(%ld)",signObj.count] : @"完成";
    
    [self.finishButton setTitle:title forState:UIControlStateNormal];
    [UIView animateWithDuration:((idx > 0) ? 0.5 : 0) animations:^{
        self.line.alpha = (signObj.count > 0);
        self.photoView.alpha = (signObj.count > 0);
    }];
    
    if (idx == -1) {
        [self.collectionView reloadData];
    } else if (idx == 0) {
        UICollectionViewCell *lastCell = nil;
        CGColorRef black = [UIColor clearColor].CGColor;
        UICollectionViewScrollPosition po = UICollectionViewScrollPositionCenteredHorizontally;
        
        lastCell = [self.collectionView cellForItemAtIndexPath:_lastIndexPath];;
        [lastCell.contentView viewWithTag:10086].layer.borderColor = black;
                
        NSInteger changeRow = MAX((signObj.count - 1), 0);
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:changeRow inSection:0];
        [_collectionView insertItemsAtIndexPaths:@[indexPath]];
        [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:po animated:YES];
        
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        cell.contentView.alpha = 0;
        cell.contentView.transform = CGAffineTransformMakeScale(.1, .1);
        CGFloat duration = (signObj.count - 1 == 0) ? 0 : 0.35;
        [UIView animateWithDuration:duration animations:^{
            cell.contentView.alpha = 1;
            cell.contentView.transform = CGAffineTransformIdentity;
        }];
    } else if (idx > 0) {
        CGFloat width = _collectionView.contentSizeWidth - WXMPhotoPreviewImageWH - 12;
        if (width < WXMPhoto_Width) {
            CGPoint point = CGPointMake(-_collectionView.contentInsetLeft, 0);
            [_collectionView setContentOffset:point animated:YES];
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx - 1 inSection:0];
        [_collectionView deleteItemsAtIndexPaths:@[indexPath]];
    }
}

#pragma mark _____________________________________________UICollectionView dataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.signObj.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    WXMPhotoSignModel * signModel = [self.signObj objectAtIndex:indexPath.row];
    UIImageView * imageView = [cell.contentView viewWithTag:10086];
    if (!imageView) {
        imageView = [self createImageView];
        [cell.contentView addSubview:imageView];
    }
    imageView.image = signModel.image;
    imageView.layer.borderColor = [UIColor clearColor].CGColor;
    if (self.seletedIdx == signModel.indexPath.row) {
        self.lastIndexPath = indexPath;
        imageView.layer.borderColor = WXMSelectedColor.CGColor;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    WXMPhotoSignModel * signModel = [self.signObj objectAtIndex:indexPath.row];
    SEL sel = @selector(wxm_touchButtomDidSelectItem:);
    if (self.delegate && [self.delegate respondsToSelector:sel]) {
        [self.delegate wxm_touchButtomDidSelectItem:signModel.indexPath];
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
        WXMPhotoSignModel * signModel = [self.signObj objectForKey:@(seletedIdx).stringValue];
        NSInteger idx = [self.signObj indexOfObject:signModel];
        UICollectionViewScrollPosition po= UICollectionViewScrollPositionCenteredHorizontally;
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
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    }
    return _collectionView;
}

/** 创建预览imageview */
- (UIImageView *)createImageView {
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    imageView.clipsToBounds = YES;
    imageView.size = CGSizeMake(WXMPhotoPreviewImageWH, WXMPhotoPreviewImageWH);
    imageView.layer.borderWidth = 1.5;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.layer.borderColor = [UIColor clearColor].CGColor;
    imageView.tag = 10086;
    return imageView;
}
@end

