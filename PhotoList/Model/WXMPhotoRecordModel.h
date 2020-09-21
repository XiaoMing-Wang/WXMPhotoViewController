//
//  WXMPhotoRecordModel.h
//  2222222
//
//  Created by wq on 2020/3/14.
//  Copyright © 2020 wxm. All rights reserved.
//

#import "WXMPhotoManager.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** 勾选用的model */
/** 勾选用的model */
/** 勾选用的model */
@interface WXMPhotoRecordModel : NSObject

/** 相册名字 */
@property (nonatomic, copy) NSString *recordAlbumName;

/** 相片媒介 */
@property (nonatomic, strong) WXMPhotoAsset *recordAsset;

/** 预览图 */
@property (nonatomic, strong) UIImage *recordImage;

/** 资源类型 */
@property (nonatomic, assign) WXMPhotoMediaType mediaType;

/** 排名 */
@property (nonatomic, assign) NSInteger recordRank;

/** 刷新使用 */
@property (nonatomic, strong) NSIndexPath *recordIndexPath;

@end

NS_ASSUME_NONNULL_END
