//
//  WXMPhotoSignModel.h
//  ModuleDebugging
//
//  Created by edz on 2019/5/12.
//  Copyright © 2019年 wq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WXMPhotoSignModel : NSObject

/** 相册名字 */
@property (nonatomic, copy) NSString *albumName;

/** 位置 */
@property (nonatomic, strong) NSIndexPath *indexPath;

/** 相片 */
@property (nonatomic, strong) UIImage *image;

/** 排名 */
@property (nonatomic, assign) NSInteger rank;

@end
