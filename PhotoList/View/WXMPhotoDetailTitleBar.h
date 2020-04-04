//
//  WXMPhotoDetailTitleBar.h
//  2222222
//
//  Created by wq on 2020/2/9.
//  Copyright © 2020 wxm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXMPhotoConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXMPhotoDetailTitleBar : UIControl

/** 标题 */
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) BOOL unfold;
@property (nonatomic, weak) id<WXMDetailTitleBarProtocol> delegate;

- (void)reductionArrowView;

@end

NS_ASSUME_NONNULL_END
