//
//  WXMPhotoDetailViewController.h
//  ModuleDebugging
//
//  Created by edz on 2019/5/6.
//  Copyright © 2019年 wq. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WXMPhotoList;
@interface WXMPhotoDetailViewController : UIViewController

/** 类型 */
typedef NS_ENUM(NSInteger, WXMPhotoDetailType) {
    WXMPhotoDetailTypeMultiSelect = 0,
};

@property (nonatomic, strong) WXMPhotoList *phoneList;

@end
