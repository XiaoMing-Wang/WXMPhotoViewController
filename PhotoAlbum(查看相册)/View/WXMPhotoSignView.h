//
//  WXMPhotoSign.h
//  ModuleDebugging
//
//  Created by edz on 2019/5/12.
//  Copyright © 2019年 wq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXMPhotoConfiguration.h"
#import "WXMPhotoSignModel.h"

@interface WXMPhotoSignView : UIButton
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, weak) id<WXMPhotoSignProtocol> delegate;
@property (nonatomic, strong) WXMPhotoSignModel *signModel;
@property (nonatomic, assign) BOOL userInteraction;

- (instancetype)initWithSupViewSize:(CGSize)size;
@end
