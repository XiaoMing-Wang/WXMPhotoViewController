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
#import "JJVideoCompression.h"

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
    [WXMManager wxm_synchronousGetPictures:asset size:coverSize completion:completion];
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
    BOOL supportVideo = (isShowVideo && WXMPhotoSupportVideo);
    if (WXMPhotoSelectedImageReturnData) {
        [WXMPhotoAssistant wxm_showLoadingView:controller.view];
    }
      
    __block NSMutableDictionary *dic = @{}.mutableCopy;
    dispatch_group_t group = dispatch_group_create();
    [array enumerateObjectsUsingBlock:^(WXMPhotoAsset *obj, NSUInteger idx, BOOL *stop) {
                               
        CGSize size = CGSizeMake(coverSize.width, coverSize.height);
        if (CGSizeEqualToSize(size, CGSizeZero)) {
            size = CGSizeMake(WXMPhoto_Width * 2, WXMPhoto_Width * obj.aspectRatio * 2);
            if (size.height * 5 < WXMPhoto_Height) size = PHImageManagerMaximumSize;
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
    
    dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC));
    dispatch_after(when, dispatch_get_main_queue(), ^{
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            NSMutableArray * array = @[].mutableCopy;
            for (NSInteger i = 0; i < dic.count; i++) {
                WXMPhotoResources *resource = [dic objectForKey:@(i)];
                if (resource != nil) [array addObject:resource];
            }
            [delegate wxm_morePhotoAlbumWithResources:array];
            [controller dismissViewControllerAnimated:YES completion:nil];
        });
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
        resource.uploadSize = coverImage.size;
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

/// 压缩视频
/// @param inputString 输入路径
/// @param outString 输出路径
/// @param callback 回调
+ (void)compressedVideo:(NSString *)inputString
              outString:(NSString *)outString
               callback:(void (^)(BOOL success))callback {
    
    JJVideoCompression *compression = [[JJVideoCompression alloc]init];
    compression.inputURL = [NSURL URLWithString:inputString]; /**  视频输入路径 */
    compression.exportURL = [NSURL fileURLWithPath:outString]; /**  视频输出路径 */
    
    JJAudioConfigurations audioConfigurations;/**  音频压缩配置 */
    audioConfigurations.samplerate = JJAudioSampleRate_11025Hz; /**  采样率 */
    audioConfigurations.bitrate = JJAudioBitRate_32Kbps;/** / 音频的码率 */
    audioConfigurations.numOfChannels = 1;/**  声道数 */
    audioConfigurations.frameSize = 8; /**  采样深度 */
    compression.audioConfigurations = audioConfigurations;
    
    JJVideoConfigurations videoConfigurations;
    videoConfigurations.fps = 25; /**  帧率 一秒中有多少帧 */
    videoConfigurations.videoBitRate = JJ_VIDEO_BITRATE_HIGH; /**  视频质量 码率 */
    videoConfigurations.videoResolution =  JJ_VIDEO_RESOLUTION_SUPER_HIGH; /** 视频尺寸 */
    compression.videoConfigurations = videoConfigurations;
    [compression startCompressionWithCompletionHandler:^(JJVideoCompressionState State) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (State == JJ_VIDEO_STATE_FAILURE) {
                NSLog(@"压缩失败");
                if (callback) callback(NO);
            } else {
                NSLog(@"压缩成功");
                if (callback) callback(YES);
            }
        });
    }];
}
@end
