//
//  WXMPhotoDetailToolbar.m
//  Multi-project-coordination
//
//  Created by wq on 2019/6/8.
//  Copyright © 2019年 wxm. All rights reserved.
//
#define WXMPhoto_DTextColor [WXMPhotoDetailToolbarTextColor colorWithAlphaComponent:0.6]
#define WXMPhoto_DSureColor [WXMSelectedColor colorWithAlphaComponent:1]
#import "WXMPhotoDetailToolbar.h"
#import "WXMPhotoConfiguration.h"
#import "UIImage+WXMPhoto.h"
#import "WXMPhotoRecordModel.h"

@interface WXMPhotoDetailToolbar ()
@property (nonatomic, strong) UIButton *previewButton;
@property (nonatomic, strong) UIButton *completeButton;
@property (nonatomic, strong) UILabel *photoNumber;
@property (nonatomic, strong) UIButton *originalImageButton;
@property (nonatomic, assign, readwrite) BOOL isOriginalImage;
@property (nonatomic, strong) UIView *cylindrical;
@property (nonatomic, strong) UIView *originalVew;
@property (nonatomic, strong) UILabel *originaSize;
@end

@implementation WXMPhotoDetailToolbar

/** 初始化 */
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) [self setupInterface];
    return self;
}

- (void)setupInterface {
    CGFloat height = kIPhoneX ? 80 : 45;
    CGFloat coHeight = 45;
    CGFloat iconWH = WXMSelectedWH;
    self.frame = CGRectMake(0, WXMPhoto_Height - height, WXMPhoto_Width, height);
    self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0];
    
    self.previewButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 3, 60, coHeight - 3)];
    self.previewButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.previewButton.titleLabel.font = [UIFont systemFontOfSize:17];
    self.previewButton.left = 14;
    self.previewButton.enabled = NO;
    [self.previewButton setTitleColor:WXMPhotoDetailToolbarTextColor forState:0];
    [self.previewButton setTitleColor:WXMPhoto_DTextColor forState:UIControlStateDisabled];
    [self.previewButton setTitle:@"预览" forState:UIControlStateNormal];
    [self.previewButton wp_addTarget:self action:@selector(previewEvent)];
    [self.previewButton wp_setEnlargeEdgeWithTop:3 left:14 right:10 bottom:5];
    
    UIImage *images = [UIImage imageFromColor:WXMSelectedColor];
    self.completeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.completeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.completeButton.titleLabel.font = [UIFont systemFontOfSize:17];
    self.completeButton.enabled = NO;
    [self.completeButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [self.completeButton setTitleColor:UIColor.whiteColor forState:UIControlStateDisabled];
    [self.completeButton setBackgroundImage:images forState:UIControlStateNormal];
    [self.completeButton setTitle:@"完成" forState:UIControlStateNormal];
    [self.completeButton wp_addTarget:self action:@selector(dismissController)];
    [self.completeButton wp_setEnlargeEdgeWithTop:3 left:15 right:14 bottom:5];
    self.completeButton.height = 30;
    self.completeButton.width = 60;
    self.completeButton.right = WXMPhoto_Width - 15;
    self.completeButton.layer.cornerRadius = 4;
    self.completeButton.layer.masksToBounds = YES;
    self.completeButton.centerY = self.previewButton.centerY;
    
    self.photoNumber = [[UILabel alloc] initWithFrame:CGRectMake(0,0,iconWH, iconWH)];
    self.photoNumber.text = @"0";
    self.photoNumber.font = [UIFont systemFontOfSize:14];
    self.photoNumber.textColor = [UIColor whiteColor];
    self.photoNumber.numberOfLines = 1;
    self.photoNumber.layer.cornerRadius = _photoNumber.width / 2;
    self.photoNumber.layer.masksToBounds = YES;
    self.photoNumber.right = self.completeButton.left - 5;
    self.photoNumber.centerY = self.completeButton.centerY;
    self.photoNumber.backgroundColor = WXMSelectedColor;
    self.photoNumber.textAlignment = NSTextAlignmentCenter;
    self.photoNumber.hidden = YES;
    
    [self addSubview:self.previewButton];
    [self addSubview:self.completeButton];
    [self addSubview:self.originalImageButton];
    
    self.userInteractionEnabled = YES;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, -0.2);
    self.layer.shadowOpacity = 0.2;
    self.layer.shadowRadius = 0.1;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(originalNoti:) name:WXMPhoto_originalNoti object:nil];
}

