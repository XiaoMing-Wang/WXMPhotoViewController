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
      viewController:(UIViewController *)controller {
    
    if (delegate == nil) return;
    BOOL supportVideo = (isShowVideo && WXMPhotoSupportVideo);
    if ([delegate respondsToSelector:@selector(wxm_singlePhotoAlbum_Image_Gif_Video:data:)]) {
        if (asset.mediaType == WXMPHAssetMediaTypePhotoGif) {
            [self sendGif:asset coverImage:coverImage delegate:delegate];
        } else if (asset.mediaType == WXMPHAssetMediaTypeVideo && supportVideo) {
            [self sendVideo:asset coverImage:coverImage delegate:delegate];
        } else {
            
            controller.view.userInteractionEnabled = NO;
            [WXMPhotoAssistant wxm_showLoadingView:controller.view];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
                NSData *data = UIImageJPEGRepresentation(coverImage, 0.75);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [controller dismissViewControllerAnimated:YES completion:nil];
                    [delegate wxm_singlePhotoAlbum_Image_Gif_Video:coverImage data:data];
                });
            });
        }
    }
}

/** 获取特定大小图片在获取data */
+ (void)sendResource:(WXMPhotoAsset *)asset
           coverSize:(CGSize)coverSize
            delegate:(id<WXMPhotoProtocol>)delegate
         isShowVideo:(BOOL)isShowVideo
      viewController:(UIViewController *)controller {
    [WXMManager getPicturesByAsset:asset.asset  synchronous:YES original:NO assetSize:coverSize resizeMode:PHImageRequestOptionsResizeModeExact deliveryMode:PHImageRequestOptionsDeliveryModeHighQualityFormat completion:^(UIImage *image) {
        [self sendResource:asset
                coverImage:image
                  delegate:delegate
               isShowVideo:isShowVideo
            viewController:controller];
    }];
}

+ (void)sendCoverImage:(UIImage *)coverImage delegate:(id<WXMPhotoProtocol>)delegate {
    if ([delegate respondsToSelector:@selector(wxm_singlePhotoAlbum_Image_Gif_Video:data:)]) {
        NSData *data = UIImageJPEGRepresentation(coverImage, 0.75);
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
       delegate:(id<WXMPhotoProtocol>)delegate {
    [WXMManager getGIFByAsset:asset.asset completion:^(NSData *data) {
       [delegate wxm_singlePhotoAlbum_Image_Gif_Video:coverImage data:data];
    }];
}

/** Video */
+ (void)sendVideo:(WXMPhotoAsset *)asset
       coverImage:(UIImage *)coverImage
         delegate:(id<WXMPhotoProtocol>)delegate {
    [WXMManager getVideoByAsset:asset.asset completion:^(NSURL *url, NSData *data) {
        [delegate wxm_singlePhotoAlbum_Image_Gif_Video:coverImage data:data];
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
