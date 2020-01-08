//
//  WXMMediator+WXMPhotoInterFace.m
//  Multi-project-coordination
//
//  Created by wq on 2019/12/29.
//  Copyright © 2019 wxm. All rights reserved.
//

#import "WXMMediator+WXMPhotoInterFace.h"

static NSString *const WXMPhotoInterFace = @"WXMPhotoInterFace";
@implementation WXMMediator (WXMPhotoInterFace)

- (UINavigationController *)wp_photoViewController:(NSDictionary *)parameter {
    return WXMMEDIATOR_PERFORM_PARAMS(WXMPhotoInterFace, parameter);
}

/** 多选模式 max可选个数 seVideo可选视频 */
- (UINavigationController *)wp_multiSelectPhoto:(NSInteger)max seVideo:(BOOL)seVideo {
    NSDictionary *params = @{@"multiSelectMax":@(max),@"canSelectedVideo":@(seVideo)};
    return [self performTarget:WXMPhotoInterFace
                        action:@"wp_photoViewController"
                        params:params
             shouldCacheTarget:NO];
}

@end
