//
//  WXMPhotoConfiguration.h
//  ModuleDebugging
//
//  Created by edz on 2019/5/12.
//  Copyright © 2019年 wq. All rights reserved.
//
#define kDevice_Is_iPhoneX \
({BOOL isPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
}\
(isPhoneX);})

#define WXMPhoto_originalNoti @"WXMPhoto_originalNoti"
#define WXMPhoto_Width [UIScreen mainScreen].bounds.size.width
#define WXMPhoto_Height [UIScreen mainScreen].bounds.size.height

#define WXMPhoto_BarHeight ((kDevice_Is_iPhoneX) ? 88.0f : 64.0f)
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
#import "WXMPhotoResources.h"

#pragma mark 查看界面

/** CollectionView 边距 */
#define kMargin 2.5

/** CollectionView 一行几个 */
#define kCount 4

#define WXMPhotoVCNavigationItem @"相册"
#define WXMPhotoVCRightItem @"取消"

#pragma mark WXMPhotoDetailViewController

/** 图片压缩比例 0.75接近原图  0.3大小大约为0.75的  1/4 */
/** 256和原图模式默认返回0.75 修改无效 */
#define WXMPhotoCompressionRatio 0.3

/** 全局是否支持显示视频 (NO会显示视频的第一帧 且WXMPhotoViewController设置showVideo也无效)*/
#define WXMPhotoSupportVideo YES

/** 是否显示GIF标志 WXMPhotoDetailViewController */
#define WXMPhotoShowGIFSign YES

/** 是否可以选择原图 */
#define WXMPhotoSelectOriginal YES

/** 裁剪是否显示GIF */
#define WXMPhotoTailoringShowGIFSign  (WXMPhotoShowGIFSign && NO)

/** 是否显示视频标志 WXMPhotoDetailViewController */
#define WXMPhotoShowVideoSign (WXMPhotoSupportVideo && YES)

/** 多选是否支持同时选图片和视频 */
#define WXMPhotoChooseVideo_Photo NO

/** 是否支持播放livephoto */
#define WXMPhotoShowLivePhto NO

/** livephoto是否静音 */
#define WXMPhotoShowLivePhtoMuted NO

/** 选择图片时(选择GIF和视频依旧会返回)是否返回data(可自行转成合适大小的data) */
#define WXMPhotoSelectedImageReturnData YES

/** collection列表是否显示下边工具栏 */
#define WXMPhotoShowDetailToolbar YES

/** 裁剪是否使用原图 (使用原图内存会暴涨建议NO)*/
#define WXMPhotoCropUseOriginal NO

/** 查看相册工具栏颜色 */
#define WXMPhotoDetailToolbarColor [UIColor whiteColor]

/** 预览工具栏颜色 */
#define WXMPhotoPreviewbarColor [WXMPhoto_RGBColor(33, 33, 33) colorWithAlphaComponent:0.9]

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

/** 混合的情况下以 WXMMultiSelectVideoMax为最大个数 */
/** WXMPhotoDetailTypeMultiSelect 默认最大张数 */
#define WXMMultiSelectMax 6

/** WXMPhotoDetailTypeMultiSelect 支持最大视频数 */
#define WXMMultiSelectVideoMax 1

/** 默认传回的图片大小  */
#define WXMDefaultSize CGSizeZero

/** 预览黑边间距 */
#define WXMPhotoPreviewSpace 20

/** 预览下面工具栏推图案大小 */
#define WXMPhotoPreviewImageWH 53

/** 手势下拉缩小最小倍数 */
#define WXMPhotoMinification 0.3

/** 播放按钮大小 */
#define WXMPhotoVideoSignSize CGSizeMake(70, 70)

/** 裁剪框边距 */
#define WXMPhotoCropBoxMargin 20

/** 类型 */
typedef NS_ENUM(NSInteger, WXMPhotoDetailType) {
    WXMPhotoDetailTypeGetPhoto = 0,             /* 单选原图大小 */
    WXMPhotoDetailTypeGetPhoto_256 = 1,         /* 单选256*256 */
    WXMPhotoDetailTypeGetPhotoCustomSize = 2,   /* 单选自定义大小 */
    WXMPhotoDetailTypeMultiSelect = 3,          /* 多选 + 预览 */
    WXMPhotoDetailTypeTailoring = 4,            /* 预览 + 裁剪 */
};

/** 预览类型 */
typedef NS_ENUM(NSInteger, WXMPhotoPreviewType) {
    WXMPhotoPreviewTypeSingle = 0,     /* 单张预览 */
    WXMPhotoPreviewTypeMost,           /* 多选预览 */
};

/** 获取相册回调协议 */
@protocol WXMPhotoProtocol <NSObject>
@optional;

/** cover 封面(除256和原图外设置用户可设置返回图片大小 不设置返回预览时大小) */
/** data 选中image时返回宏设置压缩比大小(默认大约为原图1/4大小 视频和gif返回原始data) */
- (void)wxm_singlePhotoAlbumWithResources:(WXMPhotoResources *)resource;
- (void)wxm_morePhotoAlbumWithResources:(NSArray<WXMPhotoResources *>*)resource;
@end

#pragma mark _____________________________________________ 多选模式
/** 点击标记Sign选中view回调 WXMPhotoDetailTypeMultiSelect模式 */
@protocol WXMPhotoSignProtocol <NSObject>
- (NSInteger)touchWXMPhotoSignView:(NSIndexPath *)index selected:(BOOL)selected;
- (void)wxm_cantTouchWXMPhotoSignView:(WXMPhotoMediaType)mediaType;
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

