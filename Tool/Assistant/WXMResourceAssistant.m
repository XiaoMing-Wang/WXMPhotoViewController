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
#import "WXMPhotoResources.h"

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
    
    if ([delegate respondsToSelector:@selector(wxm_singlePhotoAlbumWithResources:)]) {
        controller.view.userInteractionEnabled = NO;
        WXMPhotoResources *resource = [WXMPhotoResources new];
        resource.resourceImage = coverImage;
        resource.mediaType = asset.mediaType;
        
        if (asset.mediaType == WXMPHAssetMediaTypePhotoGif) {
            [WXMManager getGIFByAsset:asset.asset completion:^(NSData *data) {
                resource.resourceData = data;
                [delegate wxm_singlePhotoAlbumWithResources:resource];
                [controller dismissViewControllerAnimated:YES completion:nil];
            }];
            
        } else if (asset.mediaType == WXMPHAssetMediaTypeVideo && supportVideo) {
            [WXMManager getVideoByAsset:asset.asset completion:^(NSURL *url, NSData *data) {
                resource.resourceData = data;
                [delegate wxm_singlePhotoAlbumWithResources:resource];
                [controller dismissViewControllerAnimated:YES completion:nil];
            }];
            
        } else {
            
            /** 不支持视频 */
            resource.mediaType = WXMPHAssetMediaTypeImage;
            if (isShowLoad && WXMPhotoSelectedImageReturnData) {
                [WXMPhotoAssistant wxm_showLoadingView:controller.view];
            }
            NSData *data = nil; /** 0.75接近原始图大小 */
            if (WXMPhotoSelectedImageReturnData) data = UIImageJPEGRepresentation(coverImage, 0.75);
            resource.resourceData = data;
            [delegate wxm_singlePhotoAlbumWithResources:resource];
            [controller dismissViewControllerAnimated:YES completion:nil];
        }
    } else [controller dismissViewControllerAnimated:YES completion:nil];
}

/** 获取特定大小图片在获取data */
+ (void)sendResource:(WXMPhotoAsset *)asset
           coverSize:(CGSize)coverSize
            delegate:(id<WXMPhotoProtocol>)delegate
         isShowVideo:(BOOL)isShowVideo
          isShowLoad:(BOOL)isShowLoad
      viewController:(UIViewController *)controller {
    [self getCoverImage:asset.asset coverSize:coverSize completion:^(UIImage *image) {
        [self sendResource:asset
                coverImage:image
                  delegate:delegate
               isShowVideo:isShowVideo
                isShowLoad:isShowLoad
            viewController:controller];
    }];
}

+ (void)sendCoverImage:(UIImage *)coverImage delegate:(id<WXMPhotoProtocol>)delegate {
    if ([delegate respondsToSelector:@selector(wxm_singlePhotoAlbumWithResources:)]) {
        NSData *data = nil;
        if (WXMPhotoSelectedImageReturnData) data = UIImageJPEGRepresentation(coverImage, 0.75);
        WXMPhotoResources *resource = [WXMPhotoResources new];
        resource.resourceImage = coverImage;
        resource.resourceData = data;
        [delegate wxm_singlePhotoAlbumWithResources:resource];
    }
}

#pragma mark 多选
+ (void)getCoverImage:(PHAsset *)asset
            coverSize:(CGSize)coverSize
           completion:(void (^)(UIImage *image))completion {
    [WXMManager getPicturesByAsset:asset
                       synchronous:YES
                          original:NO
                         assetSize:coverSize
                        resizeMode:PHImageRequestOptionsResizeModeExact
                      deliveryMode:PHImageRequestOptionsDeliveryModeHighQualityFormat
                        completion:completion];
}

