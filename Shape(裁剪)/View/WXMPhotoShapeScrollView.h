//
//  WXMPhotoShapeScrollView.h
//  ModuleDebugging
//
//  Created by wq on 2019/5/18.
//  Copyright © 2019年 wq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WXMPhotoShapeScrollView : UIScrollView
@property (nullable, nonatomic, copy) void (^touchesBegan)(void);
@property (nullable, nonatomic, copy) void (^touchesCancelled)(void);
@property (nullable, nonatomic, copy) void (^touchesEnded)(void);
@end
