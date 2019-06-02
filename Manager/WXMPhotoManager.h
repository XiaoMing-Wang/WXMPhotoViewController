//
//  FZJPhotoTool.h
//  FZJPhotosFrameWork
//
//  Created by wq on 16/1/10.
//  Copyright © 2016年 wq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

/** 图片种类 */
typedef enum {
    WXMPHAssetMediaTypeImage,
    WXMPHAssetMediaTypeLivePhoto,
    WXMPHAssetMediaTypePhotoGif,
    WXMPHAssetMediaTypeVideo,
    WXMPHAssetMediaTypeAudio,
} WXMPhotoMediaType;

/** 相册 */
@interface WXMPhotoList : NSObject
@property (nonatomic, strong) NSString *title;                    /**相册的名字*/
@property (nonatomic, assign) NSInteger photoNum;                 /**该相册的照片数量*/
@property (nonatomic, strong) PHAsset *firstAsset;                /**该相册的第一张图片*/
@property (nonatomic, strong) UIImage *firstImage;                /**第一张图片*/
@property (nonatomic, strong) PHAssetCollection *assetCollection; /**通过该属性可以取该相册的所有照片*/
@end

/** 相片 */
@interface WXMPhotoAsset : NSObject
@property (nonatomic, strong) PHAsset *asset;              /** 相片媒介 */
@property (nonatomic, strong) UIImage *smallImage;         /** 小相片 */
@property (nonatomic, strong) UIImage *bigImage;           /** 大相片 */
@property (nonatomic, strong) UIImage *originalImage;      /** 原始相片 */
@property (nonatomic, strong) NSData *imageData;           /** gif video Data */
@property (nonatomic, strong) NSURL *videoUrl;             /** video url */
@property (nonatomic, assign) BOOL selected;               /** 选中 */
@property (nonatomic, assign) CGFloat bytes;               /** 大小 */
@property (nonatomic, assign) CGFloat aspectRatio;         /** 高/宽比例 */
@property (nonatomic, assign) WXMPhotoMediaType mediaType; /** 相片类型 */
@end


@interface WXMPhotoManager : NSObject
@property (nonatomic, strong) NSArray *picturesArray;
@property (nonatomic, strong) WXMPhotoList *firstPhotoList;

+ (instancetype)sharedInstance;

/** 是否有权限 */
- (BOOL)wxm_photoPermission;

/** 获得所有的相册对象 */
- (void)wxm_getAllPicturesListBlock:(void (^)(NSArray<WXMPhotoList *> *))block;

/** 取得所有相册的照片资源 */
- (NSArray<PHAsset *> *)wxm_getAllAssetInPhotoAblumWithAscending:(BOOL)ascending;

/**  获取指定相册的所有图片 */
- (NSArray<PHAsset *> *)wxm_getAssetsInAssetCollection:(PHAssetCollection *)assetCollection
                                             ascending:(BOOL)ascending;

/**
 *  取到对应的照片实体
 *  @param asset         索取照片实体的媒介
 *  @param synchronous   是否同步
 *  @param original      是否原图
 *  @param resizeMode    控制照片尺寸
 *  @param deliveryMode  控制照片获取质量
 *  @param completion    block返回照片实体
 */
- (void)getPicturesByAsset:(PHAsset *)asset
               synchronous:(BOOL)synchronous
                  original:(BOOL)original
                 assetSize:(CGSize)assetSize
                resizeMode:(PHImageRequestOptionsResizeMode)resizeMode
              deliveryMode:(PHImageRequestOptionsDeliveryMode)deliveryMode
                completion:(void (^)(UIImage *AssetImage))completion;


/** 获取高质量原图 */
- (void)getPictures_original:(PHAsset *)asset
                 synchronous:(BOOL)synchronous
                  completion:(void (^)(UIImage *image))completion;


/** 获取自定义尺寸 */
/** 获取自定义尺寸 设置PHImageRequestOptionsResizeModeExact是有效 */
- (void)getPictures_customSize:(PHAsset *)asset
                   synchronous:(BOOL)synchronous
                     assetSize:(CGSize)assetSize
                    completion:(void (^)(UIImage *image))completion;


/** 同步获取图片 size为zero时获取原图 */
- (void)wxm_synchronousGetPictures:(PHAsset *)asset
                              size:(CGSize)size
                        completion:(void (^)(UIImage *image))comple;


/** 获取GIF */
- (void)getGIFByAsset:(PHAsset *)asset completion:(void (^)(NSData *))completion;

/** 获取视频路径 */
- (void)getVideoByAsset:(PHAsset *)assetData completion:(void (^)(NSURL * , NSData *))completiont;
@end

