//
//  WXMPhotoPreviewController.h
//  ModuleDebugging
//
//  Created by edz on 2019/5/12.
//  Copyright © 2019年 wq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WXMPhotoPreviewController : UIViewController
/** 选中的 */
@property (nonatomic, strong) NSMutableDictionary *signDictionary;

/** 全部 */
@property (nonatomic, strong) NSMutableArray *dataSource;

/**  */
@property (nonatomic, strong) NSIndexPath *indexPath;

/** 回调 */
@property (nonatomic, copy) NSDictionary* (^callback)(NSInteger index, NSInteger rank);

/**  */
@property (nonatomic, strong) UIImage *windowImage;

/** 动画 */
@property (nonatomic, strong) UIImage * (^transitions)(NSInteger index);
- (UIScrollView *)transitionScrollerView;
- (NSInteger)transitionIndex;
@end
