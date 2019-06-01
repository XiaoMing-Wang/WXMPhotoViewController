//
//  WXMPreviewBottom.m
//  ModuleDebugging
//
//  Created by edz on 2019/5/13.
//  Copyright © 2019年 wq. All rights reserved.
//
#import "WXMPhotoConfiguration.h"
#import "WXMPreviewBottom.h"
#import "WXMPhotoSignModel.h"

@interface WXMPreviewBottom ()
@property (nonatomic, strong) UIScrollView *photoScrollView;
@property (nonatomic, strong) UIView *finshView;
@property (nonatomic, strong) UIView *line;
@property (nonatomic, strong) UIImageView * iconImgView;
@property (nonatomic, strong) UILabel * textLabel;

@property (nonatomic, assign) BOOL wxm_loadFinsh;
@property (nonatomic, strong) NSMutableDictionary *rankDictionary;
@end
@implementation WXMPreviewBottom

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) [self setupInterface];
    return self;
}

/** 初始化界面 */
- (void)setupInterface {
    CGFloat h = 125;
    CGFloat y = WXMPhoto_Height - h;
    self.frame = CGRectMake(0, y, WXMPhoto_Width, h);
    _rankDictionary = @{}.mutableCopy;
    
    /** 上半部分预览 */
    _photoScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, WXMPhoto_Width, 80)];
    _photoScrollView.backgroundColor = WXMPhoto_RGBColor(33, 33, 33);
    _photoScrollView.showsHorizontalScrollIndicator = NO;
    _photoScrollView.showsVerticalScrollIndicator = NO;
    _photoScrollView.alpha = 0;
    
    /** 下半部分按钮 */
    _finshView = [[UIView alloc] initWithFrame:CGRectMake(0, 80, WXMPhoto_Width, h - 80)];
    _finshView.backgroundColor = WXMPhoto_RGBColor(33, 33, 33);
    
    _line = [[UIView alloc] initWithFrame:CGRectMake(0, 80 - 0.5, WXMPhoto_Width, 0.5)];
    _line.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.25];
    _line.alpha = 0;
    
    [self addSubview:_photoScrollView];
    [self addSubview:_finshView];
    [self addSubview:_line];
    [self setUpFinshView];
}

/** finshView */
- (void)setUpFinshView {
    CGFloat height = 30;
    UIButton *originalbg = [[UIButton alloc] initWithFrame:CGRectMake(15, 7.5, 200, height)];
    originalbg.tag = 11;
    [originalbg addTarget:self action:@selector(original:) forControlEvents:UIControlEventTouchUpInside];
    _iconImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    _iconImgView.image = [UIImage imageNamed:@"photo_original_def"];
    _iconImgView.center = CGPointMake(_iconImgView.center.x, height / 2);
    
    _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(27, 0, 150, height)];
    _textLabel.textColor = [UIColor whiteColor];
    _textLabel.font = [UIFont systemFontOfSize:15];
    _textLabel.text = @"原图(1.34M)";
    [originalbg addSubview:_iconImgView];
    [originalbg addSubview:_textLabel];
    
    CGFloat x = WXMPhoto_Width - 60 - 15;
    UIButton * finish = [[UIButton alloc] initWithFrame:CGRectMake(x, 7.5, 60, height)];
    finish.titleLabel.font = [UIFont systemFontOfSize:13];
    [finish setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [finish setTitle:@"完成" forState:UIControlStateNormal];
    finish.backgroundColor = WXMSelectedColor;
    finish.layer.cornerRadius = 4;
    [finish addTarget:self action:@selector(finish) forControlEvents:UIControlEventTouchUpInside];
    
    [_finshView addSubview:originalbg];
    [_finshView addSubview:finish];
}

/** 原图选中 */
- (void)original:(UIButton *)sender {
    sender.selected = !sender.selected;
    _iconImgView.image = [UIImage imageNamed:@"photo_original_def"];
    if (sender.selected) {
        _iconImgView.image = [UIImage imageNamed:@"photo_sign_background"];
    }
}

/** 完成按钮 */
- (void)finish {
    if (self.delegate && [self.delegate respondsToSelector:@selector(wxm_touchButtomFinsh)]) {
        [self.delegate wxm_touchButtomFinsh];
    }
}

/** 赋值 */
- (void)setSignDictionary:(NSMutableDictionary *)signDictionary {
    _signDictionary = signDictionary;
    [self setUpPhotoView:signDictionary];
    if (!self.wxm_loadFinsh) [self setUpPhotoView:signDictionary];
    if (self.wxm_loadFinsh) [self sortingUpPhotoView];
}

- (void)setRealImageByte:(NSString *)realImageByte {
    dispatch_async(dispatch_get_main_queue(), ^{
        _realImageByte = realImageByte;
        _textLabel.text = [NSString stringWithFormat:@"原图（%@）",realImageByte];
    });
}

/** 初始化相册 */
- (void)setUpPhotoView:(NSDictionary *)dic {
    if (self.wxm_loadFinsh) return;
    [dic enumerateKeysAndObjectsUsingBlock:^(NSString* key, WXMPhotoSignModel* obj, BOOL *stop) {
        CGFloat x = (12 * obj.rank) + WXMPhotoPreviewImageWH * (obj.rank - 1);
        UIImageView * imgView = [self createImageView];
        imgView.frame = CGRectMake(x, 0, WXMPhotoPreviewImageWH, WXMPhotoPreviewImageWH);
        imgView.center = CGPointMake(imgView.center.x, self.photoScrollView.frame.size.height / 2);
        imgView.tag = obj.rank;
        imgView.image = obj.image;
        [self.rankDictionary setObject:@(obj.rank).stringValue forKey:key];
    }];
    self.wxm_loadFinsh = YES;
    self.photoScrollView.alpha = (self.signDictionary.allKeys.count > 0);
}

