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
@property (nonatomic, assign) BOOL canRespond;

/** 多选模式下设置代理 */
- (void)setDelegate:(id<WXMPhotoSignProtocol>)delegate
          indexPath:(NSIndexPath *)indexPath
          signModel:(WXMPhotoSignModel *)signModel
            respond:(BOOL)respond;
@end
