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
@implementation WXMPhotoAsset @end
@implementation WXMPhotoManager

+ (instancetype)sharedInstance {
    static WXMPhotoManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}
/** 是否有权限 */
- (BOOL)photoPermission {
    if (PHPhotoLibrary.authorizationStatus == AVAuthorizationStatusNotDetermined ||
        PHPhotoLibrary.authorizationStatus == AVAuthorizationStatusAuthorized) {
        return YES;
    }
    
    NSString *msg = @"请在系统设置中打开“允许访问照片”，否则将无法获取照片";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"去开启" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    [alert addAction:cancle];
    [alert addAction:action];
    UIWindow * window = [[[UIApplication sharedApplication] delegate] window];
    [window.rootViewController presentViewController:alert animated:YES completion:nil];
    return NO;
}
/** 相册名称转换 */
- (NSString *)transformAblumTitle:(NSString *)title {
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
    return title;
}

- (PHFetchResult *)fetchAssetsInAssetCollection:(PHAssetCollection *)assetCollection ascending:(BOOL)ascending {
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:option];
    return result;
}

/** 获得所有的相册对象*/
- (void)getAllPhotoListBlock:(void(^)(NSArray<WXMPhotoList *> *))block {
    NSMutableArray<WXMPhotoList *> *photoList = @[].mutableCopy;
    
    /** 获取系统相册 */
    PHFetchResult * smartAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    [smartAlbum enumerateObjectsUsingBlock:^(PHAssetCollection * collection, NSUInteger idx, BOOL * stop) {
        
        /** 去掉视频和最近删除的 */
        if (!([collection.localizedTitle isEqualToString:@"Recently Deleted"] ||
              [collection.localizedTitle isEqualToString:@"Videos"]||
              [collection.localizedTitle isEqualToString:@"Hidden"]||
              [collection.localizedTitle isEqualToString:@"最近删除"]||
              [collection.localizedTitle isEqualToString:@"视频"])){
            
            PHFetchResult *result = [self fetchAssetsInAssetCollection:collection ascending:NO];
            if (result.count > 0) {
                WXMPhotoList *list = [[WXMPhotoList alloc] init];
                list.title = [self transformAblumTitle:collection.localizedTitle];
                list.photoNum = result.count;
                list.firstAsset = result.firstObject;
                list.assetCollection = collection;
                [photoList addObject:list];
                if (idx == 0) [WXMPhotoManager sharedInstance].firstPhotoList = list;
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
            list.title = collection.localizedTitle;
            list.photoNum = result.count;
            list.firstAsset = result.firstObject;
            list.assetCollection = collection;
            [photoList addObject:list];
        }
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.photoData = photoList.mutableCopy;
        if (block) block(photoList);
    });
}

#pragma mark ________________________________________________________ 获取asset相对应的照片

- (void)getImageByAsset:(PHAsset *)asset
         makeResizeMode:(PHImageRequestOptionsResizeMode)resizeMode
             isOriginal:(BOOL)original
             completion:(void (^)(UIImage *))completion {

    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    /**
     resizeMode：对请求的图像怎样缩放。有三种选择：
     None，不缩放；
     Fast，尽快地提供接近或稍微大于要求的尺寸；
     Exact，精准提供要求的尺寸。
     
     deliveryMode：图像质量。有三种值：
     Opportunistic，在速度与质量中均衡；
     HighQualityFormat，不管花费多长时间，提供高质量图像；
     FastFormat，以最快速度提供好的质量。
     这个属性只有在 synchronous 为 YES 时有效。
     */
    option.resizeMode = resizeMode;//控制照片尺寸
    option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;//控制照片质量
    
    //同步获取
    option.synchronous = YES;
    CGSize size = original ? PHImageManagerMaximumSize : CGSizeZero;
    //下载图片
    //option.networkAccessAllowed = YES;
    // param：targetSize 即你想要的图片尺寸，若想要原尺寸则可输入PHImageManagerMaximumSize
    [[PHCachingImageManager defaultManager] requestImageForAsset:asset
                                                      targetSize:size
                                                     contentMode:PHImageContentModeAspectFit
                                                         options:option
                                                   resultHandler:^(UIImage *_Nullable image, NSDictionary *_Nullable info) {
                                                       completion(image);
                                                   }];
}

#pragma mark __________________________________________________ 获取视频
- (void)getVideoByAsset:(PHAsset *)asset completion:(void (^)(NSDictionary *))completiont {}

#pragma mark ____________________________________________________ 获取PHAsset指定尺寸的照片

- (void)getImageByAsset_Synchronous:(PHAsset *)asset
                               size:(CGSize)size
                         completion:(void (^)(UIImage *))completion {
    
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = PHImageRequestOptionsResizeModeNone;//控制照片尺寸
    option.synchronous = YES;
    option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    [[PHCachingImageManager defaultManager] requestImageForAsset:asset
                                                      targetSize:size
                                                     contentMode:PHImageContentModeAspectFill
                                                         options:option
                                                   resultHandler:^(UIImage *image, NSDictionary *info) {
                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                           completion(image);
                                                       });
                                                   }];
}
- (void)getImageByAsset_Asynchronous:(PHAsset *)asset
                                size:(CGSize)size
                          completion:(void (^)(UIImage *))completion {
    
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = PHImageRequestOptionsResizeModeNone;//控制照片尺寸
    option.synchronous = NO;
    option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    [[PHCachingImageManager defaultManager] requestImageForAsset:asset
                                                      targetSize:size
                                                     contentMode:PHImageContentModeAspectFill
                                                         options:option
                                                   resultHandler:^(UIImage *image, NSDictionary *info) {
                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                           completion(image);
                                                       });
                                                   }];
}

#pragma mark __________________________________________________ 取到所有相册 的所有PHAsset资源

- (NSArray<PHAsset *> *)getAllAssetInPhotoAblumWithAscending:(BOOL)ascending {
    NSMutableArray<PHAsset *> *assets = @[].mutableCopy;
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    // ascending 为YES时，按照照片的创建时间升序排列;为NO时，则降序排列
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
    PHFetchResult *result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:option];
    [result enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        PHAsset *asset = (PHAsset *) obj;
        [assets addObject:asset];
    }];
    return assets;
}

#pragma mark __________________________________________________ 获得指定相册的PHAsset资源

- (NSArray<PHAsset *> *)getAssetsInAssetCollection:(PHAssetCollection *)assetCollection
                                         ascending:(BOOL)ascending {
    
    NSMutableArray<PHAsset *> *arr = @[].mutableCopy;
    PHFetchResult *result = [self fetchAssetsInAssetCollection:assetCollection ascending:ascending];
    [result enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        [arr addObject:obj];
    }];
    return arr;
}

@end
