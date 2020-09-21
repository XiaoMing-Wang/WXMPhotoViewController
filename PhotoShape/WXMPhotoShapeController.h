//
//  WXMPhotoShapeController.h
//  ModuleDebugging
//
//  Created by edz on 2019/5/17.
//  Copyright © 2019年 wq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXMPhotoConfiguration.h"

@interface WXMPhotoShapeController : UIViewController

@property (nonatomic, strong) UIImage *shapeImage;
@property (nonatomic, weak) id<WXMPhotoProtocol> delegate;

/** 期望获取图片大小 */
@property (nonatomic, assign) CGSize expectSize;
@property (nonatomic, assign) BOOL donePop;

@end

