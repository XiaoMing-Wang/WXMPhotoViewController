//
//  WXMPreviewBottom.h
//  ModuleDebugging
//
//  Created by edz on 2019/5/13.
//  Copyright © 2019年 wq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WXMPreviewBottomBar : UIView

/** 是否选取原图 */
@property (nonatomic, assign, readonly) BOOL isOriginalImage;

/** 当前显示图片大小 */
@property (nonatomic, assign) NSString *realImageByte;


@property (nonatomic, assign) id<WXMPreviewToolbarProtocol> delegate;

/** 当前选中的 */
@property (nonatomic, assign) NSInteger seletedIdx;

/** 全部选中的 */
@property (nonatomic, strong) NSMutableDictionary *signDictionary;

/** 显示隐藏 */
- (void)setAccordingState:(BOOL)state;
@end
