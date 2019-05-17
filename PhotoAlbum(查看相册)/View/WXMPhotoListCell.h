//
//  WXMPhotoListCell.h
//  ModuleDebugging
//
//  Created by edz on 2019/5/5.
//  Copyright © 2019年 wq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXMPhotoManager.h"
#import "WXMPhotoConfiguration.h"
#import "WXMPhotoSignView.h"
#import "WXMPhotoSignModel.h"

/** 全部相册UITableViewCell*/
@interface WXMPhotoListCell : UITableViewCell
@property (nonatomic, strong) WXMPhotoList *phoneList;
@property (strong, nonatomic) UIImageView *posterImageView;
@property (strong, nonatomic) UILabel *titleLable;
@end

/** 单个相册CollectionViewCell*/
@interface WXMPhotoCollectionCell : UICollectionViewCell
@property (nonatomic, strong) WXMPhotoAsset *photoAsset;
@property (nonatomic, assign) WXMPhotoDetailType photoType;
@property (nonatomic, assign) BOOL canRespond;

/** 设置代理 */
- (void)setDelegate:(id<WXMPhotoSignProtocol>)delegate
          indexPath:(NSIndexPath *)indexPath
          signModel:(WXMPhotoSignModel *)signModel
            respond:(BOOL)respond;
@end
