//
//  FZJPhotoTool.m
//  FZJPhotosFrameWork
//
//  Created by wq on 16/1/10.
//  Copyright © 2016年 wq. All rights reserved.
//

#import "WXMPhotoManager.h"
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import <AssetsLibrary/ALAssetsGroup.h>
#import <AssetsLibrary/ALAssetsLibrary.h>

@implementation WXMPhotoList @end
@implementation WXMPhotoAsset
- (WXMPhotoMediaType)mediaType {
    if (self.asset.mediaType == PHAssetMediaTypeVideo) return WXMPHAssetMediaTypeVideo;
    if (self.asset.mediaType == PHAssetMediaTypeAudio) return WXMPHAssetMediaTypeAudio;
    if (self.asset.mediaType == PHAssetMediaTypeImage) {
        if (@available(iOS 9.1, *)) {
            if (self.asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
                return WXMPHAssetMediaTypeLivePhoto;
            }
        }

        if ([[self.asset valueForKey:@"filename"] hasSuffix:@"GIF"]) {
            return WXMPHAssetMediaTypePhotoGif;
        }
    }
    return WXMPHAssetMediaTypeImage;
}

/** 获取视频时长 */
- (NSString *)videoDrantion {
    if (self.mediaType != WXMPHAssetMediaTypeVideo) return @"";
    NSString *videoDrantion = [NSString stringWithFormat:@"%0.0f",self.asset.duration];
    NSInteger videoDrantionInt = videoDrantion.integerValue;
    
    NSString *drantionString = @"";
    NSInteger minutes = videoDrantionInt / 60;
    NSInteger seconds = videoDrantionInt % 60;
    drantionString = [NSString stringWithFormat:@"%02zd:%02zd",minutes,seconds];
    return drantionString;
}

/** 获取相片宽高比 */
- (CGFloat)aspectRatio {
    CGFloat width = (CGFloat) self.asset.pixelWidth;
    CGFloat height = (CGFloat) self.asset.pixelHeight;
    return height / width * 1.0;
}
@end

@implementation WXMPhotoManager

static WXMPhotoManager *manager = nil;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

/** 是否有权限 */
- (BOOL)wxm_photoPermission {
    if (PHPhotoLibrary.authorizationStatus == AVAuthorizationStatusNotDetermined ||
        PHPhotoLibrary.authorizationStatus == AVAuthorizationStatusAuthorized) {
        return YES;
    }
    
    NSString *msg = @"请在系统设置中打开“允许访问照片”，否则将无法获取照片";
    UIAlertController*al= [UIAlertController alertControllerWithTitle:@"提示" message:msg preferredStyle:1];
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:1 handler:nil];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"去开启" style:0 handler:^(UIAlertAction *acs) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    [al addAction:cancle];
    [al addAction:action];
    UIWindow * window = [[[UIApplication sharedApplication] delegate] window];
    UIViewController * root = window.rootViewController.presentedViewController?:window.rootViewController;
    [root presentViewController:al animated:YES completion:nil];
    return NO;
}

/** 相册名称转换 */
- (NSString *)wxm_transformAblumTitle:(NSString *)title {
    if ([title isEqualToString:@"Slo-mo"]) return @"慢动作";
    else if ([title isEqualToString:@"Recently Added"])  return @"最近添加";
    else if ([title isEqualToString:@"Favorites"]) return @"个人收藏";
    else if ([title isEqualToString:@"Recently Deleted"])         return @"最近删除";
    else if ([title isEqualToString:@"Videos"])  return @"视频";
    else if ([title isEqualToString:@"All Photos"]) return @"所有照片";
    else if ([title isEqualToString:@"Selfies"]) return @"自拍";
    else if ([title isEqualToString:@"Screenshots"]) return @"屏幕快照";
    else if ([title isEqualToString:@"Camera Roll"]) return @"相机胶卷";
    else if ([title isEqualToString:@"My Photo Stream"]) return @"我的照片流";
    else if ([title isEqualToString:@"Hidden"]) return @"隐藏";
    else if ([title isEqualToString:@"Bursts"]) return @"连拍快照";
    return title;
}

