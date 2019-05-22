//
//  WXMPhotoConfiguration.h
//  ModuleDebugging
//
//  Created by edz on 2019/5/12.
//  Copyright © 2019年 wq. All rights reserved.
//
#define WXMPhoto_Width [UIScreen mainScreen].bounds.size.width
#define WXMPhoto_Height [UIScreen mainScreen].bounds.size.height
#define WXMPhoto_IPHONEX ((WXMPhoto_Height == 812.0f) ? YES : NO)
#define WXMPhoto_BarHeight ((WXMPhoto_IPHONEX) ? 88.0f : 64.0f)
#define WXMPhoto_KWindow [[[UIApplication sharedApplication] delegate] window]
#define WXMPhoto_RGBColor(r, g, b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]

#ifndef WXMPhotoConfiguration_h
#define WXMPhotoConfiguration_h
#import <UIKit/UIKit.h>
#import "WXMPhotoAssistant.h"

/** 导航栏颜色 */
#define WXMBarColor [[UIColor whiteColor] colorWithAlphaComponent:1]

/** 导航栏title颜色 */
#define WXMBarTitleColor [[UIColor blackColor] colorWithAlphaComponent:1]

/** 导航栏线条颜色  */
#define WXMBarLineColor [[UIColor whiteColor] colorWithAlphaComponent:0]

/** 选中颜色  */
#define WXMSelectedColor [WXMPhoto_RGBColor(31, 185, 34) colorWithAlphaComponent:0.9]

/** 查看界面cell图片大小 */
#define WXMItemWidth ((WXMPhoto_Width - 7.5) / 4) * 2

/** WXMPhotoDetailViewController界面 选中图标大小  */
#define WXMSelectedWH 25

/** WXMPhotoDetailViewController界面 选中图标字体大小  */
#define WXMSelectedFont 15

/** WXMPhotoDetailTypeMultiSelect 默认最大张数 */
#define WXMMultiSelectMax 4

/** 默认传递大小  */
#define WXMDefaultSize CGSizeMake(200, 200 * 1.78)

/** 预览黑边间距 */
#define WXMPhotoPreviewSpace 20

/** 预览下面工具栏推按大小 */
#define WXMPhotoPreviewImageWH 53

/** 手势下拉缩小最小倍数 */
#define WXMPhotoMinification 0.3


/** 类型 */
typedef NS_ENUM(NSInteger, WXMPhotoDetailType) {
    WXMPhotoDetailTypeGetPhoto = 0,     /* 单选 */
    WXMPhotoDetailTypeGetPhoto_256 = 1, /* 单选扫码 */
    WXMPhotoDetailTypeMultiSelect = 2,  /* 多选 */
    WXMPhotoDetailTypePreview = 3,      /* 预览模式 */
    WXMPhotoDetailTypeTailoring = 4,    /* 裁剪 */
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

/** 工具栏回调 */
@protocol WXMPreviewToolbarProtocol <NSObject>
- (void)wxm_touchTopLeftItem;
- (void)wxm_touchTopRightItem:(id)obj;
- (void)wxm_touchButtomFinsh;
@end


#endif /* WXMPhotoConfiguration_h */
