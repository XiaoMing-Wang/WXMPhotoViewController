//
//  WXMCompression.m
//  TianMiMi
//
//  Created by sdjim on 2020/3/17.
//  Copyright © 2020 sdjgroup. All rights reserved.
//

#import "WXMCompression.h"

@implementation WXMCompression

/// 系统自带的视频解压
static int errorCount = 0;
+ (void)wp_compressionVideo:(NSString *)inputString
                  outString:(NSString *)outString
                    avAsset:(AVURLAsset *)avAsset
                   callback:(void (^)(BOOL success))callback {
    
    if (DEBUG) {
        NSLog(@"==================================压缩视频-输入地址 %@",inputString);
        NSLog(@"==================================压缩视频-输出地址 %@",outString);
    }
    
    CGFloat bitys = [self fileSize:[NSURL URLWithString:inputString]];
    
    /** 小于2.5的不压缩 小于5M的用高清压缩 */
    NSString *presetName = AVAssetExportPresetMediumQuality;
    if (bitys <= 8.0) presetName = AVAssetExportPresetHighestQuality;
    if (bitys <= 2.5) {
        callback(NO);
        NSLog(@"不压缩完毕, %fMB ", bitys);
        return;
    }
    
    /** 创建AVAsset对象 */
    AVAsset *asset = [AVAsset assetWithURL:[NSURL URLWithString:inputString]];
    AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:asset presetName:presetName];
    
    /** 优化网络 */
    session.shouldOptimizeForNetworkUse = YES;
    
    [session setOutputFileType:AVFileTypeQuickTimeMovie];
    
    /** 判断文件是否存在，如果已经存在删除 */
    [[NSFileManager defaultManager] removeItemAtPath:outString error:nil];
    
    /** 设置输出路径 */
    session.outputURL = [NSURL fileURLWithPath:outString];
    
    AVMutableVideoComposition *videoComposition = [self fixedCompositionWithAsset:avAsset];
    if (videoComposition.renderSize.width) {
        session.videoComposition = videoComposition;
    }
    
    /** 设置输出类型  这里可以更改输出的类型 具体可以看文档描述 */
    NSArray *supportedTypeArray = session.supportedFileTypes;
    if ([supportedTypeArray containsObject:AVFileTypeMPEG4]) {
        session.outputFileType = AVFileTypeMPEG4;
    } else if (supportedTypeArray.count == 0) {
        NSLog(@"No supported file types 视频类型暂不支持导出");
        return;
    } else {
        
        //不是MP4
        session.outputFileType = [supportedTypeArray objectAtIndex:0];
        if (avAsset.URL && avAsset.URL.lastPathComponent) {
            outString = [outString stringByReplacingOccurrencesOfString:@".mp4" withString:[NSString stringWithFormat:@"-%@", avAsset.URL.lastPathComponent]];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [session exportAsynchronouslyWithCompletionHandler:^{
            if (session.status == AVAssetExportSessionStatusCompleted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"压缩完毕, 压缩前%fMB 压缩后 %f MB", bitys, [self fileSize:session.outputURL]);
                    if (callback) callback(YES);
                });
                errorCount = 0;
            } else if (session.status == AVAssetExportSessionStatusFailed ||
                       session.status == AVAssetExportSessionStatusCancelled) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (errorCount >= 2) {
                        errorCount = 0;
                        if (callback) callback(NO);
                        return;
                    }
                    
                    NSLog(@"压缩失败");
                    errorCount ++;
                    [self wp_compressionVideo:inputString
                                    outString:outString
                                      avAsset:avAsset
                                     callback:callback];
                    
                });
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                switch (session.status) {
                    case AVAssetExportSessionStatusUnknown: {
                        NSLog(@"AVAssetExportSessionStatusUnknown");
                    }  break;
                    case AVAssetExportSessionStatusWaiting: {
                        NSLog(@"AVAssetExportSessionStatusWaiting");
                    }  break;
                    case AVAssetExportSessionStatusExporting: {
                        NSLog(@"AVAssetExportSessionStatusExporting");
                    }  break;
                    case AVAssetExportSessionStatusCompleted: {
                        NSLog(@"AVAssetExportSessionStatusCompleted");
                        
                    }  break;
                    case AVAssetExportSessionStatusFailed: {
                        NSLog(@"AVAssetExportSessionStatusFailed");
                        
                    }  break;
                    case AVAssetExportSessionStatusCancelled: {
                        NSLog(@"AVAssetExportSessionStatusCancelled");
                        
                    }  break;
                    default: break;
                }
            });
        }];
    });
}

/** 计算压缩大小 */
+ (CGFloat)fileSize:(NSURL *)path {
    return [[NSData dataWithContentsOfURL:path] length] / 1024.00 / 1024.00;
}

/// 获取优化后的视频转向信息
+ (AVMutableVideoComposition *)fixedCompositionWithAsset:(AVAsset *)videoAsset {
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    
    // 视频转向
    int degrees = [self degressFromVideoFileWithAsset:videoAsset];
    if (degrees != 0) {
        CGAffineTransform translateToCenter;
        CGAffineTransform mixedTransform;
        videoComposition.frameDuration = CMTimeMake(1, 30);
        
        NSArray *tracks = [videoAsset tracksWithMediaType:AVMediaTypeVideo];
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        
        AVMutableVideoCompositionInstruction *roateInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        roateInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, [videoAsset duration]);
        AVMutableVideoCompositionLayerInstruction *roateLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
        
        if (degrees == 90) {
            // 顺时针旋转90°
            translateToCenter = CGAffineTransformMakeTranslation(videoTrack.naturalSize.height, 0.0);
            mixedTransform = CGAffineTransformRotate(translateToCenter,M_PI_2);
            videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.height,videoTrack.naturalSize.width);
            [roateLayerInstruction setTransform:mixedTransform atTime:kCMTimeZero];
        } else if(degrees == 180){
            // 顺时针旋转180°
            translateToCenter = CGAffineTransformMakeTranslation(videoTrack.naturalSize.width, videoTrack.naturalSize.height);
            mixedTransform = CGAffineTransformRotate(translateToCenter,M_PI);
            videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.width,videoTrack.naturalSize.height);
            [roateLayerInstruction setTransform:mixedTransform atTime:kCMTimeZero];
        } else if(degrees == 270){
            // 顺时针旋转270°
            translateToCenter = CGAffineTransformMakeTranslation(0.0, videoTrack.naturalSize.width);
            mixedTransform = CGAffineTransformRotate(translateToCenter,M_PI_2*3.0);
            videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.height,videoTrack.naturalSize.width);
            [roateLayerInstruction setTransform:mixedTransform atTime:kCMTimeZero];
        }
        
        roateInstruction.layerInstructions = @[roateLayerInstruction];
        // 加入视频方向信息
        videoComposition.instructions = @[roateInstruction];
    }
    return videoComposition;
}

/// 获取视频角度
+ (int)degressFromVideoFileWithAsset:(AVAsset *)asset {
    int degress = 0;
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if([tracks count] > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        CGAffineTransform t = videoTrack.preferredTransform;
        if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0){
            // Portrait
            degress = 90;
        } else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0){
            // PortraitUpsideDown
            degress = 270;
        } else if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0){
            // LandscapeRight
            degress = 0;
        } else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0){
            // LandscapeLeft
            degress = 180;
        }
    }
    return degress;
}

@end
