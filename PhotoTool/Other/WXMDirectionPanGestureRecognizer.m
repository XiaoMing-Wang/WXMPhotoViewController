//
//  WXMDirectionPanGestureRecognizer.m
//  ModuleDebugging
//
//  Created by edz on 2019/5/16.
//  Copyright © 2019年 wq. All rights reserved.
//

#import "WXMDirectionPanGestureRecognizer.h"
int const static kDirectionPanThreshold = 5;

@implementation WXMDirectionPanGestureRecognizer

@synthesize direction = _direction;

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    if (self.state == UIGestureRecognizerStateFailed) return;
    CGPoint nowPoint = [[touches anyObject] locationInView:self.view];
    CGPoint prevPoint = [[touches anyObject] previousLocationInView:self.view];
    _moveX += prevPoint.x - nowPoint.x;
    _moveY += prevPoint.y - nowPoint.y;
    
    if (!_drag) {
        if (abs(_moveX) > kDirectionPanThreshold) {
            if (_direction == DirectionPangestureRecognizerVertical ||
                _direction == DirectionPanGestureRecognizerBottom) {
                self.state = UIGestureRecognizerStateFailed;
            } else {
                _drag = YES;
            }
        } else if (abs(_moveY) > kDirectionPanThreshold) {
            if (_direction == DirectionPanGestureRecognizerHorizontal) {
                self.state = UIGestureRecognizerStateFailed;
            } else if (_direction == DirectionPanGestureRecognizerBottom) {
                if (_moveY > 0) self.state = UIGestureRecognizerStateFailed;
                else _drag = YES;
            } else {
                _drag = YES;
            }
        }
    }
}

- (void)reset {
    [super reset];
    _drag = NO;
    _moveX = 0;
    _moveY = 0;
}

@end
