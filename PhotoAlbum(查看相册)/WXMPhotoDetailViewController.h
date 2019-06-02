//
//  WXMPhotoDetailViewController.h
//  ModuleDebugging
//
//  Created by edz on 2019/5/6.
//  Copyright © 2019年 wq. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "WXMPhotoViewController.h"
#import "WXMPhotoConfiguration.h"

@class WXMPhotoList;
@interface WXMPhotoDetailViewController : UIViewController
@property (nonatomic, strong) WXMPhotoList *phoneList;
@property (nonatomic, assign) WXMPhotoDetailType photoType;

/** 是否有预览默认YES WXMPhotoDetailTypeGetPhoto 和 WXMPhotoDetailTypeGetPhoto_256设置有效 */
@property (nonatomic, assign) BOOL exitPreview;

/** 期望获取图片大小 */
@property (nonatomic, assign) CGSize expectSize;

/** 回调 */
@property (nonatomic, weak) id<WXMPhotoProtocol> delegate;
@property (nonatomic, strong) void (^results)(UIImage *image);
@property (nonatomic, strong) void (^resultArray)(NSArray<UIImage *> *images);

/** 自定义转场使用 */
- (UICollectionView *)transitionCollectionView;
@end
