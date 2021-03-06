//
//  WXMPhotoConfiguration.h
//  ModuleDebugging
//
//  Created by edz on 2019/5/12.
//  Copyright © 2019年 wq. All rights reserved.
//
#define kIPhoneX \
({ BOOL isPhoneX = NO; \
if (@available(iOS 11.0, *)) { \
   isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
}\
(isPhoneX);})

#define WXMPhoto_originalNoti @"WXMPhoto_originalNoti"
#define WXMPhoto_Width [UIScreen mainScreen].bounds.size.width
#define WXMPhoto_Height [UIScreen mainScreen].bounds.size.height

#define WXMPhoto_BarHeight ((kIPhoneX) ? 88.0f : 64.0f)
#define WXMPhoto_SafeHeight ((kIPhoneX) ? 35.0f : 0.0f)

#define WXMPhoto_KWindow [[[UIApplication sharedApplication] delegate] window]

#define WXMPhoto_SRect CGRectMake(0, WXMPhoto_BarHeight, WXMPhoto_Width, WXMPhoto_Height - WXMPhoto_BarHeight)

#define WXMPhoto_RGBColor(r, g, b)\
[UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]

#ifndef WXMPhotoConfiguration_h
#define WXMPhotoConfiguration_h

#import <UIKit/UIKit.h>
#import "UIView+WXMPhoto.h"
#import "WXMPhotoResources.h"
#import "WXMPhotoUIAssistant.h"

#pragma mark 查看界面

/** CollectionView 边距 */
#define kMargin 2.5

/** CollectionView 一行几个 */
#define kCount 4

/** 宽度 */
#define kImageWidth ([UIScreen mainScreen].bounds.size.width - (kCount - 1) * kMargin) / kCount

#define WXMPhotoVCNavigationItem @"相册"
#define WXMPhotoVCRightItem @"取消"

#pragma mark WXMPhotoDetailViewController

/** 图片压缩比例 0.75接近原图  0.3大小大约为0.75的  1/4 */
/** 256和原图模式默认返回0.75 修改无效 */
#define WXMPhotoCompressionRatio 0.3

/** 限制可选视频最大时间长度 */
#define WXMPhotoLimitVideoTime 300

/** 限制最大GIF 单位M */
#define WXMPhotoLimitGIFSize 5

/** 全局是否支持显示视频 (NO会显示视频的第一帧 且WXMPhotoViewController设置showVideo也无效)*/
#define WXMPhotoSupportVideo YES

/** 是否显示GIF标志 WXMPhotoDetailViewController */
#define WXMPhotoShowGIFSign YES

/** 是否可以选择原图 */
#define WXMPhotoSelectOriginal NO

/** 是否显示视频标志 WXMPhotoDetailViewController */
#define WXMPhotoShowVideoSign (WXMPhotoSupportVideo && YES)

/** 多选是否支持同时选图片和视频 */
#define WXMPhotoChooseVideo_Photo NO

/** 是否支持播放livephoto */
#define WXMPhotoShowLivePhto NO

/** 自动播放视频 */
#define WXMPhotoAutomaticVideo NO

/** livephoto是否静音 */
#define WXMPhotoShowLivePhtoMuted YES

/** 选择图片时(选择GIF和视频依旧会返回)是否返回data(可自行转成合适大小的data) */
#define WXMPhotoSelectedImageReturnData NO

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
#define WXMDisAbleColor [WXMPhoto_RGBColor(99, 99, 99) colorWithAlphaComponent:0.9]

/** 查看界面cell图片大小 */
#define WXMItemWidth ((WXMPhoto_Width - 7.5) / 4) * 2.0

/** WXMPhotoDetailViewController界面 选中图标大小  */
#define WXMSelectedWH 25

/** WXMPhotoDetailViewController界面 选中图标字体大小  */
#define WXMSelectedFont 15

