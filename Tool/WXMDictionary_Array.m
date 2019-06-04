//
//  WXMDictionary_Array.m
//  ModuleDebugging
//
//  Created by edz on 2019/6/3.
//  Copyright © 2019 wq. All rights reserved.
//

#import "WXMDictionary_Array.h"

@interface WXMDictionary_Array ()

/** 保存内容 */
@property (nonatomic, strong) NSMutableDictionary *contentDictionary;
@property (nonatomic, strong) NSPointerArray *contentArray;

/** 标记 */
@property (nonatomic, strong) NSMutableDictionary *signDictionary;
@end

@implementation WXMDictionary_Array

/** Dictionary */
- (void)setObject:(id)anObject forKey:(id)aKey {
    if (!anObject || !aKey) return;
    if ([self.allKeys containsObject:aKey]) {
        NSInteger idex = [[self.signDictionary objectForKey:aKey] integerValue];
        [self.contentDictionary setObject:anObject forKey:aKey];
        if(anObject && self.contentArray.count >= idex + 1) {
            [self.contentArray replacePointerAtIndex:idex withPointer:(__bridge void *)(anObject)];
        }
    } else {
        if (self.maxCount > 0 && self.count >= self.maxCount) return;
        [self.contentDictionary setObject:anObject forKey:aKey];
        [self.contentArray addPointer:(__bridge void * _Nullable)(anObject)];
        [self.signDictionary setObject:self.location forKey:aKey];
    }
}

- (id)objectForKey:(id)aKey {
    if (!aKey) return nil;
    return [self.contentDictionary objectForKey:aKey];
}

- (void)removeObjectForKey:(id)aKey {
    if (!aKey) return;
    id obj = [self.contentDictionary objectForKey:aKey];
    if (obj) [self removeObject:obj];
}

- (void)removeAllObjects {
    [self.contentDictionary removeAllObjects];
    [self.signDictionary removeAllObjects];
    self.contentArray = [NSPointerArray weakObjectsPointerArray];
}

- (void)enumerateKeysAndObjectsUsingBlock:(void (NS_NOESCAPE ^)(id key, id obj, BOOL *stop))block {
    if (self.contentDictionary.count == 0) return;
    [self.contentDictionary enumerateKeysAndObjectsUsingBlock:block];
}

- (NSArray *)allKeys {
    return self.contentDictionary.allKeys;
}

- (NSArray *)allValues {
    return self.contentDictionary.allValues;
}


/** Array */

- (NSUInteger)count {
    return self.contentArray.count;
}

- (id)firstObject {
    if (self.contentArray.count == 0) return nil;
    return [self.contentArray pointerAtIndex:0];
}

- (id)lastObject {
    if (self.contentArray.count == 0) return nil;
    return [self.contentArray pointerAtIndex:self.contentArray.count - 1];
}

#pragma mark add

- (void)addObject:(id)object {
    if (!object) return;
    NSString * objHash = [@([object hash]).stringValue stringByAppendingString:@"_hash"];
    [self.contentArray addPointer:(__bridge void * _Nullable)(object)];
    [self.contentDictionary setObject:object forKey:objHash];
    [self.signDictionary setObject:self.location forKey:objHash];
}

- (void)addObjectsFromArray:(NSArray *)array {
    for (id obj in array) {
        [self addObject:obj];
    }
}

#pragma mark insert

- (void)insertObject:(id)object atIndex:(NSUInteger)idx {
    NSString * objHash = [@([object hash]).stringValue stringByAppendingString:@"_hash"];
    NSString * idxString = @(idx).stringValue;
    [self.contentArray insertPointer:(__bridge void * _Nullable)(object) atIndex:idx];
    [self.contentDictionary setObject:object forKey:objHash];
    [self.signDictionary setObject:idxString forKey:objHash];
}

- (NSUInteger)indexOfObject:(id)anObject {
    NSInteger idx = -1;
    for (NSInteger i = 0; i < self.contentArray.count; i++) {
        id weakObj = [self.contentArray pointerAtIndex:i];
        if (weakObj == anObject) {
            idx = i;
            break;
        }
    }
    return idx;
}

#pragma mark get

- (id)objectAtIndex:(NSUInteger)index {
    return [self.contentArray pointerAtIndex:index];
}

#pragma mark remove

- (void)removeFirstObject {
    if (self.contentArray.count == 0) return;
    id obj = [self.contentArray pointerAtIndex:0];
    [self removeObject:obj];
}

- (void)removeLastObject {
    if (self.contentArray.count == 0) return;
    id obj = [self.contentArray pointerAtIndex:self.contentArray.count - 1];
    [self removeObject:obj];
}

- (void)removeObject:(id)object {
    if (!object) return;
    NSString * key = [self contentKeyWithArrayObj:object];
    NSInteger index = [self indexOfObject:object];
    if (index >= 0) [self.contentArray removePointerAtIndex:index];
    if (key) {
        [self.contentDictionary removeObjectForKey:key];
        [self.signDictionary removeObjectForKey:key];
    }
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    if (index < 0) return;
    id obj = [self.contentArray pointerAtIndex:index];
    [self removeObject:obj];
}

/** 只替换字典里的value 不替换值 替换字典找不到 */
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObj {
    id oldValue = [self.contentArray pointerAtIndex:index];
    NSString * key = [self contentKeyWithArrayObj:oldValue];
    
    /** 替换值 */
    [self.contentDictionary setObject:anObj forKey:key];
    [self.contentArray replacePointerAtIndex:index withPointer:(__bridge void * _Nullable)(anObj)];
}

- (void)enumerateObjectsUsingBlock:(void (NS_NOESCAPE ^)(id obj, NSUInteger idx, BOOL stop))block {
    if (!block) return;
    for (NSInteger i = 0; i < self.contentArray.count; i++) {
        id weakObj = [self.contentArray pointerAtIndex:i];
        BOOL weakStop = NO;
        block(weakObj, i, weakStop);
        if (weakStop) break;
    }
}

/** 获取key */
- (NSString *)contentKeyWithArrayObj:(id)contentObj {
    __block NSString *contentKey = nil;
    [self.contentDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (obj == contentObj) {
            contentKey = key;
            *stop = YES;
        }
    }];
    return contentKey;
}

- (NSString *)location {
    return @(self.contentArray.count - 1).stringValue;
}

- (NSPointerArray *)contentArray {
    if (!_contentArray) _contentArray = [NSPointerArray weakObjectsPointerArray];
    return _contentArray;
}
- (NSMutableDictionary *)contentDictionary {
    if (!_contentDictionary) _contentDictionary = @{}.mutableCopy;
    return _contentDictionary;
}
- (NSMutableDictionary *)signDictionary {
    if (!_signDictionary) _signDictionary = @{}.mutableCopy;
    return _signDictionary;
}

- (NSString *)description {
    @try {
        NSMutableString *string = [NSMutableString string];
        [string appendString:@"{\n"];
        [self.contentDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [string appendFormat:@"\t%@", key ?: @""];
            [string appendString:@" : "];
            [string appendFormat:@"%@,\n", obj ?: @""];
        }];
        [string appendString:@"}"];
        NSRange range = [string rangeOfString:@"," options:NSBackwardsSearch];
        if (range.location != NSNotFound) [string deleteCharactersInRange:range];
        return string;
    } @catch (NSException *exception) {} @finally {}
    return nil;
}
@end
