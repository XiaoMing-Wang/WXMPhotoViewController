//
//  FZJPhotoTool.h
//  FZJPhotosFrameWork
//
//  Created by wq on 16/1/10.
//  Copyright © 2016年 wq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

/** 相册 */
@interface WXMPhotoList : NSObject
@property (nonatomic, strong) NSString *title;                    /**相册的名字*/
@property (nonatomic, assign) NSInteger photoNum;                 /**该相册的照片数量*/
@property (nonatomic, strong) PHAsset *firstAsset;                /**该相册的第一张图片*/
@property (nonatomic, strong) UIImage *firstImage;                /**第一张图片*/
@property (nonatomic, strong) PHAssetCollection *assetCollection; /**通过该属性可以取该相册的所有照片*/
@end

/** 相片对象 */
@interface WXMPhotoAsset : NSObject
@property (nonatomic, strong) PHAsset *asset;        /** 相片媒介 */
@property (nonatomic, strong) UIImage *bigImage;    /** 大相片 */
@property (nonatomic, strong) UIImage *smallImage; /** 小相片 */
@property (nonatomic, assign) BOOL selected;      /** 选中 */
@end


@interface WXMPhotoManager : NSObject
@property (nonatomic, strong) NSArray *photoData;
@property (nonatomic, strong) WXMPhotoList *firstPhotoList;

+ (instancetype)sharedInstance;

/** 是否有权限 */
- (BOOL)photoPermission;

/** 获得所有的相册对象 */
- (void)getAllPhotoListBlock:(void (^)(NSArray<WXMPhotoList *> *))block;

/** 取得所有相册的照片资源 */
- (NSArray<PHAsset *> *)getAllAssetInPhotoAblumWithAscending:(BOOL)ascending;

/**  获取指定相册的所有图片 */
- (NSArray<PHAsset *> *)getAssetsInAssetCollection:(PHAssetCollection *)assetCollection
                                         ascending:(BOOL)ascending;

/**
 *  取到对应的照片实体
 *  @param asset      索取照片实体的媒介
 *  @param original   是不是原生
 *  @param resizeMode 控制照片尺寸
 *  @param completion block返回照片实体
 */
- (void)getImageByAsset:(PHAsset *)asset
         makeResizeMode:(PHImageRequestOptionsResizeMode)resizeMode
             isOriginal:(BOOL)original
             completion:(void (^)(UIImage *AssetImage))completion;

/** 获取指定尺寸图片(同步) 上面是获取原生或者缩略 */
- (void)getImageByAsset_Synchronous:(PHAsset *)asset
                               size:(CGSize)size
                         completion:(void (^)(UIImage *))completion;
- (void)getImageByAsset_Asynchronous:(PHAsset *)asset
                                size:(CGSize)size
                          completion:(void (^)(UIImage *))completion;


/** 获取视频路径 */
- (void)getVideoByAsset:(PHAsset *)asset completion:(void (^)(NSDictionary *))completiont;
@end