/** 混合的情况下以 WXMMultiSelectMax为最大个数 */
/** WXMPhotoDetailTypeMultiSelect 默认最大张数 */
#define WXMMultiSelectMax 9

/** WXMPhotoDetailTypeMultiSelect 支持最大视频数 */
#define WXMMultiSelectVideoMax 1

/** 默认传回的图片大小  */
#define WXMDefaultSize CGSizeZero

/** 预览黑边间距 */
#define WXMPhotoPreviewSpace 20

/** 预览下面工具栏推图案大小 */
#define WXMPhotoPreviewImageWH 53

/** 手势下拉缩小最小倍数 */
#define WXMPhotoMinification 0.48

/** 播放按钮大小 */
#define WXMPhotoVideoSignSize CGSizeMake(70, 70)

/** 裁剪框边距 */
#define WXMPhotoCropBoxMargin 20

/** list cell高度 */
#define WXMPhotoListCellH 80

/** list个数 */
#define WXMPhotoListCellCount (WXMPhoto_Width == 320 ? 5 : (WXMPhoto_Width == 375 ? 6 : 7))

/** 类型 */
typedef NS_ENUM(NSInteger, WXMPhotoDetailType) {
    WXMPhotoDetailTypeGetPhoto = 0,             /* 单选原图大小 */
    WXMPhotoDetailTypeGetPhoto_256 = 1,         /* 单选256*256 */
    WXMPhotoDetailTypeGetPhotoCustomSize = 2,   /* 单选自定义大小 */
    WXMPhotoDetailTypeMultiSelect = 3,          /* 多选 + 预览() */
    WXMPhotoDetailTypeTailoring = 4,            /* 预览 + 裁剪 */
    WXMPhotoDetailTypeHybrid = 5,               /* 混合(不限制) */
    WXMPhotoDetailTypeSingleType = 6,           /* 单一类型(只能选图片或者视频) */
};

/** 预览类型 */
typedef NS_ENUM(NSInteger, WXMPhotoPreviewType) {
    WXMPhotoPreviewTypeSingle = 0,     /* 单张预览 */
    WXMPhotoPreviewTypeMost,           /* 多选预览 */
};

/** 获取相册回调协议 */
@protocol WXMPhotoProtocol <NSObject>
@optional

/** cover 封面(除256和原图外设置用户可设置返回图片大小 不设置返回预览时大小) */
/** data 选中image时返回宏设置压缩比大小(默认大约为原图1/4大小 视频和gif返回原始data) */
- (void)wp_singlePhotoAlbumWithResources:(WXMPhotoResources *)resource;
- (void)wp_morePhotoAlbumWithResources:(NSArray<WXMPhotoResources *>*)resource;
@end

#pragma mark _____________________________________________ 多选模式

/** 预览缩放cell回调 */
@protocol WXMPreviewCellProtocol <NSObject>
- (void)wp_respondsToTapSingle:(BOOL)plays;
- (void)wp_respondsBeginDragCell;
- (void)wp_respondsEndDragCell:(UIScrollView *)jump;
@end

/** 查看详情标题栏 */
@protocol WXMDetailTitleBarProtocol <NSObject>
- (void)wp_touchTitleBarWithUnfold:(BOOL)unfold;
- (void)wp_changePhotoList:(WXMPhotoList *)photoList;
@end

/** 查看详情工具栏回调 */
@protocol WXMDetailToolbarProtocol <NSObject>
- (void)wp_touchPreviewControl;
- (void)wp_touchDismissViewController;
@end

/** 预览上下工具栏回调 */
@protocol WXMPreviewToolbarProtocol <NSObject>
- (void)wp_touchTopLeftItem;
- (void)wp_touchTopRightItem:(id)obj;
- (void)wp_touchButtomFinsh;
- (void)wp_touchButtomDidSelectItem:(NSIndexPath *)idx;
@end


#endif /* WXMPhotoConfiguration_h */

