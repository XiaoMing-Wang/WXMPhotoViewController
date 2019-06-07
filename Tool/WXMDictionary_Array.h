//
//  WXMDictionary_Array.h
//  ModuleDebugging
//
//  Created by edz on 2019/6/3.
//  Copyright © 2019 wq. All rights reserved.
//
/** 数组指点二合一的对象 */
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXMDictionary_Array : NSObject

@property (nonatomic, strong, readonly) NSArray *allKeys;
@property (nonatomic, strong, readonly) NSArray *allValues;
@property (nonatomic, strong, readonly) id firstObject;
@property (nonatomic, strong, readonly) id lastObject;
@property (nonatomic, assign) NSInteger maxCount;

/** Dictionary */
- (void)setObject:(id)anObject forKey:(id)aKey;
- (id)objectForKey:(id)aKey;
- (void)removeObjectForKey:(id)aKey;
- (void)removeAllObjects;
- (void)enumerateKeysAndObjectsUsingBlock:(void (NS_NOESCAPE ^)(id key, id obj, BOOL *stop))block;

- (NSUInteger)count;

/** Array */
- (void)addObject:(id)object;
- (void)addObjectsFromArray:(NSArray *)array;
- (NSUInteger)indexOfObject:(id)anObject;
- (void)insertObject:(id)object atIndex:(NSUInteger)idx;
- (id)objectAtIndex:(NSUInteger)index;

- (void)removeObject:(id)object;
- (void)removeFirstObject;
- (void)removeLastObject;
- (void)removeObjectAtIndex:(NSUInteger)index;

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;
- (void)enumerateObjectsUsingBlock:(void (NS_NOESCAPE ^)(id obj, NSUInteger idx, BOOL stop))block;
@end

NS_ASSUME_NONNULL_END
