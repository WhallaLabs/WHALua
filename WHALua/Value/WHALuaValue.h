//
//  WHALuaValue.h
//  WHALua
//
//  Created by Szymon Kuczur on 15.07.2015.
//  Copyright (c) 2015 Whallalabs. All rights reserved.
//

@import Foundation;

#import "WHALuaContext.h"

@protocol WHALuaValue <NSObject>

+ (BOOL)handlesType:(NSString *)type;
+ (BOOL)handlesValueAtIndex:(NSInteger)index inContext:(WHALuaContext *)context;

- (NSInteger)pushValue;

- (void *)valuePointerForType:(NSString *)type;

+ (instancetype)valueWithIndex:(NSInteger)index withinContext:(WHALuaContext *)context;
- (instancetype)initWithIndex:(NSInteger)index withinContext:(WHALuaContext *)context;

+ (instancetype)valueWithInvocation:(NSInvocation *)invocation inContext:(WHALuaContext *)context;
- (instancetype)initWithInvocation:(NSInvocation *)invocation inContext:(WHALuaContext *)context;

@end

@interface WHALuaValue : NSObject<WHALuaValue>

@property (strong, nonatomic, readonly) WHALuaContext *context;
@property (copy, nonatomic, readonly) NSString *name;
@property (assign, nonatomic, readonly, getter = isGlobal) BOOL global;

- (instancetype)initWithGlobalName:(NSString *)name inContext:(WHALuaContext *)context;

- (instancetype)initWithContext:(WHALuaContext *)context NS_DESIGNATED_INITIALIZER;

@end
