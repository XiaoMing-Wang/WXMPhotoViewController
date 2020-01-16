//
//  WXMPhotoDetailToolbar.m
//  Multi-project-coordination
//
//  Created by wq on 2019/6/8.
//  Copyright © 2019年 wxm. All rights reserved.
//
#define WXMPhoto_DTextColor [WXMPhotoDetailToolbarTextColor colorWithAlphaComponent:0.6]
#define WXMPhoto_DSureColor [WXMSelectedColor colorWithAlphaComponent:0.6]
#import "WXMPhotoDetailToolbar.h"
#import "WXMPhotoConfiguration.h"

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
    self.backgroundColor = [UIColor clearColor];
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:self.bounds];
    toolBar.backgroundColor = WXMPhotoDetailToolbarColor;
    
    self.previewButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 3, 60, coHeight - 3)];
    self.previewButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.previewButton.titleLabel.font = [UIFont systemFontOfSize:16.5];
    self.previewButton.left = 14;
    self.previewButton.enabled = NO;
    [self.previewButton setTitleColor:WXMPhotoDetailToolbarTextColor forState:0];
    [self.previewButton setTitleColor:WXMPhoto_DTextColor forState:UIControlStateDisabled];
    [self.previewButton setTitle:@"预览" forState:UIControlStateNormal];
    [self.previewButton wc_addTarget:self action:@selector(previewEvent)];
    [self.previewButton wc_setEnlargeEdgeWithTop:3 left:14 right:10 bottom:5];
    
    self.completeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 3, 0, coHeight - 3)];
    self.completeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    self.completeButton.titleLabel.font = [UIFont systemFontOfSize:16.5];
    self.completeButton.enabled = NO;
    [self.completeButton setTitleColor:WXMSelectedColor forState:UIControlStateNormal];
    [self.completeButton setTitleColor:WXMPhoto_DSureColor forState:UIControlStateDisabled];
    [self.completeButton setTitle:@"完成" forState:UIControlStateNormal];
    [self.completeButton sizeToFit];
    [self.completeButton wc_addTarget:self action:@selector(dismissController)];
    [self.completeButton wc_setEnlargeEdgeWithTop:3 left:15 right:14 bottom:5];
    self.completeButton.right = WXMPhoto_Width - 14;
    self.completeButton.height = coHeight - 3;
    self.completeButton.top = self.previewButton.top;
    
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
    
    [self addSubview:toolBar];
    [self addSubview:self.previewButton];
    [self addSubview:self.completeButton];
    [self addSubview:self.photoNumber];
    [self addSubview:self.originalImageButton];
    self.userInteractionEnabled = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(originalNoti:)
                                                 name:WXMPhoto_originalNoti
                                               object:nil];
    
}

/** 原图通知 */
- (void)originalNoti:(NSNotification *)notice {
    BOOL origina = [notice.object boolValue];
    self.isOriginalImage = origina;
    self.originalImageButton.selected = origina;
}

/** 预览按钮  */
- (void)previewEvent {
    if ([self.detailDelegate respondsToSelector:@selector(wxm_touchPreviewControl)]) {
        [self.detailDelegate wxm_touchPreviewControl];
    }
}

- (void)dismissController {
    if ([self.detailDelegate respondsToSelector:@selector(wxm_touchDismissViewController)]) {
        [self.detailDelegate wxm_touchDismissViewController];
    }
}

- (void)setSignObj:(WXMDictionary_Array *)signObj {
    _signObj = signObj;
    _previewButton.enabled = (_signObj.count > 0);
    _completeButton.enabled = (_signObj.count > 0);
    _photoNumber.hidden = (_signObj.count <= 0);
    _photoNumber.text = @(_signObj.count).stringValue;
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
        _originalImageButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_originalImageButton setTitle:@"  原图" forState:UIControlStateNormal];
        [_originalImageButton wc_addTarget:self action:@selector(originalEvent:)];
        _originalImageButton.centerX = self.width / 2;
        _originalImageButton.top = 3;
        _originalImageButton.hidden = !WXMPhotoSelectOriginal;

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
