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

@interface WXMPhotoResources : NSObject

/** 预览图片 */
@property (nonatomic, strong) UIImage *resourceImage;

/** 视频data */
@property (nonatomic, strong) NSData *resourceData;

/** 本地URL */
@property (nonatomic, strong) NSString *resourceUrl;

/** 阿里云URL */
@property (nonatomic, strong) NSString *aliCloudUrl;

/** 类型 */
@property (nonatomic, assign) WXMPhotoMediaType mediaType;

/** 高 / 宽 */
@property (nonatomic, assign) CGFloat aspectRatio;

/** 上传保存的size */
@property (nonatomic, assign) CGSize uploadSize;

@end
