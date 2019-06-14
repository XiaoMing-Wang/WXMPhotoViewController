//
//  WXMResourceAssistant.h
//  ModuleDebugging
//
//  Created by edz on 2019/6/13.
//  Copyright © 2019 wq. All rights reserved.
//
#import "WXMPhotoManager.h"
#import <Foundation/Foundation.h>
#import "WXMPhotoConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXMResourceAssistant : NSObject

#pragma mark 单选
/**
 data不压缩直接返回 适用WXMPhotoDetailTypeGetPhoto 和 WXMPhotoDetailTypeGetPhoto_256
 
 @param asset 图片资源
 @param coverImage 封面(传过来)
 @param delegate 代理
 @param isShowVideo 是否支持允许返回视频data
 */
+ (void)sendResource:(WXMPhotoAsset *)asset
          coverImage:(UIImage *)coverImage
            delegate:(id<WXMPhotoProtocol>)delegate
         isShowVideo:(BOOL)isShowVideo
      viewController:(UIViewController *)controller;

/**  */
+ (void)sendResource:(WXMPhotoAsset *)asset
           coverSize:(CGSize)coverSize
            delegate:(id<WXMPhotoProtocol>)delegate
         isShowVideo:(BOOL)isShowVideo
      viewController:(UIViewController *)controller;


+ (void)sendCoverImage:(UIImage *)coverImage delegate:(id<WXMPhotoProtocol>)delegate;
#pragma mark 多选



@end

NS_ASSUME_NONNULL_END
