//
//  WXMPhotoListCell.h
//  ModuleDebugging
//
//  Created by edz on 2019/5/5.
//  Copyright © 2019年 wq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXMPhotoManager.h"
/** 全部相册UITableViewCell*/
@interface WXMPhotoListCell : UITableViewCell
@property (nonatomic, strong) WXMPhotoList *phoneList;
@property (strong, nonatomic) UIImageView *posterImageView;
@property (strong, nonatomic) UILabel *titleLable;
@end

/** 单个相册CollectionViewCell*/
@interface WXMPhotoCollectionCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *seleIcon;
@property (nonatomic, strong) WXMPhotoAsset *photoAsset;
//
//- (void)setPhotoAsset:(PhotoAsset *)photoAsset mainThread:(BOOL)mainThread;
@end