/** 获得所有的相册对象*/
- (void)wxm_getAllPicturesListBlock:(void(^)(NSArray<WXMPhotoList *> *))block {
    
    @autoreleasepool {
        NSMutableArray<WXMPhotoList *> *photoList = @[].mutableCopy;
        
        /** 获取系统相册 */
        PHFetchResult * album = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        
        [album enumerateObjectsUsingBlock:^(PHAssetCollection *collection,NSUInteger idx,BOOL*stop){
            
            /** 去掉视频和最近删除的 */
            if (!([collection.localizedTitle isEqualToString:@"Recently Deleted"] ||
                  [collection.localizedTitle isEqualToString:@"Hidden"]||
                  [collection.localizedTitle isEqualToString:@"最近删除"])){
                
                PHFetchResult *result = [self fetchAssetsInAssetCollection:collection ascending:NO];
                if (result.count > 0) {
                    WXMPhotoList *list = [[WXMPhotoList alloc] init];
                    list.title = [self wxm_transformAblumTitle:collection.localizedTitle];
                    list.photoNum = result.count;
                    list.firstAsset = result.firstObject;
                    list.assetCollection = collection;
                    if ([list.title isEqualToString:@"相机胶卷"] || [list.title isEqualToString:@"Live Photos"]) {
                        [photoList insertObject:list atIndex:0];
                    } else {
                        [photoList addObject:list];
                    }
                    
                    if (idx == 0) self.firstPhotoList = list;
                    if ([list.title isEqualToString:@"相机胶卷"]) self.firstPhotoList = list;
                }
            }
        }];
        
        
        /** 用户创建的相册 */
        PHFetchResult * userAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
        [userAlbum enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL *stop) {
            PHFetchResult *result = [self fetchAssetsInAssetCollection:collection ascending:NO];
            if (result.count > 0) {
                WXMPhotoList *list = [[WXMPhotoList alloc] init];
                list.title = [self wxm_transformAblumTitle:collection.localizedTitle];
                list.photoNum = result.count;
                list.firstAsset = result.firstObject;
                list.assetCollection = collection;
                if ([list.title isEqualToString:@"我的照片流"] && photoList.count >= 1) {
                    [photoList insertObject:list atIndex:1];
                } else {
                    [photoList addObject:list];
                }
            }
        }];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!self.firstPhotoList) self.firstPhotoList = photoList.firstObject;
            self.picturesArray = photoList;
            if (block) block(photoList);
        });
    } 
}

/** 获取相册结果集 */
- (PHFetchResult *)fetchAssetsInAssetCollection:(PHAssetCollection*)assetCollection ascending:(BOOL)asc {
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:asc]];
    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:option];
    return result;
}

#pragma mark ________________________________________________________ 获取asset相对应的照片

/** 获取原生和非原生图片 */
- (int32_t)getPicturesByAsset:(PHAsset *)asset
                  synchronous:(BOOL)synchronous
                     original:(BOOL)original
                    assetSize:(CGSize)assetSize
                   resizeMode:(PHImageRequestOptionsResizeMode)resizeMode
                 deliveryMode:(PHImageRequestOptionsDeliveryMode)deliveryMode
                   completion:(void (^)(UIImage *AssetImage))completion {
    
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    /**
     resizeMode：对请求的图像怎样缩放。有三种选择：
     None，不缩放； PHImageRequestOptionsResizeModeNone
     Fast，尽快地提供接近或稍微大于要求的尺寸；
     Exact，精准提供要求的尺寸。PHImageRequestOptionsResizeModeExact
     
     deliveryMode：图像质量。有三种值：
     Opportunistic，在速度与质量中均衡；
     HighQualityFormat，不管花费多长时间，提供高质量图像；
     FastFormat，以最快速度提供好的质量。
     这个属性只有在 synchronous 为 YES 时有效。
     */
    
    /** 控制照片尺寸 */
    option.resizeMode = resizeMode;

    /** 控制照片质量 */
    option.deliveryMode = deliveryMode;

    /** 是否同步获取 */
    if (synchronous == YES) option.synchronous = YES;
    
    CGSize size = assetSize;
    if (original) {
        size = PHImageManagerMaximumSize;
    }  else {
        size = assetSize;
    }
    
    /** 下载图片 */
    /** option.networkAccessAllowed = YES; */
    /**  targetSize 即你想要的图片尺寸，若想要原尺寸则可输入PHImageManagerMaximumSize */
    int32_t requestID = [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage *image, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(image);
        });
    }];
    return requestID;
}

/** 获取高质量原图 */
- (int32_t)getPictures_original:(PHAsset *)asset
                    synchronous:(BOOL)synchronous
                     completion:(void (^)(UIImage *AssetImage))completion {
    
    /** PHImageRequestOptionsResizeModeExact精准大小 */
    return [self getPicturesByAsset:asset
                        synchronous:synchronous
                           original:YES
                          assetSize:PHImageManagerMaximumSize
                         resizeMode:PHImageRequestOptionsResizeModeNone
                       deliveryMode:PHImageRequestOptionsDeliveryModeHighQualityFormat
                         completion:completion];
}

