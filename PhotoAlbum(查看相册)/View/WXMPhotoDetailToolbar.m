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
#import "UIView+WXMLieKit.h"
@interface WXMPhotoDetailToolbar ()
@property (nonatomic, strong) UIButton *previewButton;
@property (nonatomic, strong) UIButton *completeButton;
@property (nonatomic, strong) UILabel *photoNumber;

@property (nonatomic, strong) UIButton *originalImageButton;
@property (nonatomic, assign, readwrite) BOOL isOriginalImage;
//@property (nonatomic, strong) UIView *cylindrical;
//@property (nonatomic, strong) UIView *originalVew;
//@property (nonatomic, strong) UILabel *originaSize;
@end

@implementation WXMPhotoDetailToolbar

/** 初始化 */
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) [self setupInterface];
    return self;
}
- (void)setupInterface {
    self.frame = CGRectMake(0, WXMPhoto_Height - 45, WXMPhoto_Width, 45);
    self.backgroundColor = [UIColor clearColor];
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:self.bounds];
    toolBar.backgroundColor = WXMPhotoDetailToolbarColor;
    [self addSubview:toolBar];
    
    _previewButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 3, 60, self.height - 3)];
    [_previewButton setTitle:@"预览" forState:UIControlStateNormal];
    _previewButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _previewButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_previewButton setTitleColor:WXMPhotoDetailToolbarTextColor forState:UIControlStateNormal];
    [_previewButton setTitleColor:WXMPhoto_DTextColor forState:UIControlStateDisabled];
    [_previewButton wxm_setEnlargeEdgeWithTop:3 left:14 right:10 bottom:5];
    _previewButton.left = 14;
    _previewButton.enabled = NO;
    [_previewButton wxm_addTarget:self action:@selector(previewEvent)];
    
    _completeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 3, 0, self.height - 3)];
    [_completeButton setTitle:@"完成" forState:UIControlStateNormal];
    _completeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    _completeButton.titleLabel.font = [UIFont systemFontOfSize:16.2];
    [_completeButton setTitleColor:WXMSelectedColor forState:UIControlStateNormal];
    [_completeButton setTitleColor:WXMPhoto_DSureColor forState:UIControlStateDisabled];
    [_completeButton sizeToFit];
    _completeButton.right = WXMPhoto_Width - 14;
    _completeButton.height = self.height - 3;
    _completeButton.top = _previewButton.top;
    _completeButton.enabled = NO;
    [_completeButton wxm_addTarget:self action:@selector(dismissController)];
    [_completeButton wxm_setEnlargeEdgeWithTop:3 left:15 right:14 bottom:5];
    
    _photoNumber = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, WXMSelectedWH, WXMSelectedWH)];
    _photoNumber.text = @"1";
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
    
    [self addSubview:_previewButton];
    [self addSubview:_completeButton];
    [self addSubview:_photoNumber];
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
    if (self.detailDelegate &&
        [self.detailDelegate respondsToSelector:@selector(wxm_touchPreviewControl)]) {
        [self.detailDelegate wxm_touchPreviewControl];
    }
}

/** */
- (void)dismissController {
    if (self.detailDelegate &&
        [self.detailDelegate respondsToSelector:@selector(wxm_touchDismissViewController)]) {
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


/** 点击事件 */
- (void)originalEvent:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.isOriginalImage = sender.selected;
 }

/**  */
- (UIButton *)originalImageButton {
    if (!_originalImageButton) {
        _originalImageButton = [[UIButton alloc] init];
        _originalImageButton.size = CGSizeMake(80, 42);
        _originalImageButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_originalImageButton setTitle:@"  原图" forState:UIControlStateNormal];
        [_originalImageButton wxm_addTarget:self action:@selector(originalEvent:)];
        _originalImageButton.centerX = self.width / 2;
        _originalImageButton.top = 3;

        UIImage *defImage = [UIImage imageNamed:@"photo_original_def"];
        UIImage *seleImage = [UIImage imageNamed:@"photo_original_selected"];
        [_originalImageButton setTitleColor:WXMPhotoDetailToolbarTextColor
                                   forState:UIControlStateNormal];
        [_originalImageButton setTitleColor:WXMPhoto_DTextColor
                                   forState:UIControlStateDisabled];
        [_originalImageButton setImage:defImage forState:UIControlStateNormal];
        [_originalImageButton setImage:defImage forState:UIControlStateHighlighted];
        [_originalImageButton setImage:seleImage forState:UIControlStateSelected];
    }
    return _originalImageButton;
}

