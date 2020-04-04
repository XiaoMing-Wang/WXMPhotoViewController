//
//  WXMResourceAssistant.m
//  ModuleDebugging
//
//  Created by edz on 2019/6/13.
//  Copyright © 2019 wq. All rights reserved.
//
#define WXMManager [WXMPhotoManager sharedInstance]

/** 文件管理类 */
#define kFileManager [NSFileManager defaultManager]

/** Library目录 */
#define kLibraryboxPath \
NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject

/** 缓存文件夹 */
#define kCachePath \
[kLibraryboxPath stringByAppendingPathComponent:@"WXMCACHE"]

#define kTargetPath \
[kCachePath stringByAppendingPathComponent:@"PhotoAlbumModule"]

#import "WXMResourceAssistant.h"
#import "WXMPhotoAssistant.h"
#import "WXMPhotoResources.h"
#import "WXMCompression.h"

@implementation WXMResourceAssistant
/**
 有封面图的情况下回调
 
 @param asset 图片资源
 @param coverImage 封面(传过来)
 @param delegate 代理
 */
+ (void)sendResource:(WXMPhotoAsset *)asset
          coverImage:(UIImage *)coverImage
            delegate:(id<WXMPhotoProtocol>)delegate
          isShowLoad:(BOOL)isShowLoad
      viewController:(UIViewController *)controller {
    
    if (isShowLoad && WXMPhotoSelectedImageReturnData) {
        [WXMPhotoAssistant wp_showLoadingView:controller.view];
        controller.view.userInteractionEnabled = NO;
    }
    
    if ([delegate respondsToSelector:@selector(wp_singlePhotoAlbumWithResources:)]) {
        WXMPhotoResources *resource = [WXMPhotoResources new];
        resource.resourceImage = coverImage;
        resource.mediaType = WXMPHAssetMediaTypeImage;
        resource.aspectRatio = asset.aspectRatio;
        if (coverImage) resource.uploadSize = coverImage.size;
        
        /** 0.75接近原始图大小 */
        if (WXMPhotoSelectedImageReturnData) {
            resource.resourceData = UIImageJPEGRepresentation(coverImage, 0.75);
        }
        [delegate wp_singlePhotoAlbumWithResources:resource];
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
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
                isShowLoad:isShowLoad
            viewController:controller];
    }];
}

/** 预览返回带data */
+ (void)sendCoverImage:(UIImage *)coverImage delegate:(id<WXMPhotoProtocol>)delegate {
    if ([delegate respondsToSelector:@selector(wp_singlePhotoAlbumWithResources:)]) {
        NSData *data = nil;
        if (WXMPhotoSelectedImageReturnData) data = UIImageJPEGRepresentation(coverImage, 0.75);
        WXMPhotoResources *resource = [WXMPhotoResources new];
        resource.resourceImage = coverImage;
        resource.resourceData = data;
        [delegate wp_singlePhotoAlbumWithResources:resource];
    }
}

+ (void)getCoverImage:(PHAsset *)asset
            coverSize:(CGSize)coverSize
           completion:(void (^)(UIImage *image))completion {
    [WXMManager synchronousGetPictures:asset size:coverSize completion:^(UIImage *image) {
        if (image && completion) completion(image);
        if (!image) [WXMManager getPicturesOriginal:asset synchronous:YES completion:completion];
    }];
}

#pragma mark 多选