/** 获取自定义尺寸 设置PHImageRequestOptionsResizeModeExact是有效 */
- (int32_t)getPictures_customSize:(PHAsset *)asset
                      synchronous:(BOOL)synchronous
                        assetSize:(CGSize)assetSize
                       completion:(void (^)(UIImage *image))completion {
    
    return [self getPicturesByAsset:asset
                        synchronous:synchronous
                           original:NO
                          assetSize:assetSize
                         resizeMode:PHImageRequestOptionsResizeModeFast
                       deliveryMode:PHImageRequestOptionsDeliveryModeHighQualityFormat
                         completion:completion];
}

/** 同步获取图片 */
- (int32_t)wxm_synchronousGetPictures:(PHAsset *)asset
                                 size:(CGSize)size
                           completion:(void (^)(UIImage *image))comple {
    
    if (CGSizeEqualToSize(size, CGSizeZero) ||
        CGSizeEqualToSize(size, PHImageManagerMaximumSize)) {
        return [self getPictures_original:asset
                              synchronous:YES
                               completion:comple];
    } else {
        return [self getPicturesByAsset:asset
                            synchronous:YES
                               original:NO
                              assetSize:size
                             resizeMode:PHImageRequestOptionsResizeModeExact
                           deliveryMode:PHImageRequestOptionsDeliveryModeHighQualityFormat
                             completion:comple];
    }
}

/** GIF */
- (int32_t)getGIFByAsset:(PHAsset *)asset completion:(void (^)(NSData *))completion {
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    option.synchronous = NO;
    option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    return [[PHCachingImageManager defaultManager]  requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(imageData);
        });
    }];
}

/** Image */
- (int32_t)getImageByAsset:(PHAsset *)asset completion:(void (^)(NSData *))completion {
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    option.synchronous = YES;
    option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    return [[PHCachingImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(imageData);
        });
    }];
}

/** 取到所有相册 的所有PHAsset资源 */
- (NSArray<PHAsset *> *)wxm_getAllAssetInPhotoAblumWithAscending:(BOOL)ascending {
    NSMutableArray<PHAsset *> *assets = @[].mutableCopy;
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    /** ascending 为YES时，按照照片的创建时间升序排列;为NO时，则降序排列 */
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
    PHFetchResult *result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:option];
    [result enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        PHAsset *asset = (PHAsset *) obj;
        [assets addObject:asset];
    }];
    return assets;
}

/** 获得指定相册的PHAsset资源 */
- (NSArray<PHAsset *> *)wxm_getAssetsInAssetCollection:(PHAssetCollection *)assetCollection
                                             ascending:(BOOL)ascending {
    NSMutableArray<PHAsset *> *arr = @[].mutableCopy;
    PHFetchResult *result = [self fetchAssetsInAssetCollection:assetCollection ascending:ascending];
    [result enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        [arr addObject:obj];
    }];
    return arr;
}

/** 获取视频 */
- (void)getVideoByAsset:(PHAsset *)assetData completion:(void (^)(NSURL * , NSData *))completiont {
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.version = PHImageRequestOptionsVersionCurrent;
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    [[PHImageManager defaultManager] requestAVAssetForVideo:assetData options:options resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
        // 获取信息 asset audioMix info
        // 上传视频时用到data
        AVURLAsset *urlAsset = (AVURLAsset *)asset;
        NSURL *url = urlAsset.URL;
        NSData *data = [NSData dataWithContentsOfURL:url];
        dispatch_async(dispatch_get_main_queue(), ^{
            completiont(url, data);
        });
    }];
}

/** 获取livePhoto */
- (void)getLivePhotoByAsset:(PHAsset *)assetData
                   liveSize:(CGSize)liveSize
                 completion:(void (^)(PHLivePhoto *))completiont {
        
    if (@available(iOS 9.1, *)) {
        PHLivePhotoRequestOptions *options = [[PHLivePhotoRequestOptions alloc]init];
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.networkAccessAllowed = YES;
        PHImageManager * manager = [PHImageManager defaultManager];
        [manager requestLivePhotoForAsset:assetData targetSize:liveSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(PHLivePhoto *livePhoto,NSDictionary* info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completiont(livePhoto);
            });
        }];
    }
}

/** 取消 */
- (void)cancelRequestWithID:(int32_t)requestID {
    [[PHCachingImageManager defaultManager] cancelImageRequest:requestID];
}
@end
