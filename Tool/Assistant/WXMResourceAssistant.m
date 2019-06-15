//
//  WXMResourceAssistant.m
//  ModuleDebugging
//
//  Created by edz on 2019/6/13.
//  Copyright © 2019 wq. All rights reserved.
//
#define WXMManager [WXMPhotoManager sharedInstance]
#import "WXMResourceAssistant.h"
#import "WXMPhotoAssistant.h"

@implementation WXMResourceAssistant
/**
 有封面图的情况下回调
 
 @param asset 图片资源
 @param coverImage 封面(传过来)
 @param delegate 代理
 @param isShowVideo 是否支持视频
 */
+ (void)sendResource:(WXMPhotoAsset *)asset
          coverImage:(UIImage *)coverImage
            delegate:(id<WXMPhotoProtocol>)delegate
         isShowVideo:(BOOL)isShowVideo
          isShowLoad:(BOOL)isShowLoad
      viewController:(UIViewController *)controller {
    
    if (delegate == nil) return;
    BOOL supportVideo = (isShowVideo && WXMPhotoSupportVideo);
    if ([delegate respondsToSelector:@selector(wxm_singlePhotoAlbum_Image_Gif_Video:data:)]) {
        UIViewController *vc = controller;
        
        if (asset.mediaType == WXMPHAssetMediaTypePhotoGif) {
            [self sendGif:asset coverImage:coverImage delegate:delegate viewController:vc];
        } else if (asset.mediaType == WXMPHAssetMediaTypeVideo && supportVideo) {
            [self sendVideo:asset coverImage:coverImage delegate:delegate viewController:vc];
        } else {
            vc.view.userInteractionEnabled = NO;
            if (isShowLoad && WXMPhotoSelectedImageReturnData) {
                [WXMPhotoAssistant wxm_showLoadingView:vc.view];
            }
            
            /** 0.75接近原始图大小 */
            NSData *data = nil;
            if (WXMPhotoSelectedImageReturnData) data = UIImageJPEGRepresentation(coverImage, 0.75);
            [delegate wxm_singlePhotoAlbum_Image_Gif_Video:coverImage data:data];
            [controller dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

/** 获取特定大小图片在获取data */
+ (void)sendResource:(WXMPhotoAsset *)asset
           coverSize:(CGSize)coverSize
            delegate:(id<WXMPhotoProtocol>)delegate
         isShowVideo:(BOOL)isShowVideo
          isShowLoad:(BOOL)isShowLoad
      viewController:(UIViewController *)controller {
    [WXMManager getPicturesByAsset:asset.asset synchronous:YES original:NO assetSize:coverSize resizeMode:PHImageRequestOptionsResizeModeExact deliveryMode:PHImageRequestOptionsDeliveryModeHighQualityFormat completion:^(UIImage *image) {
        [self sendResource:asset
                coverImage:image
                  delegate:delegate
               isShowVideo:isShowVideo
                isShowLoad:isShowLoad
            viewController:controller];
    }];
}

+ (void)sendCoverImage:(UIImage *)coverImage delegate:(id<WXMPhotoProtocol>)delegate {
    if ([delegate respondsToSelector:@selector(wxm_singlePhotoAlbum_Image_Gif_Video:data:)]) {
        NSData *data = nil;
        if (WXMPhotoSelectedImageReturnData) data = UIImageJPEGRepresentation(coverImage, 0.75);
        [delegate wxm_singlePhotoAlbum_Image_Gif_Video:coverImage data:data];
    }
}

///** 回调单张 */
//+ (void)sendResourceAssistant:(WXMPhotoAsset *)asset
//                   coverImage:(UIImage *)coverImage
//                    coverSize:(UIImage *)coverSize
//                     delegate:(id<WXMPhotoProtocol>)delegate {
//    if (delegate == nil) return;
//    
//    if (asset.mediaType == WXMPHAssetMediaTypePhotoGif) {
//    /** [self sendGif:asset coverImage:coverImage coverSize:coverSize delegate:delegate]; */
//    } else if (asset.mediaType == WXMPHAssetMediaTypeVideo) {
//        /** [self sendVideo:asset coverImage:coverImage coverSize:coverSize delegate:delegate]; */
//    } else {
//    /** [self sendImage:asset coverImage:coverImage coverSize:coverSize delegate:delegate]; */
//    }
//}

/** Gif */
+ (void)sendGif:(WXMPhotoAsset *)asset
     coverImage:(UIImage *)coverImage
       delegate:(id<WXMPhotoProtocol>)delegate
 viewController:(UIViewController *)controller {
    [WXMManager getGIFByAsset:asset.asset completion:^(NSData *data) {
        [delegate wxm_singlePhotoAlbum_Image_Gif_Video:coverImage data:data];
        [controller dismissViewControllerAnimated:YES completion:nil];
    }];
}

/** Video */
+ (void)sendVideo:(WXMPhotoAsset *)asset
       coverImage:(UIImage *)coverImage
         delegate:(id<WXMPhotoProtocol>)delegate
   viewController:(UIViewController *)controller {
    [WXMManager getVideoByAsset:asset.asset completion:^(NSURL *url, NSData *data) {
        [delegate wxm_singlePhotoAlbum_Image_Gif_Video:coverImage data:data];
        [controller dismissViewControllerAnimated:YES completion:nil];
    }];
}

/** Image */
+ (void)sendImage:(WXMPhotoAsset *)asset
       coverImage:(UIImage *)coverImage
         delegate:(id<WXMPhotoProtocol>)delegate {
    NSData *data = UIImageJPEGRepresentation(coverImage, WXMPhotoCompressionRatio);
    [delegate wxm_singlePhotoAlbum_Image_Gif_Video:coverImage data:data];
}

@end