/// 多选
/// @param array 资源数组
/// @param delegate 代理
/// @param isShowVideo 是否支持显示视频(否返回图片 是返回视频data)
/// @param isShowLoad 显示菊花
/// @param controller 回调
+ (void)sendMoreResource:(NSArray <WXMPhotoAsset *>*)array
                delegate:(id<WXMPhotoProtocol>)delegate
             isShowVideo:(BOOL)isShowVideo
              isShowLoad:(BOOL)isShowLoad
          viewController:(UIViewController *)controller {
        
    if (delegate == nil || array.count == 0 ||
        ![delegate respondsToSelector:@selector(wp_morePhotoAlbumWithResources:)]) {
        [controller dismissViewControllerAnimated:YES completion:nil];
        return;
    }
   
    /** 图片转化成data 建议自行转化 */
    BOOL supportVideo = (isShowVideo && WXMPhotoSupportVideo);
    if (WXMPhotoSelectedImageReturnData || array.count >= 3) {
        [WXMPhotoAssistant wp_showLoadingView:controller.view];
        controller.view.userInteractionEnabled = NO;
    }
    
    /** 回调 */
    void (^callback)(NSMutableDictionary *) = ^(NSMutableDictionary *dictionary) {
        NSMutableArray * array = @[].mutableCopy;
        for (NSInteger i = 0; i < dictionary.count; i++) {
            WXMPhotoResources *resource = [dictionary objectForKey:@(i)];
            if (resource != nil) [array addObject:resource];
        }
        [delegate wp_morePhotoAlbumWithResources:array];
        [controller dismissViewControllerAnimated:YES completion:nil];
    };
    
    NSMutableDictionary *dictionary = @{}.mutableCopy;
    for (int i = 0 ; i < array.count; i++) {
        WXMPhotoAsset *photoAsset = [array objectAtIndex:i];
        CGSize size = CGSizeMake(WXMPhoto_Width * 2.0, WXMPhoto_Width * 2.0 * photoAsset.aspectRatio);
        if (size.height * 5 < WXMPhoto_Height) size = PHImageManagerMaximumSize;
                
        [self getCoverImage:photoAsset.asset coverSize:size completion:^(UIImage *image) {
            if (photoAsset.mediaType == WXMPHAssetMediaTypeVideo && supportVideo) {
                
                [WXMPhotoAssistant wp_showLoadingView:controller.view];
                controller.view.userInteractionEnabled = NO;
                [WXMManager getVideoByAsset:photoAsset.asset completion:^(AVURLAsset *asset ,NSURL *url, NSData *data) {
                    
                    /** 视频压缩 */
                    /** 视频压缩 */
                    [WXMPhotoAssistant wp_showLoadingView:controller.view];
                    controller.view.userInteractionEnabled = NO;
                    NSString *timeStemp =
                    [NSString stringWithFormat:@"%zd", (long) [[NSDate date] timeIntervalSince1970]];
                    
                    __block NSString *input = url.absoluteString;
                    __block NSString *output = [NSString stringWithFormat:@"%@.mp4", timeStemp];
                    output = [kTargetPath stringByAppendingPathComponent:output];
                    
                    [WXMCompression wp_compressionVideo:input outString:output avAsset:asset callback:^(BOOL success) {
                        
                        NSString *outputS = [@"file://" stringByAppendingString:output.copy];
                        NSData *newDatas = [NSData dataWithContentsOfURL:[NSURL URLWithString:outputS]];
                        
                        WXMPhotoResources *resource = [WXMPhotoResources new];
                        resource.resourceImage = image;
                        resource.resourceData = success ? newDatas : data;
                        resource.resourceUrl = success ? output.copy : input.copy;
                        resource.mediaType = WXMPHAssetMediaTypeVideo;
                        resource.uploadSize = size;
                        resource.aspectRatio = photoAsset.aspectRatio;
                        [dictionary setObject:resource forKey:@(i)];
                        if (dictionary.allValues.count == array.count) callback(dictionary);
                    }];
                }];
                
                
            } else {
                
                
                NSData *data = nil;
                if (WXMPhotoSelectedImageReturnData) {
                    data = UIImageJPEGRepresentation(image, WXMPhotoCompressionRatio);
                }
                
                WXMPhotoResources *resource = [WXMPhotoResources new];
                resource.resourceImage = image;
                resource.resourceData = data;
                resource.mediaType = WXMPHAssetMediaTypeImage;
                resource.aspectRatio = photoAsset.aspectRatio;
                resource.uploadSize = size;
                [dictionary setObject:resource forKey:@(i)];
                if (dictionary.allValues.count == array.count) callback(dictionary);
                
            }
        }];
    }
}

///// 压缩视频
///// @param inputString 输入路径
///// @param outString 输出路径
///// @param callback 回调
//+ (void)compressedVideo:(NSString *)inputString
//              outString:(NSString *)outString
//               callback:(void (^)(BOOL success))callback {
//
//    JJVideoCompression *compression = [[JJVideoCompression alloc]init];
//    compression.inputURL = [NSURL URLWithString:inputString]; /**  视频输入路径 */
//    compression.exportURL = [NSURL fileURLWithPath:outString]; /**  视频输出路径 */
//
//    JJAudioConfigurations audioConfigurations;/**  音频压缩配置 */
//    audioConfigurations.samplerate = JJAudioSampleRate_11025Hz; /**  采样率 */
//    audioConfigurations.bitrate = JJAudioBitRate_32Kbps;/** / 音频的码率 */
//    audioConfigurations.numOfChannels = 1;/**  声道数 */
//    audioConfigurations.frameSize = 8; /**  采样深度 */
//    compression.audioConfigurations = audioConfigurations;
//
//    JJVideoConfigurations videoConfigurations;
//    videoConfigurations.fps = 25; /**  帧率 一秒中有多少帧 */
//    videoConfigurations.videoBitRate = JJ_VIDEO_BITRATE_HIGH; /**  视频质量 码率 */
//    videoConfigurations.videoResolution =  JJ_VIDEO_RESOLUTION_SUPER_HIGH; /** 视频尺寸 */
//    compression.videoConfigurations = videoConfigurations;
//    [compression startCompressionWithCompletionHandler:^(JJVideoCompressionState State) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (State == JJ_VIDEO_STATE_FAILURE) {
//                NSLog(@"压缩失败");
//                if (callback) callback(NO);
//            } else {
//                NSLog(@"压缩成功");
//                if (callback) callback(YES);
//            }
//        });
//    }];
//}
@end
