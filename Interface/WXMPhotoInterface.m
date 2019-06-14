//
//  WXMPhotoInterface.m
//  ModuleDebugging
//
//  Created by edz on 2019/5/7.
//  Copyright © 2019年 wq. All rights reserved.
//

#import "WXMPhotoInterface.h"
#import "WXMComponentHeader.h"
#import "WXMPhotoViewController.h"
#import "WXMPhotoInterFaceProtocol.h"
#import "WXMPhotoManager.h"

@WXMService(WXMPhotoInterFaceProtocol, WXMPhotoInterface); 
@interface WXMPhotoInterface () <WXMPhotoInterFaceProtocol,WXMComponentFeedBack,WXMPhotoProtocol>
@end

@implementation WXMPhotoInterface

- (BOOL)cacheImplementer {
    return YES;
}

- (NSArray *)modules_events {
    return @[@"XProtocol(500-550,988-1000)"];
}

- (void)providedEventModule_event:(WXMMessageContext *)context {
    /** WXMPhotoInterFaceProtocol:1000 */
    
    
    NSLog(@"%@",context.module);
    NSLog(@"%ld",context.event);
}

/** 判断权限 */
- (id)photoPermission {
    return @([WXMPhotoManager sharedInstance].wxm_photoPermission);
}

/** 获取相册 */
- (UIViewController *)achieveWXMPhotoViewController:(void (^)(UIImage * image))results {
    WXMPhotoViewController * vc = [WXMPhotoViewController new];
    vc.photoType = WXMPhotoDetailTypeGetPhoto_256;
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:vc];
    return nav;
}

/** 获取相册路由方式 */
- (UIViewController *)routeAchieveWXMPhotoViewController:(void (^)(id obj))results {
    WXMPhotoViewController * vc = [WXMPhotoViewController new];
    vc.photoType = WXMPhotoDetailTypeMultiSelect;
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:vc];
    return nav;
}

/** 获取相册路由方式 */
- (UIViewController *)routeAchieveWXMPhotoType:(NSDictionary *)params {
    NSString * typeString = [params objectForKey:@"type"];
    NSInteger typeInt = typeString.integerValue;
    WXMPhotoViewController * vc = [WXMPhotoViewController new];
    vc.delegate = self;
    vc.showVideo = YES;
    vc.exitPreview = NO;
    vc.photoType = typeInt;
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:vc];
    return nav;
}

- (void)dealloc {
    NSLog(@"dealloc------222");
}


@end
