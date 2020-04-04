//
//  WXMPhotoCollectionCell.h
//  ModuleDebugging
//
//  Created by wq on 2019/5/18.
//  Copyright © 2019年 wq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXMPhotoManager.h"
#import "WXMPhotoRecordModel.h"
#import "WXMPhotoConfiguration.h"

@class WXMPhotoCollectionCell;
@protocol WXMPhotoCollectionCellDelegate <NSObject>
- (void)wp_photoCollectionCellCheckBox:(WXMPhotoCollectionCell *)cell selected:(BOOL)selected;
@end

/** 单个相册CollectionViewCell*/
@interface WXMPhotoCollectionCell : UICollectionViewCell

/** 数据源 */
@property (nonatomic, strong) WXMPhotoAsset *photoAsset;

/** 是否显示勾选框 */
@property (nonatomic, assign) BOOL displayCheckBox;

/** 是否显示视频 NO会显示为视频第一帧 */
@property (nonatomic, assign) BOOL showVideo;

/** 是否可以点击 */
@property (nonatomic, assign) BOOL userCanTouch;

/** 代理 */
@property (nonatomic, assign) id<WXMPhotoCollectionCellDelegate>delegate;

/** 选中的对象 */
@property (nonatomic, strong) WXMPhotoRecordModel *recordModel;

/** 设置选中按钮 */
- (void)refreshRanking:(WXMPhotoRecordModel *)recordModel animation:(BOOL)animation;

/** 显示遮罩 */
- (void)setUserCanTouch:(BOOL)userCanTouch animation:(BOOL)animation;

@end
