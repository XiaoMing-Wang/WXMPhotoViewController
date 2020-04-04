//
//  WXMBottomBarCollectionViewCell.h
//  2222222
//
//  Created by wq on 2020/3/15.
//  Copyright © 2020 wxm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXMPhotoRecordModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXMBottomBarCollectionViewCell : UICollectionViewCell

/** 选中的图片 */
@property (nonatomic, strong) WXMPhotoRecordModel *recordModel;

/** 是否选中 选中绿边 */
@property (nonatomic, assign) BOOL isSelected;

@end

NS_ASSUME_NONNULL_END