/** 排序 */
- (void)sortingUpPhotoView {
    CGFloat w = self.photoScrollView.bounds.size.width;
    [UIView animateWithDuration:0.75 animations:^{
        NSInteger count = self.signDictionary.allKeys.count;
        self.photoScrollView.contentSize = CGSizeMake(count *(WXMPhotoPreviewImageWH + 12) + 20, 0);
        self.photoScrollView.alpha = (self.signDictionary.allKeys.count > 0);
        self.line.alpha = self.photoScrollView.alpha;
    }];
    
    /** 增加了一个 */
    if (self.signDictionary.allKeys.count > self.rankDictionary.allKeys.count) {
        NSString * ketString = [self increaseSignModel];
        WXMPhotoSignModel* obj = [self.signDictionary objectForKey:ketString];
        NSInteger current = obj.rank;
        CGFloat x = (12 * current) + WXMPhotoPreviewImageWH * (current - 1);
        UIImageView * imgView = [self createImageView];
        imgView.frame = CGRectMake(x, 0, WXMPhotoPreviewImageWH, WXMPhotoPreviewImageWH);
        imgView.alpha = 0;
        imgView.image = obj.image;
        imgView.tag = obj.rank;
        imgView.layer.borderColor = WXMSelectedColor.CGColor;
        imgView.center = CGPointMake(imgView.center.x, self.photoScrollView.frame.size.height / 2);
        [self.rankDictionary setObject:@(obj.rank).stringValue forKey:ketString];
        
        /**  滚动到最后面  */
        CGPoint offset = CGPointMake(MAX(self.photoScrollView.contentSize.width - w, 0), 0);
        [UIView animateWithDuration:0.35 animations:^{
            imgView.alpha = 1;
            [self.photoScrollView setContentOffset:offset animated:NO];
        }];
        
    /** 去掉了一个 */
    } else if (self.signDictionary.allKeys.count < self.rankDictionary.allKeys.count) {
        NSString * ketString = [self removeSignModel];
        NSString * rankString = [self.rankDictionary objectForKey:ketString];
        [self.rankDictionary removeObjectForKey:ketString];
        [self synchronouRank];
        NSInteger rank = rankString.integerValue;
        
        for (int i = 1; i <= WXMMultiSelectMax; i++) {
            UIImageView * imgView = [self.photoScrollView viewWithTag:i];
            if (imgView.tag == rank && imgView) [imgView removeFromSuperview];
            if (imgView.tag > rank  && imgView) {
                [UIView animateWithDuration:0.45 animations:^{
                    imgView.tag = imgView.tag - 1;
                    CGFloat x = (12 * imgView.tag) + WXMPhotoPreviewImageWH * (imgView.tag - 1);
                    imgView.frame = CGRectMake(x, 0, WXMPhotoPreviewImageWH, WXMPhotoPreviewImageWH);
                    imgView.center = CGPointMake(imgView.center.x, self.photoScrollView.frame.size.height / 2);
                }];
            }
        }
    }
}

/** 创建预览imageview */
- (UIImageView *)createImageView {
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    imageView.clipsToBounds = YES;
    imageView.layer.borderWidth = 1;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.photoScrollView addSubview:imageView];
    return imageView;
}

/** 判断增加的是哪一个 */
- (NSString *)increaseSignModel {
    __block NSString* increaseObj = nil;
    [_signDictionary enumerateKeysAndObjectsUsingBlock:^(NSString* key, WXMPhotoSignModel* obj, BOOL *stop) {
        if (![self.rankDictionary.allKeys containsObject:key])  {
            increaseObj = key;
            *stop = YES;
        }
    }];
    return increaseObj;
}

/** 判断删除的是哪一个 */
- (NSString *)removeSignModel {
    __block NSString* removeObj = nil;
    [_rankDictionary enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSString* obj, BOOL *stop) {
        if (![self.signDictionary.allKeys containsObject:key])  {
            removeObj = key;
            *stop = YES;
        }
    }];
    return removeObj;
}

/** 同步数据 */
- (void)synchronouRank {
    [_signDictionary enumerateKeysAndObjectsUsingBlock:^(NSString* key, WXMPhotoSignModel* obj, BOOL *stop) {
        [self.rankDictionary setObject:@(obj.rank).stringValue forKey:key];
    }];
}

/** 当前选中的 */
- (void)setSeletedIdx:(NSInteger)seletedIdx {
    _seletedIdx = seletedIdx;
    NSInteger sele = [[self.rankDictionary objectForKey:@(seletedIdx).stringValue] integerValue];
    for (int i = 1; i <= WXMMultiSelectMax; i++) {
        UIImageView * imgView = [self.photoScrollView viewWithTag:i];
        if (imgView) {
            imgView.layer.borderWidth = 1;
            imgView.layer.borderColor = [UIColor clearColor].CGColor;
            if (sele == i) imgView.layer.borderColor = WXMSelectedColor.CGColor;
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
@end
