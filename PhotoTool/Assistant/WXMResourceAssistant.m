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
[kLibraryboxPath stringByAppendingPathComponent:@"Caches"]

#define kTargetPath kCachePath

#include <zlib.h>
#include <CommonCrypto/CommonCrypto.h>
#import <CoreText/CoreText.h>
#import <objc/runtime.h>
#import "WXMResourceAssistant.h"
#import "WXMPhotoUIAssistant.h"
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
        [WXMPhotoUIAssistant showLoadingView:controller.view];
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

+ (void)getCoverImage:(PHAsset *)asset coverSize:(CGSize)coverSize completion:(void (^)(UIImage *image))completion {
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
        
    if (delegate == nil || array.count == 0 || ![delegate respondsToSelector:@selector(wp_morePhotoAlbumWithResources:)]) {
        [controller dismissViewControllerAnimated:YES completion:nil];
        return;
    }
   
    /** 图片转化成data */
    BOOL supportVideo = (isShowVideo && WXMPhotoSupportVideo);
     
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
        CGSize size = CGSizeMake(WXMPhoto_Width * 2, WXMPhoto_Width * 2 * photoAsset.aspectRatio);
        if (size.height * 5 < WXMPhoto_Height) size = PHImageManagerMaximumSize;
                
        [self getCoverImage:photoAsset.asset coverSize:size completion:^(UIImage *image) {
            if (photoAsset.mediaType == WXMPHAssetMediaTypeVideo && supportVideo) {
                
                controller.view.userInteractionEnabled = NO;
                [WXMPhotoUIAssistant showLoadingView:controller.view];
                [WXMManager getVideoByAsset:photoAsset.asset completion:^(AVURLAsset *asset, NSURL *url, NSData *data) {
                    
                    NSString *input = url.absoluteString;
                    NSString *encodedString = input;
                    CGFloat dataSize = data.length / 1024/ 1024;
                    if (dataSize <= 120)  { encodedString = [self base64EncodedString:[self getMD5Data:data]]; }
                    else { encodedString = [self base64EncodedString:[self md5String:input]]; }
                    
                    encodedString = [encodedString stringByAppendingString:@".mp4"];
                    WXMPhotoResources *resource = [WXMPhotoResources new];
                    resource.resourceImage = image;
                    resource.nativeUrl = input.copy;
                    resource.asset = asset;
                    resource.resourceUrl = input;
                    resource.mediaType = WXMPHAssetMediaTypeVideo;
                    resource.uploadSize = size;
                    resource.objKey = encodedString;
                    resource.aspectRatio = photoAsset.aspectRatio;
                    resource.videoDrantion = photoAsset.videoDrantion;
                    resource.assetDrantion = photoAsset.assetDrantion;
                    [dictionary setObject:resource forKey:@(i)];
                    if (dictionary.allValues.count == array.count) callback(dictionary);
                    
                }];
                
                
            } else if (photoAsset.mediaType == WXMPHAssetMediaTypePhotoGif) {
                
                controller.view.userInteractionEnabled = NO;
                [WXMPhotoUIAssistant showLoadingView:controller.view];
                [WXMManager getGIFByAsset:photoAsset.asset completion:^(NSData *data) {
                    WXMPhotoResources *resource = [WXMPhotoResources new];
                    resource.resourceImage = image;
                    resource.mediaType = WXMPHAssetMediaTypePhotoGif;
                    resource.aspectRatio = photoAsset.aspectRatio;
                    resource.uploadSize = size;
                    resource.resourceData = data;
                    [dictionary setObject:resource forKey:@(i)];
                    if (dictionary.allValues.count == array.count) callback(dictionary);
                }];
                
            } else {
                
                WXMPhotoResources *resource = [WXMPhotoResources new];
                resource.resourceImage = image;
                resource.mediaType = WXMPHAssetMediaTypeImage;
                resource.aspectRatio = photoAsset.aspectRatio;
                resource.uploadSize = size;
                [dictionary setObject:resource forKey:@(i)];
                if (dictionary.allValues.count == array.count) callback(dictionary);
            }
        }];
    }
}

/** md5 */
+ (NSString *)md5String:(NSString *)astring {
    NSData *data = [astring dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data.bytes, (CC_LONG) data.length, result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ].lowercaseString;
}

/** md5 */
+ (NSString *)getMD5Data:(NSData *)data {
    @try {
        
        if (!data) return nil;
        //需要MD5变量并且初始化
        CC_MD5_CTX  md5;
        CC_MD5_Init(&md5);
        //开始加密(第一个参数：对md5变量去地址，要为该变量指向的内存空间计算好数据，第二个参数：需要计算的源数据，第三个参数：源数据的长度)
        CC_MD5_Update(&md5, data.bytes, (CC_LONG)data.length);
        //声明一个无符号的字符数组，用来盛放转换好的数据
        unsigned char result[CC_MD5_DIGEST_LENGTH];
        //将数据放入result数组
        CC_MD5_Final(result, &md5);
        //将result中的字符拼接为OC语言中的字符串，以便我们使用。
        NSMutableString *resultString = [NSMutableString string];
        for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
            [resultString appendFormat:@"%02X",result[i]];
        }
        return resultString;
        
    } @catch (NSException *exception) { } @finally { }
}

/**  转换为Base64编码 */
+ (NSString *)base64EncodedString:(NSString *)astring {
    NSData *data = [astring dataUsingEncoding:NSUTF8StringEncoding];
    return [data base64EncodedStringWithOptions:0];
}

@end
