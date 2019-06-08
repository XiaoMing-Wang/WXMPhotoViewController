//
//  WXMPhotoVideoCell.h
//  Multi-project-coordination
//
//  Created by wq on 2019/6/2.
//  Copyright © 2019年 wxm. All rights reserved.
//
#import "WXMPhotoManager.h"
#import "WXMPhotoConfiguration.h"
#import <UIKit/UIKit.h>

@interface WXMPhotoVideoCell : UICollectionViewCell
@property (nonatomic, strong) WXMPhotoAsset *photoAsset;
@property (nonatomic, assign) id<WXMPreviewCellProtocol> delegate;
@property (nonatomic, weak) UIPanGestureRecognizer *colleRecognizer;

/** 获取当前image */
- (UIImage *)currentImage;
@end
