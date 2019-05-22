//
//  WXMPhotoInterface.m
//  ModuleDebugging
//
//  Created by edz on 2019/5/7.
//  Copyright © 2019年 wq. All rights reserved.
//

#import "WXMPhotoInterface.h"
#import "WQComponentHeader.h"
#import "WXMPhotoViewController.h"
#import "WXMPhotoInterFaceProtocol.h"
#import "WXMPhotoManager.h"

@WXMService(WXMPhotoInterFaceProtocol, WXMPhotoInterface);
@interface WXMPhotoInterface () <WXMPhotoInterFaceProtocol,WQComponentFeedBack>
@end

@implementation WXMPhotoInterface

+ (NSArray *)events {
    return @[@"1001",@"1000"];
}
+ (NSArray *)modules {
    return @[@"WXMPhotoInterFaceProtocol"];
}
+ (void)providedEventModule_event:(NSString *)module_event eventObj:(id)eventObj {
    /** WXMPhotoInterFaceProtocol:1000 */
    
    
    NSLog(@"%@",module_event);
}
/** 判断权限 */
- (id)photoPermission {
    return @([WXMPhotoManager sharedInstance].wxm_photoPermission);
}

/** 获取相册 */
- (UIViewController *)achieveWXMPhotoViewController:(void (^)(UIImage * image))results {
    WXMPhotoViewController * vc = [WXMPhotoViewController new];
    vc.photoType = WXMPhotoDetailTypeGetPhoto_256;
    vc.results = results;
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:vc];
    return nav;
}
/** 获取相册路由方式 */
- (UIViewController *)routeAchieveWXMPhotoViewController:(void (^)(id obj))results {
    WXMPhotoViewController * vc = [WXMPhotoViewController new];
    vc.photoType = WXMPhotoDetailTypeTailoring;
    if (results) vc.results = results;
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:vc];
    return nav;
}
@end
