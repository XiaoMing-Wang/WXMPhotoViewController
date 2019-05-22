//
//  WXMPhotoShapeScrollView.m
//  ModuleDebugging
//
//  Created by wq on 2019/5/18.
//  Copyright © 2019年 wq. All rights reserved.
//

#import "WXMPhotoShapeScrollView.h"

@implementation WXMPhotoShapeScrollView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.touchesBegan) self.touchesBegan();
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.touchesEnded) self.touchesEnded();
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.touchesCancelled) self.touchesCancelled();
    [super touchesCancelled:touches withEvent:event];
}
@end
