//
//  WXMPhotoSignModel.h
//  ModuleDebugging
//
//  Created by edz on 2019/5/12.
//  Copyright © 2019年 wq. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "WXMPhotoManager.h"

@interface WXMPhotoSignModel : NSObject

/** 相册名字 */
@property (nonatomic, copy) NSString *albumName;

/** 本地标识 */
@property (nonatomic, copy) NSString *localIdentifier;

/** 位置 */
@property (nonatomic, strong) NSIndexPath *indexPath;

/** 相片 */
@property (nonatomic, strong) UIImage *image;

/** rank是动态的 */
@property (nonatomic, assign) NSInteger rank;

/** 相片类型 */
@property (nonatomic, assign) WXMPhotoMediaType mediaType;

@end



