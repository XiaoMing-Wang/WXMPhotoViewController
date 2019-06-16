//
//  WXMPhotoResources.h
//  Multi-project-coordination
//
//  Created by wq on 2019/6/16.
//  Copyright © 2019年 wxm. All rights reserved.
//
#import "WXMPhotoManager.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface WXMPhotoResources : NSObject

@property (nonatomic, assign) WXMPhotoMediaType mediaType;

@property (nonatomic, strong) UIImage *resourceImage;

@property (nonatomic, strong) NSData *resourceData;
@end
