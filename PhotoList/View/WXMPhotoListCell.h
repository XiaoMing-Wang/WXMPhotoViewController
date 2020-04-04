//
//  WXMPhotoListCell.h
//  ModuleDebugging
//
//  Created by edz on 2019/5/5.
//  Copyright © 2019年 wq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXMPhotoManager.h"
#import "WXMPhotoSignModel.h"
#import "WXMPhotoConfiguration.h"

@interface WXMPhotoListCell : UITableViewCell

/** 相册媒介 */
@property (nonatomic, strong) WXMPhotoList *phoneList;

@end
