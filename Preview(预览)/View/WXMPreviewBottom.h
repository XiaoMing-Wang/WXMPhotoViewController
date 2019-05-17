//
//  WXMPreviewBottom.h
//  ModuleDebugging
//
//  Created by edz on 2019/5/13.
//  Copyright © 2019年 wq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WXMPreviewBottom : UIView


@property (nonatomic, assign) id<WXMPreviewToolbarProtocol> delegate;

/** 选中的 */
@property (nonatomic, strong) NSMutableDictionary *signDictionary;

/** 当前选中的 */
@property (nonatomic, assign) NSInteger seletedIdx;

/** 显示隐藏 */
- (void)setAccordingState:(BOOL)state;
@end
