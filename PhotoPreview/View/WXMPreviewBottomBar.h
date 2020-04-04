//
//  WXMPreviewBottom.h
//  ModuleDebugging
//
//  Created by edz on 2019/5/13.
//  Copyright © 2019年 wq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXMDictionary_Array.h"
#import "WXMPhotoRecordModel.h"
#import "WXMPhotoConfiguration.h"

@interface WXMPreviewBottomBar : UIView

/** 选中的记录RecordModel */
@property (nonatomic, strong) WXMPhotoRecordModel *recordModel;

/** 是否选取原图 */
@property (nonatomic, assign, readonly) BOOL isOriginalImage;

/** 显示原图的按钮是否显示 */
@property (nonatomic, assign) BOOL showOriginalButton;

/** 当前显示图片原图大小 */
@property (nonatomic, assign) NSString *realImageByte;

/** 当前选中的Idx */
@property (nonatomic, assign) NSInteger seletedIdx;

/** 全部选中的 */
@property (nonatomic, strong) WXMDictionary_Array *dictionaryArray;
@property (nonatomic, assign) id<WXMPreviewToolbarProtocol> delegate;

/** 显示隐藏 */
- (void)setOriginalImage;

/** 显示原图大小 */
- (void)setRealImageByte:(NSString *)realImageByte video:(BOOL)video;

/**  */
- (void)setAccordingState:(BOOL)state;

/** 加载数据 */
- (void)loadDictionaryArray:(WXMDictionary_Array *)dictionaryArray;

/** 新增一个 */
- (void)addPhotoRecordModel:(WXMDictionary_Array *)dictionaryArray;

/** 删除一个 */
- (void)deletePhotoRecordModel:(WXMDictionary_Array *)dictionaryArray;

@end
