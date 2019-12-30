//
//  WXMMediator+WXMPhotoInterFace.h
//  Multi-project-coordination
//
//  Created by wq on 2019/12/29.
//  Copyright © 2019 wxm. All rights reserved.
//
#import "WXMMediator.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXMMediator (WXMPhotoInterFace)

/** 获取相册界面 */
- (UINavigationController *)wp_photoViewController:(NSDictionary *)parameter;

/** 多选模式 selectMax可选个数 canSelectedVideo可选视频 */
- (UINavigationController *)wp_multiSelectPhoto:(NSInteger)max seVideo:(BOOL)seVideo;

@end

NS_ASSUME_NONNULL_END
