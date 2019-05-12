//
//  WXMPhotoConfiguration.h
//  ModuleDebugging
//
//  Created by edz on 2019/5/12.
//  Copyright © 2019年 wq. All rights reserved.
//

#ifndef WXMPhotoConfiguration_h
#define WXMPhotoConfiguration_h
#import <UIKit/UIKit.h>

/** 导航栏颜色 */
#define WXMBarColor [[UIColor whiteColor] colorWithAlphaComponent:1]

/** 导航栏title颜色 */
#define WXMBarTitleColor [[UIColor blackColor] colorWithAlphaComponent:1]

/** 导航栏线条颜色  */
#define WXMBarLineColor [[UIColor whiteColor] colorWithAlphaComponent:1]

/** 选中图标颜色  */
#define WXMSelectedColor [[UIColor greenColor] colorWithAlphaComponent:1]

/** 选中图标大小  */
#define WXMSelectedWH 20.5

/** WXMPhotoDetailTypeMultiSelect 默认最大张数 */
#define WXMMultiSelectMax 4

/** 默认传递大小  */
#define WXMDefaultSize CGSizeMake(200, 200 * 1.78)


/** 类型 */
typedef NS_ENUM(NSInteger, WXMPhotoDetailType) {
    WXMPhotoDetailTypeGetPhoto = 0,     /* 单选 */
    WXMPhotoDetailTypeGetPhoto_256 = 1, /* 单选扫码 */
    WXMPhotoDetailTypeMultiSelect = 2,  /* 多选 */
    WXMPhotoDetailTypePreview = 3,      /* 预览模式 */
    WXMPhotoDetailTypeTailoring = 4,    /* 裁剪 */
};

/** 相册回调协议 */
@protocol WXMPhotoProtocol <NSObject>
@optional;
- (void)wxm_singlePhotoAlbumWithImage:(UIImage *)image;
- (void)wxm_morePhotoAlbumWithImages:(NSArray<UIImage *>*)images;
@end

/** 点击标记选中view回调 WXMPhotoDetailTypeMultiSelect模式 */
@protocol WXMPhotoSignProtocol <NSObject>
- (NSInteger)touchWXMPhotoSignView:(NSIndexPath *)index selected:(BOOL)selected;
@end
#endif /* WXMPhotoConfiguration_h */
