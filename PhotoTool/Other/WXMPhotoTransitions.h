//
//  WXMPhotoTransitions.h
//  ModuleDebugging
//
//  Created by wq on 2019/5/16.
//  Copyright © 2019年 wq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, WXMPhotoTransitionsType) {
    WXMPhotoTransitionsTypePush = 0,
    WXMPhotoTransitionsTypePop = 1,
};

@interface WXMPhotoTransitions : NSObject<UIViewControllerAnimatedTransitioning>
@property (nonatomic, assign) WXMPhotoTransitionsType transitionsType;
+ (instancetype)photoTransitionsWithType:(WXMPhotoTransitionsType)type;
@end
