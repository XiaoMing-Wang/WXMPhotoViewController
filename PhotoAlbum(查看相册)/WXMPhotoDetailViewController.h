//
//  WXMPhotoDetailViewController.h
//  ModuleDebugging
//
//  Created by edz on 2019/5/6.
//  Copyright © 2019年 wq. All rights reserved.
//
#import "WXMPhotoViewController.h"
#import <UIKit/UIKit.h>
#import "WXMPhotoConfiguration.h"

@class WXMPhotoList;
@interface WXMPhotoDetailViewController : UIViewController
@property (nonatomic, strong) WXMPhotoList *phoneList;
@property (nonatomic, assign) WXMPhotoDetailType photoType;
@property (nonatomic, assign) CGSize expectSize;
@property (nonatomic, weak) id<WXMPhotoProtocol> delegate;
@property (nonatomic, strong) void (^results)(UIImage *image);
@property (nonatomic, strong) void (^resultArray)(NSArray<UIImage *> *images);
- (UICollectionView *)transitionCollectionView;
@end
