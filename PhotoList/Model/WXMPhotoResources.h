//
//  WXMPhotoResources.h
//  Multi-project-coordination
//
//  Created by wq on 2019/6/16.
//  Copyright © 2019年 wxm. All rights reserved.
//
#import "WXMPhotoManager.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

/** 回调用的model */
/** 回调用的model */
/** 回调用的model */
@interface WXMPhotoResources : NSObject

/** 预览图片 */
@property (nonatomic, strong) UIImage *resourceImage;

/** 视频data */
@property (nonatomic, strong) NSData *nativeData;
@property (nonatomic, strong) NSData *resourceData;
@property (nonatomic, strong) NSString *videoDrantion;
@property (nonatomic, assign) NSTimeInterval assetDrantion;

/** 本地URL */
@property (nonatomic, strong) NSString *objKey;
@property (nonatomic, strong) NSString *nativeUrl;
@property (nonatomic, strong) NSString *resourceUrl;
@property (nonatomic, strong) AVURLAsset *asset;

/** 类型 */
@property (nonatomic, assign) WXMPhotoMediaType mediaType;

/** 高 / 宽 */
@property (nonatomic, assign) CGFloat aspectRatio;

/** 上传保存的size */
@property (nonatomic, assign) CGSize uploadSize;

@end