/** 原图通知 */
- (void)originalNoti:(NSNotification *)notice {
    BOOL origina = [notice.object boolValue];
    self.isOriginalImage = origina;
    self.originalImageButton.selected = origina;
}

/** 预览按钮  */
- (void)previewEvent {
    if ([self.delegate respondsToSelector:@selector(wp_touchPreviewControl)]) {
        [self.delegate wp_touchPreviewControl];
    }
}

- (void)dismissController {
    if ([self.delegate respondsToSelector:@selector(wp_touchDismissViewController)]) {
        [self.delegate wp_touchDismissViewController];
    }
}

- (void)setDictionaryArray:(WXMDictionary_Array *)dictionaryArray {
    _dictionaryArray = dictionaryArray;
    _photoNumber.hidden = (_dictionaryArray.count <= 0);
    _completeButton.enabled = (_dictionaryArray.count > 0);
    _previewButton.enabled = NO;
    [dictionaryArray enumerateObjectsUsingBlock:^(WXMPhotoRecordModel *obj, NSUInteger idx, BOOL stop) {
        if ([obj.recordAlbumName isEqualToString:self.albumName]) {
            self.previewButton.enabled = YES;
            stop = YES;
        }
    }];
        
    if (_dictionaryArray.count == 0) {
        self.completeButton.width = 60;
        [self.completeButton setTitle:@"完成" forState:UIControlStateNormal];
    } else {
        self.completeButton.width = 70;
        NSString *title = [NSString stringWithFormat:@"完成(%zd)", _dictionaryArray.count];
        [self.completeButton setTitle:title forState:UIControlStateNormal];
    }
    self.completeButton.right = WXMPhoto_Width - 14;
}

/** 设置 */
- (void)setOriginalEnabled:(BOOL)originalEnabled {
    _originalEnabled = originalEnabled;
    _originalImageButton.enabled = originalEnabled;
    if (originalEnabled == NO) _originalImageButton.selected = NO;
}

/** 点击事件 */
- (void)originalEvent:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.isOriginalImage = sender.selected;
}

- (UIButton *)originalImageButton {
    if (!_originalImageButton) {
        _originalImageButton = [[UIButton alloc] init];
        _originalImageButton.size = CGSizeMake(80, 42);
        _originalImageButton.titleLabel.font = [UIFont systemFontOfSize:15];
        _originalImageButton.centerX = self.width / 2;
        _originalImageButton.top = 3;
        _originalImageButton.hidden = !WXMPhotoSelectOriginal;
        [_originalImageButton setTitle:@"  原图" forState:UIControlStateNormal];
        [_originalImageButton wp_addTarget:self action:@selector(originalEvent:)];
        
        UIImage *defImage = [UIImage imageNamed:@"photo_original_def"];
        UIImage *seleImage = [UIImage imageNamed:@"photo_original_selected"];
        [_originalImageButton setTitleColor:WXMPhotoDetailToolbarTextColor forState:0];
        [_originalImageButton setTitleColor:WXMPhoto_DTextColor forState:0];
        [_originalImageButton setImage:defImage forState:UIControlStateNormal];
        [_originalImageButton setImage:defImage forState:UIControlStateHighlighted];
        [_originalImageButton setImage:seleImage forState:UIControlStateSelected];
    }
    return _originalImageButton;
}

@end
