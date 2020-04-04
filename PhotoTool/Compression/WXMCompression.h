//
//  WXMCompression.h
//  TianMiMi
//
//  Created by sdjim on 2020/3/17.
//  Copyright © 2020 sdjgroup. All rights reserved.
//
#import <Photos/Photos.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** 系统自带的视频解压 */
@interface WXMCompression : NSObject

/// 系统自带的视频解压
/// @param inputString 输入地址
/// @param outString 输入地址
/// @param callback 解压完成回调
+ (void)wp_compressionVideo:(NSString *)inputString
                  outString:(NSString *)outString
                    avAsset:(AVURLAsset *)avAsset
                   callback:(void (^)(BOOL success))callback;

@end

NS_ASSUME_NONNULL_END
