//
//  WXMPhotoDetailToolbar.h
//  Multi-project-coordination
//
//  Created by wq on 2019/6/8.
//  Copyright © 2019年 wxm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXMDictionary_Array.h"
#import "WXMPhotoConfiguration.h"

@interface WXMPhotoDetailToolbar : UIView

/** 存储被标记的图片model */
@property (nonatomic, strong) WXMDictionary_Array *signObj;

/** 是否选取原图 */
@property (nonatomic, assign, readonly) BOOL isOriginalImage;


@property (nonatomic, weak) id<WXMDetailToolbarProtocol> detailDelegate;
@end
