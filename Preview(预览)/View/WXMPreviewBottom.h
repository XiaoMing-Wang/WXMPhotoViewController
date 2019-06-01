//
//  WXMPreviewBottom.h
//  ModuleDebugging
//
//  Created by edz on 2019/5/13.
//  Copyright © 2019年 wq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WXMPreviewBottom : UIView

/** 是否选取原图 */
@property (nonatomic, assign) BOOL isOriginalImage;

/** 原图大小 */
@property (nonatomic, assign) NSString *realImageByte;


@property (nonatomic, assign) id<WXMPreviewToolbarProtocol> delegate;

/** 全部选中的 */
@property (nonatomic, strong) NSMutableDictionary *signDictionary;

/** 当前选中的 */
@property (nonatomic, assign) NSInteger seletedIdx;

/** 显示隐藏 */
- (void)setAccordingState:(BOOL)state;
@end
