//
//  WXMPhotoOverlayView.h
//  ModuleDebugging
//
//  Created by wq on 2019/5/18.
//  Copyright © 2019年 wq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WXMPhotoOverlayView : UIView

/** 隐藏内部网格线，没有动画 */
@property(nonatomic, assign) BOOL gridHidden;

/** 添加/删除内部水平网格线 */
@property(nonatomic, assign) BOOL displayHorizontalGridLines;

/** 添加/删除内部垂直网格线 */
@property(nonatomic, assign) BOOL displayVerticalGridLines;

/** 使用可选的交叉淡入显示和隐藏内部网格线  */
- (void)setGridHidden:(BOOL)hidden animated:(BOOL)animated;

@end
