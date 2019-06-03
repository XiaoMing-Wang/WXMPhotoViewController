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

/** 回调 */
@property (nonatomic, strong) void (^results)(UIImage *image);

@end
