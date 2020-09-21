//
//  WXMPhotoPreviewCell.h
//  ModuleDebugging
//
//  Created by edz on 2019/5/12.
//  Copyright © 2019年 wq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXMPhotoManager.h"
#import "WXMPhotoConfiguration.h"

@interface WXMPhotoPreviewCell : UICollectionViewCell

@property (nonatomic, assign) BOOL supportGIF;

@property (nonatomic, strong) WXMPhotoAsset *photoAsset;

@property (nonatomic, assign) id<WXMPreviewCellProtocol> delegate;

@property (nonatomic, weak) UIPanGestureRecognizer *colleRecognizer;

/** 还原zoom */
- (void)originalAppearance;

/** 获取当前image */
- (UIImage *)currentImage;

/** 开始播放livephoto */
- (void)startPlayLivePhoto;

@end