/**  */
//- (UIButton *)originalImageButton {
//    if (!_originalImageButton) {
//        _originalImageButton = [[UIButton alloc] init];
//        _originalImageButton.size = CGSizeMake(80, 42);
//        _originalImageButton.titleLabel.textColor = WXMPhoto_DTextColor;
//        [_originalImageButton setTitleColor:WXMPhoto_DTextColor forState:UIControlStateNormal];
//        [_originalImageButton setTitleColor:WXMPhoto_DTextColor forState:UIControlStateDisabled];
//        _originalImageButton.titleLabel.font = [UIFont systemFontOfSize:14];
//        [_originalImageButton setTitle:@"  原图" forState:UIControlStateNormal];
//        [_originalImageButton wxm_addTarget:self action:@selector(originalEvent:)];
//        _originalImageButton.centerX = self.width / 2;
//        _originalImageButton.top = 3;
//
//        [_originalImageButton setImage:[UIImage imageNamed:@"photo_original_def"]
//                              forState:UIControlStateNormal];
//        [_originalImageButton setImage:[UIImage imageNamed:@"photo_original_selected"]
//                              forState:UIControlStateSelected];
//
//        _cylindrical = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 23, 23)];
//        _cylindrical.layer.cornerRadius = _cylindrical.width / 2;
//        _cylindrical.layer.masksToBounds = YES;
//        _cylindrical.layer.borderColor = [UIColor whiteColor].CGColor;
//        _cylindrical.layer.borderWidth = .75;
//        _cylindrical.centerY = _originalImageButton.height / 2;
//        _cylindrical.userInteractionEnabled = NO;
//
//        _originalVew = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 17, 17)];
//        _originalVew.layer.cornerRadius = _originalVew.width / 2;
//        _originalVew.backgroundColor = WXMSelectedColor;
//        [_cylindrical addSubview:_originalVew];
//        _originalVew.layoutCenterSupView = YES;
//    /** _originalVew.hidden = YES; */
//        _originalVew.userInteractionEnabled = NO;
//
//        UIImage *image = [_cylindrical wxm_makeImage];
//        NSString *path_document = NSHomeDirectory();
//        NSString *imagePath = [path_document stringByAppendingString:@"/Documents/pic.png"];
//        NSLog(@"%@",imagePath);
//        [UIImagePNGRepresentation(image) writeToFile:imagePath atomically:YES];

//        _originaSize = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
//        _originaSize.userInteractionEnabled = NO;
//        _originaSize.text = @"原图";
//        _originaSize.font = [UIFont systemFontOfSize:14];
//        _originaSize.textColor = WXMPhoto_DTextColor;
//        [_originaSize sizeToFit];
//        _originaSize.numberOfLines = 1;
//        _originaSize.left = _cylindrical.right + 6;
//        _originaSize.textAlignment = NSTextAlignmentLeft;
//        _originaSize.centerY = _cylindrical.centerY;
//
//        _originalImageButton.width = _cylindrical.width + 4 + _originaSize.width;
//        _originalImageButton.centerX = self.width / 2;
//        _originalImageButton.top = 3;
//        [_originalImageButton addSubview:_cylindrical];
//        [_originalImageButton addSubview:_originaSize];
//
//    }
//    return _originalImageButton;
//}


@end