+ (void)sendMoreResource:(NSArray <WXMPhotoAsset *>*)array
               coverSize:(CGSize)coverSize
                delegate:(id<WXMPhotoProtocol>)delegate
             isShowVideo:(BOOL)isShowVideo
              isShowLoad:(BOOL)isShowLoad
          viewController:(UIViewController *)controller {
    if (delegate == nil || array.count == 0 ||
        ![delegate respondsToSelector:@selector(wxm_morePhotoAlbumWithResources:)]) {
        [controller dismissViewControllerAnimated:YES completion:nil];
        return;
    }
   
    /** 图片转化成data 建议自行转化 */
    if (WXMPhotoSelectedImageReturnData) [WXMPhotoAssistant wxm_showLoadingView:controller.view];
    BOOL supportVideo = (isShowVideo && WXMPhotoSupportVideo);
    __block NSMutableDictionary *dic = @{}.mutableCopy;
    dispatch_group_t group = dispatch_group_create();
    
    [array enumerateObjectsUsingBlock:^(WXMPhotoAsset *obj, NSUInteger idx, BOOL *stop) {
        CGSize size = CGSizeMake(coverSize.width, coverSize.height);
        if (CGSizeEqualToSize(size, CGSizeZero)) {
            size = CGSizeMake(WXMPhoto_Width*2, WXMPhoto_Width * obj.aspectRatio * 2);
            if (size.height * 2.5 < WXMPhoto_Height * 2) size = PHImageManagerMaximumSize;
        }
             
        dispatch_group_enter(group);
        [self getCoverImage:obj.asset coverSize:size completion:^(UIImage *image) {
            if (obj.mediaType == WXMPHAssetMediaTypePhotoGif) {
                [self sendGif:obj coverImage:image dictionary:dic idx:idx group:group];
            } else if (obj.mediaType == WXMPHAssetMediaTypeVideo && supportVideo) {
                [self sendVideo:obj coverImage:image dictionary:dic idx:idx group:group];
            } else {
                [self sendImage:obj coverImage:image dictionary:dic idx:idx group:group];
            }
        }];
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSMutableArray * array = @[].mutableCopy;
        for (NSInteger i = 0; i < dic.count; i++) {
            WXMPhotoResources *resource = [dic objectForKey:@(i)];
            if (resource != nil) [array addObject:resource];
        }
        [delegate wxm_morePhotoAlbumWithResources:array];
        [controller dismissViewControllerAnimated:YES completion:nil];
    });
}


/** Gif */
+ (void)sendGif:(WXMPhotoAsset *)asset
     coverImage:(UIImage *)coverImage
     dictionary:(NSMutableDictionary *)dictionary
            idx:(NSInteger)idx
            group:(dispatch_group_t)group {
    [WXMManager getGIFByAsset:asset.asset completion:^(NSData *data) {
        WXMPhotoResources *resource = [WXMPhotoResources new];
        resource.resourceImage = coverImage;
        resource.resourceData = data;
        resource.mediaType = WXMPHAssetMediaTypePhotoGif;
        [dictionary setObject:resource forKey:@(idx)];
        dispatch_group_leave(group);
    }];
}


/** Video */
+ (void)sendVideo:(WXMPhotoAsset *)asset
       coverImage:(UIImage *)coverImage
       dictionary:(NSMutableDictionary *)dictionary
              idx:(NSInteger)idx
            group:(dispatch_group_t)group {
    [WXMManager getVideoByAsset:asset.asset completion:^(NSURL *url, NSData *data) {
        WXMPhotoResources *resource = [WXMPhotoResources new];
        resource.resourceImage = coverImage;
        resource.resourceData = data;
        resource.mediaType = WXMPHAssetMediaTypeVideo;
        [dictionary setObject:resource forKey:@(idx)];
        dispatch_group_leave(group);
    }];
}

/** Image */
+ (void)sendImage:(WXMPhotoAsset *)asset
       coverImage:(UIImage *)coverImage
       dictionary:(NSMutableDictionary *)dictionary
              idx:(NSInteger)idx
            group:(dispatch_group_t)group {
    NSData *data = nil;
    if (WXMPhotoSelectedImageReturnData) {
        data = UIImageJPEGRepresentation(coverImage, WXMPhotoCompressionRatio);
    }
    WXMPhotoResources *resource = [WXMPhotoResources new];
    resource.resourceImage = coverImage;
    resource.resourceData = data;
    resource.mediaType = WXMPHAssetMediaTypeImage;
    [dictionary setObject:resource forKey:@(idx)];
    dispatch_group_leave(group);
}
@end
