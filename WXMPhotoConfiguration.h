//
//  WXMPhotoConfiguration.h
//  ModuleDebugging
//
//  Created by edz on 2019/5/12.
//  Copyright © 2019年 wq. All rights reserved.
//
#define WXMPhoto_originalNoti @"WXMPhoto_originalNoti"
#define WXMPhoto_Width [UIScreen mainScreen].bounds.size.width
#define WXMPhoto_Height [UIScreen mainScreen].bounds.size.height
#define WXMPhoto_IPHONEX ((WXMPhoto_Height == 812.0f) ? YES : NO)
#define WXMPhoto_BarHeight ((WXMPhoto_IPHONEX) ? 88.0f : 64.0f)
#define WXMPhoto_KWindow [[[UIApplication sharedApplication] delegate] window]
#define WXMPhoto_SRect \
CGRectMake(0, WXMPhoto_BarHeight, WXMPhoto_Width, WXMPhoto_Height - WXMPhoto_BarHeight)
#define WXMPhoto_RGBColor(r, g, b)\
[UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]

#ifndef WXMPhotoConfiguration_h
#define WXMPhotoConfiguration_h
#import <UIKit/UIKit.h>
#import "WXMPhotoAssistant.h"
#import "UIView+WXMPhoto.h"
#import "WXMPhotoSignModel.h"

#pragma mark 查看界面
#define WXMPhotoVCNavigationItem @"相册"
#define WXMPhotoVCRightItem @"取消"

#pragma mark WXMPhotoDetailViewController

/** collection列表是否显示下边工具栏 */
#define WXMPhotoShowDetailToolbar YES

/** 工具栏颜色 */
#define WXMPhotoDetailToolbarColor [UIColor whiteColor]

/** 工具栏字体 */
#define WXMPhotoDetailToolbarTextColor [UIColor blackColor]

/** 导航栏颜色 */
#define WXMBarColor [[UIColor whiteColor] colorWithAlphaComponent:1]

/** 导航栏title颜色 */
#define WXMBarTitleColor [[UIColor blackColor] colorWithAlphaComponent:1]

/** 导航栏线条颜色  */
#define WXMBarLineColor [[UIColor whiteColor] colorWithAlphaComponent:0]

/** 选中颜色  */
#define WXMSelectedColor [WXMPhoto_RGBColor(31, 185, 34) colorWithAlphaComponent:0.9]

/** 查看界面cell图片大小 */
#define WXMItemWidth ((WXMPhoto_Width - 7.5) / 4) * 2.0

/** WXMPhotoDetailViewController界面 选中图标大小  */
#define WXMSelectedWH 25

/** WXMPhotoDetailViewController界面 选中图标字体大小  */
#define WXMSelectedFont 15

/** WXMPhotoDetailTypeMultiSelect 默认最大张数 */
#define WXMMultiSelectMax 4

/** 默认传回的图片大小  */
#define WXMDefaultSize CGSizeMake(200, 200 * 1.78)

/** 预览黑边间距 */
#define WXMPhotoPreviewSpace 20

/** 预览下面工具栏推图案大小 */
#define WXMPhotoPreviewImageWH 53

/** 手势下拉缩小最小倍数 */
#define WXMPhotoMinification 0.3

/** 是否显示GIF标志 */
#define WXMPhotoShowGIFSign YES

/** 是否显示视频标志 */
#define WXMPhotoShowVideoSign YES

/** 播放按钮大小 */
#define WXMPhotoVideoSignSize CGSizeMake(70, 70)


/** 类型 */
typedef NS_ENUM(NSInteger, WXMPhotoDetailType) {
    WXMPhotoDetailTypeGetPhoto = 0,     /* 单选原图 */
    WXMPhotoDetailTypeGetPhoto_256 = 1, /* 单选256*256 */
    WXMPhotoDetailTypeMultiSelect = 2,  /* 多选 + 预览 */
    WXMPhotoDetailTypePreview = 3,      /* 单选 + 预览 */
    WXMPhotoDetailTypeTailoring = 4,    /* 预览 + 裁剪 */
};

/** 预览类型 */
typedef NS_ENUM(NSInteger, WXMPhotoPreviewType) {
    WXMPhotoPreviewTypeSingle = 0,     /* 单张 */
    WXMPhotoPreviewTypeMost,           /* 多张 */
};

/** 获取相册回调协议 */
@protocol WXMPhotoProtocol <NSObject>
@optional;
- (void)wxm_singlePhotoAlbumWithImage:(UIImage *)image;
- (void)wxm_morePhotoAlbumWithImages:(NSArray<UIImage *>*)images;
@end

#pragma mark _____________________________________________ 多选模式
/** 点击标记Sign选中view回调 WXMPhotoDetailTypeMultiSelect模式 */
@protocol WXMPhotoSignProtocol <NSObject>
- (NSInteger)touchWXMPhotoSignView:(NSIndexPath *)index selected:(BOOL)selected;
@end

/** 预览缩放cell回调 */
@protocol WXMPreviewCellProtocol <NSObject>
- (void)wxm_respondsToTapSingle;
- (void)wxm_respondsBeginDragCell;
- (void)wxm_respondsEndDragCell:(UIScrollView *)jump;
@end

/** 查看详情工具栏回调 */
@protocol WXMDetailToolbarProtocol <NSObject>
- (void)wxm_touchPreviewControl;
- (void)wxm_touchDismissViewController;

@end

/** 预览上下工具栏回调 */
@protocol WXMPreviewToolbarProtocol <NSObject>
- (void)wxm_touchTopLeftItem;
- (void)wxm_touchTopRightItem:(id)obj;
- (void)wxm_touchButtomFinsh;
- (void)wxm_touchButtomDidSelectItem:(NSIndexPath *)idx;
@end


#endif /* WXMPhotoConfiguration_h */
