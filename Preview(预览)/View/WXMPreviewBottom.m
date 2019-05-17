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
@property (nonatomic, strong) UIScrollView *photoView;
@property (nonatomic, strong) UIView *actionView;
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
    
    _photoView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, WXMPhoto_Width, 80)];
    _photoView.backgroundColor = WXMPhoto_RGBColor(33, 33, 33);
    _photoView.alpha = 0;
    
    _actionView = [[UIView alloc] initWithFrame:CGRectMake(0, 80, WXMPhoto_Width, h - 80)];
    _actionView.backgroundColor = WXMPhoto_RGBColor(33, 33, 33);
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 80 - 0.5, WXMPhoto_Width, 0.5)];
    line.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.25];
    
    [self addSubview:_photoView];
    [self addSubview:_actionView];
    [_photoView addSubview:line];
    [self setUpActionView];
}
/** ActionView */
- (void)setUpActionView {
    CGFloat x = WXMPhoto_Width - 60 - 10;
    UIButton * finish = [[UIButton alloc] initWithFrame:CGRectMake(x, 7.5, 60, 30)];
    finish.titleLabel.font = [UIFont systemFontOfSize:13];
    [finish setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [finish setTitle:@"完成" forState:UIControlStateNormal];
    finish.backgroundColor = WXMSelectedColor;
    finish.layer.cornerRadius = 4;
    [finish addTarget:self action:@selector(finish) forControlEvents:UIControlEventTouchUpInside];
    [_actionView addSubview:finish];
}

/** 完成按钮 */
- (void)finish {
    if (self.delegate && [self.delegate respondsToSelector:@selector(wxm_touchButtomFinsh)]) {
        [self.delegate wxm_touchButtomFinsh];
    }
}
- (void)setSignDictionary:(NSMutableDictionary *)signDictionary {
    _signDictionary = signDictionary;
    [self setUpPhotoView:signDictionary];
    if (!self.wxm_loadFinsh) [self setUpPhotoView:signDictionary];
    if (self.wxm_loadFinsh) [self sortingUpPhotoView];
}

/** 初始化相册 */
- (void)setUpPhotoView:(NSDictionary *)dic {
    if (self.wxm_loadFinsh) return;
    [dic enumerateKeysAndObjectsUsingBlock:^(NSString* key, WXMPhotoSignModel* obj, BOOL *stop) {
        CGFloat x = (12 * obj.rank) + 53 * (obj.rank - 1);
        UIImageView * imgView = [self createImageView];
        imgView.frame = CGRectMake(x, 0, 53, 53);
        imgView.center = CGPointMake(imgView.center.x, self.photoView.frame.size.height / 2);
        imgView.tag = obj.rank;
        imgView.image = obj.image;
        [self.rankDictionary setObject:@(obj.rank).stringValue forKey:key];
    }];
    self.wxm_loadFinsh = YES;
    self.photoView.alpha = (self.signDictionary.allKeys.count > 0);
}
/** 排序 */
- (void)sortingUpPhotoView {
    [UIView animateWithDuration:0.75 animations:^{
        self.photoView.alpha = (self.signDictionary.allKeys.count > 0);
    }];
    
    /** 增加了一个 */
    if (self.signDictionary.allKeys.count > self.rankDictionary.allKeys.count) {
        NSString * ketString = [self increaseSignModel];
        WXMPhotoSignModel* obj = [self.signDictionary objectForKey:ketString];
        NSInteger current = obj.rank;
        CGFloat x = (12 * current) + 53 * (current - 1);
        UIImageView * imgView = [self createImageView];
        imgView.frame = CGRectMake(x, 0, 53, 53);
        imgView.alpha = 0;
        imgView.image = obj.image;
        imgView.tag = obj.rank;
        imgView.layer.borderColor = WXMSelectedColor.CGColor;
        imgView.center = CGPointMake(imgView.center.x, self.photoView.frame.size.height / 2);
        [self.rankDictionary setObject:@(obj.rank).stringValue forKey:ketString];
        [UIView animateWithDuration:0.35 animations:^{ imgView.alpha = 1;  }];
        
        /** 去掉了一个 */
    } else if (self.signDictionary.allKeys.count < self.rankDictionary.allKeys.count) {
        NSString * ketString = [self removeSignModel];
        NSString * rankString = [self.rankDictionary objectForKey:ketString];
        [self.rankDictionary removeObjectForKey:ketString];
        [self synchronouRank];
        NSInteger rank = rankString.integerValue;
        for (int i = 1; i <= 4; i++) {
            UIImageView * imgView = [self.photoView viewWithTag:i];
            if (imgView.tag == rank && imgView) [imgView removeFromSuperview];
            if (imgView.tag > rank  && imgView) {
                [UIView animateWithDuration:0.45 animations:^{
                    imgView.tag = imgView.tag - 1;
                    CGFloat x = (12 * imgView.tag) + 53 * (imgView.tag - 1);
                    imgView.frame = CGRectMake(x, 27 / 2, 53, 53);
                }];
            }
        }
    }
}

/**  */
- (UIImageView *)createImageView {
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    imageView.clipsToBounds = YES;
    imageView.layer.borderWidth = 1;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.photoView addSubview:imageView];
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
    for (int i = 1; i <= 4; i++) {
        UIImageView * imgView = [self.photoView viewWithTag:i];
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
