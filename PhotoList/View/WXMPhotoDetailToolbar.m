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
    
    CGFloat height = kDevice_Is_iPhoneX ? 80 : 45;
    CGFloat coHeight = 45;
    CGFloat iconWH = WXMSelectedWH;
    
    
    self.frame = CGRectMake(0, WXMPhoto_Height - height, WXMPhoto_Width, height);
    self.backgroundColor = [UIColor clearColor];
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:self.bounds];
    toolBar.backgroundColor = WXMPhotoDetailToolbarColor;
    
    _previewButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 3, 60, coHeight - 3)];
    [_previewButton setTitle:@"预览" forState:UIControlStateNormal];
    _previewButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _previewButton.titleLabel.font = [UIFont systemFontOfSize:16.5];
    [_previewButton setTitleColor:WXMPhotoDetailToolbarTextColor forState:0];
    [_previewButton setTitleColor:WXMPhoto_DTextColor forState:UIControlStateDisabled];
    [_previewButton wxm_setEnlargeEdgeWithTop:3 left:14 right:10 bottom:5];
    _previewButton.left = 14;
    _previewButton.enabled = NO;
    [_previewButton wxm_addTarget:self action:@selector(previewEvent)];
    
    _completeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 3, 0, coHeight - 3)];
    [_completeButton setTitle:@"完成" forState:UIControlStateNormal];
    _completeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    _completeButton.titleLabel.font = [UIFont systemFontOfSize:16.5];
    [_completeButton setTitleColor:WXMSelectedColor forState:UIControlStateNormal];
    [_completeButton setTitleColor:WXMPhoto_DSureColor forState:UIControlStateDisabled];
    [_completeButton sizeToFit];
    _completeButton.right = WXMPhoto_Width - 14;
    _completeButton.height = coHeight - 3;
    _completeButton.top = _previewButton.top;
    _completeButton.enabled = NO;
    [_completeButton wxm_addTarget:self action:@selector(dismissController)];
    [_completeButton wxm_setEnlargeEdgeWithTop:3 left:15 right:14 bottom:5];
    
    _photoNumber = [[UILabel alloc] initWithFrame:CGRectMake(0,0,iconWH, iconWH)];
    _photoNumber.text = @"0";
    _photoNumber.font = [UIFont systemFontOfSize:14];
    _photoNumber.textColor = [UIColor whiteColor];
    _photoNumber.numberOfLines = 1;
    _photoNumber.layer.cornerRadius = _photoNumber.width / 2;
    _photoNumber.layer.masksToBounds = YES;
    _photoNumber.right = _completeButton.left - 5;
    _photoNumber.centerY = _completeButton.centerY;
    _photoNumber.backgroundColor = WXMSelectedColor;
    _photoNumber.textAlignment = NSTextAlignmentCenter;
    _photoNumber.hidden = YES;
    
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
        [_originalImageButton wxm_addTarget:self action:@selector(originalEvent:)];
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
