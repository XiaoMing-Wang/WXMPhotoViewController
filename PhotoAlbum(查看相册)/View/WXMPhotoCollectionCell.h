//
//  WXMPhotoCollectionCell.h
//  ModuleDebugging
//
//  Created by wq on 2019/5/18.
//  Copyright © 2019年 wq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXMPhotoConfiguration.h"
#import "WXMPhotoSignModel.h"
#import "WXMPhotoManager.h"

/** 单个相册CollectionViewCell*/
@interface WXMPhotoCollectionCell : UICollectionViewCell
@property (nonatomic, assign) BOOL showVideo;
@property (nonatomic, assign) BOOL userCanTouch;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) NSString *warningString;

@property (nonatomic, strong) WXMPhotoAsset *photoAsset;
@property (nonatomic, strong) WXMPhotoSignModel *signModel;
@property (nonatomic, assign) WXMPhotoDetailType photoType;
@property (nonatomic, weak) id<WXMPhotoSignProtocol> delegate;
@property (nonatomic, copy) NSString *representedAssetIdentifier;

/** 设置button选中 */
- (void)signButtonSelected:(BOOL)selected;

/** 刷新标号排名 */
- (void)refreshRankingWithSignModel:(WXMPhotoSignModel *)signModel;

/** 设置蒙版 */
- (void)setUserCanTouch:(BOOL)userCanTouch animation:(BOOL)animation;

/** 多选模式下设置代理 */
- (void)setDelegate:(id<WXMPhotoSignProtocol>)delegate
          indexPath:(NSIndexPath *)indexPath
          signModel:(WXMPhotoSignModel *)signModel
           canTouch:(BOOL)canTouch;

@end
