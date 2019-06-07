//
//  WXMPreviewBottom.h
//  ModuleDebugging
//
//  Created by edz on 2019/5/13.
//  Copyright © 2019年 wq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXMDictionary_Array.h"

@interface WXMPreviewBottomBar : UIView

/** 是否选取原图 */
@property (nonatomic, assign, readonly) BOOL isOriginalImage;

/** 显示原图的按钮是否显示 */
@property (nonatomic, assign) BOOL isShowOriginalButton;

/** 当前显示图片原图大小 */
@property (nonatomic, assign) NSString *realImageByte;

/** 当前选中的Idx */
@property (nonatomic, assign) NSInteger seletedIdx;

/** 全部选中的 */
@property (nonatomic, strong) WXMDictionary_Array *signObj;
@property (nonatomic, assign) id<WXMPreviewToolbarProtocol> delegate;

/** 显示隐藏 */
- (void)setAccordingState:(BOOL)state;
- (void)setSignObj:(WXMDictionary_Array *)signObj removeIdx:(NSInteger)idx;
@end
