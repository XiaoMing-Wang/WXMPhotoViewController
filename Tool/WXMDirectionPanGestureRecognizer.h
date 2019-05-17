//
//  WXMDirectionPanGestureRecognizer.h
//  ModuleDebugging
//
//  Created by edz on 2019/5/16.
//  Copyright © 2019年 wq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>
typedef enum {
    /** 竖向 */
    DirectionPangestureRecognizerVertical,

    /** 横向 */
    DirectionPanGestureRecognizerHorizontal,
    
    /** 只支持下 */
    DirectionPanGestureRecognizerBottom

} DirectionPangestureRecognizerDirection;

@interface WXMDirectionPanGestureRecognizer : UIPanGestureRecognizer {
  @public
    BOOL _drag;
    int _moveX;
    int _moveY;
    DirectionPangestureRecognizerDirection _direction;
}
@property (nonatomic, assign) DirectionPangestureRecognizerDirection direction;
@end
