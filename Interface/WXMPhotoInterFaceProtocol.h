//
//  WXMPhotoInterFaceProtocol.h
//  ModuleDebugging
//
//  Created by edz on 2019/5/7.
//  Copyright © 2019年 wq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@protocol WXMPhotoInterFaceProtocol <NSObject>

/** 相册权限 未检测和有都是YES */
- (id)photoPermission;

/** 获取相册 自带导航栏 */
- (UIViewController *)achieveWXMPhotoViewController:(void (^)(UIImage * image))results;

/** 获取相册路由方式 自带导航栏*/
- (UIViewController *)routeAchieveWXMPhotoViewController:(void (^)(id obj))results;


- (UIViewController *)routeAchieveWXMPhotoType:(NSDictionary *)params;
@end
