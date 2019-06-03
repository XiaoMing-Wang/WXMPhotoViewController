//
//  WXMPhotoCollectionCell.h
//  ModuleDebugging
//
//  Created by wq on 2019/5/18.
//  Copyright © 2019年 wq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXMPhotoConfiguration.h"
#import "WXMPhotoSignView.h"
#import "WXMPhotoSignModel.h"
#import "WXMPhotoManager.h"

/** 单个相册CollectionViewCell*/
@interface WXMPhotoCollectionCell : UICollectionViewCell
@property (nonatomic, strong) WXMPhotoAsset *photoAsset;
@property (nonatomic, assign) WXMPhotoDetailType photoType;

/** 能否相应 默认YES NO出现白色遮罩 */
@property (nonatomic, assign) BOOL userCanTouch;
@property (nonatomic, strong) NSIndexPath *indexPath;

/** 多选模式下设置代理 */
- (void)setDelegate:(id<WXMPhotoSignProtocol>)delegate
          indexPath:(NSIndexPath *)indexPath
          signModel:(WXMPhotoSignModel *)signModel
           showMask:(BOOL)showMask;

@end
