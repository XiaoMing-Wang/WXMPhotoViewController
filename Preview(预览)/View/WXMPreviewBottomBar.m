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
@property (nonatomic, strong) UIView *line;

/** 上一次的个数 */
@property (nonatomic, assign) NSInteger lastCount;
@property (nonatomic, assign) BOOL isAnimation;
@end
@implementation WXMPreviewBottomBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) [self setupInterface];
    return self;
}

/** 初始化界面 */
- (void)setupInterface {
    CGFloat h = 125;
    CGFloat y = WXMPhoto_Height - h;
    self.frame = CGRectMake(0, y, WXMPhoto_Width, h);
    
    /** 上半部分预览 */
    _photoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WXMPhoto_Width, 80)];
    _photoView.backgroundColor = WXMPhoto_RGBColor(33, 33, 33);
    _photoView.alpha = 1;
    [_photoView addSubview:self.collectionView];
    
    /** 下半部分按钮 */
    _finshView = [[UIView alloc] initWithFrame:CGRectMake(0, 80, WXMPhoto_Width, h - 80)];
    _finshView.backgroundColor = WXMPhoto_RGBColor(33, 33, 33);
    
    _line = [[UIView alloc] initWithFrame:CGRectMake(0, 80 - 0.5, WXMPhoto_Width, 0.5)];
    _line.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.25];
    _line.alpha = 1;
    
    self.collectionView.layoutCenterSupView = NO;
    [self addSubview:_photoView];
    [self addSubview:_finshView];
    [self addSubview:_line];
    [self wxm_setUpFinshView];
}

/** finshView */
- (void)wxm_setUpFinshView {
    
    CGFloat height = 30;
    UIButton *originalbg = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, height)];
    originalbg.tag = 100;
    [originalbg setImage:[UIImage imageNamed:@"photo_original_def"] forState:UIControlStateNormal];
    [originalbg setImage:[UIImage imageNamed:@"photo_sign_background2"] forState:UIControlStateSelected];
    [originalbg setTitle:@"  原图(0.00M)" forState:UIControlStateNormal];
    originalbg.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    originalbg.titleLabel.font = [UIFont systemFontOfSize:15];
    originalbg.left = 15;
    originalbg.centerY = _finshView.height / 2;
    [originalbg wxm_addTarget:self action:@selector(originalTouchEvents:)];
    
    UIButton * finishButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, height)];
    finishButton.layoutRight = 15;
    finishButton.centerY = _finshView.height / 2;
    finishButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [finishButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [finishButton setTitle:@"完成" forState:UIControlStateNormal];
    finishButton.backgroundColor = WXMSelectedColor;
    finishButton.layer.cornerRadius = 4;
    [finishButton wxm_addTarget:self action:@selector(finishTouchEvents)];
    
    [_finshView addSubview:originalbg];
    [_finshView addSubview:finishButton];
}

/** 原图选中 */
- (void)originalTouchEvents:(UIButton *)sender {
    sender.selected = !sender.selected;
    _isOriginalImage = sender.selected;
}

/** 完成按钮 */
- (void)finishTouchEvents {
    if (self.delegate && [self.delegate respondsToSelector:@selector(wxm_touchButtomFinsh)]) {
        [self.delegate wxm_touchButtomFinsh];
    }
}

/** 显示隐藏原图按钮 */
- (void)setIsShowOriginalButton:(BOOL)isShowOriginalButton {
    _isShowOriginalButton = isShowOriginalButton;
    [self.finshView viewWithTag:100].hidden = !isShowOriginalButton;
}

/** 更新原图大小 */
- (void)setRealImageByte:(NSString *)realImageByte {
    _realImageByte = realImageByte;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIButton *originalbg = [self.finshView viewWithTag:100];
        NSString *text = [NSString stringWithFormat:@"  原图（%@）",realImageByte];
        [originalbg setTitle:text forState:UIControlStateNormal];
    });
}

/** 赋值 */
- (void)setSignObj:(WXMDictionary_Array *)signObj {
    _signObj = signObj;
    _line.alpha = (signObj.count > 0);
    _photoView.alpha = (signObj.count > 0);
    [self.collectionView reloadData];
    [self.collectionView layoutIfNeeded];
    [self animateCollection];
    self.lastCount = _signObj.count;
}

- (void)animateCollection {
    
    if (self.lastCount == 0 || _signObj.count == 0 || _isAnimation) return;
    NSArray *cells = _collectionView.visibleCells;
    for (UICollectionViewCell *cell in cells) {
        NSInteger idex = [self.collectionView indexPathForCell:cell].row;
        
        /** 增加 */
        if (cells.count >= self.lastCount && (idex == cells.count - 1)) {
            cell.contentView.alpha = 0;
            cell.contentView.transform = CGAffineTransformMakeScale(.1, .1);
            [UIView animateWithDuration:0.25 animations:^{
                cell.contentView.alpha = 1;
                cell.contentView.transform = CGAffineTransformIdentity;
            }];
            break;
        }
        
        /** 减少 */
        else if (cells.count < self.lastCount && idex >= 1) {
            cell.contentView.left = WXMPhotoPreviewImageWH + 12;
            [UIView animateWithDuration:0.35 animations:^{
                cell.contentView.left = 0;
            }];
        }
        
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.isAnimation = NO;
    });
}

#pragma mark _____________________________________________UICollectionView dataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.signObj.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionView *cv = collectionView;
    NSIndexPath *ip = indexPath;
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:ip];
    UIImageView * content = [cell.contentView viewWithTag:10086];
    if (!content) {
        content = [self createImageView];
        [cell.contentView addSubview:content];
    }
    
    content.layer.borderColor = [UIColor clearColor].CGColor;
    WXMPhotoSignModel * signModel = [self.signObj objectAtIndex:indexPath.row];
    content.image = signModel.image;
    if (self.seletedIdx == signModel.indexPath.row) {
        content.layer.borderColor = WXMSelectedColor.CGColor;
    }
    return cell;
}

/** 显示隐藏 */
- (void)setAccordingState:(BOOL)state {
    if (state) self.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = state;
    }];
}

/**  */
- (void)setSeletedIdx:(NSInteger)seletedIdx {
    _seletedIdx = seletedIdx;
    [self.collectionView reloadData];
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
    imageView.layer.borderColor = WXMSelectedColor.CGColor;
    imageView.tag = 10086;
    return imageView;
}
@end
