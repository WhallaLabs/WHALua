//
//  WHALuaGlobalFunction.m
//  WHALua
//
//  Created by Szymon Kuczur on 17.07.2015.
//  Copyright (c) 2015 Whallalabs. All rights reserved.
//

#import "WHALuaGlobalFunction.h"

#import "WHALuaContext.h"
#import "WHALuaValue.h"

#import "WHALuaObject.h"
#import "WHALuaNumber.h"
#import "WHALuaString.h"

#import "lualib.h"
#import "lauxlib.h"

@interface WHALuaGlobalFunction ()

@property (copy, nonatomic, readwrite) NSString *name;
@property (copy, nonatomic, readwrite) NSArray *output;

@end

@implementation WHALuaGlobalFunction

- (instancetype)initWithGlobalName:(NSString *)name {
    self = [super init];
    if (self) {
        self.name = name;
    }
    return self;
}

- (void)exexuteWithContext:(WHALuaContext *)context {
    [self willExecuteFunctionInContext:context];
    
    lua_getglobal(context.state, [self.name UTF8String]);
    
    for (WHALuaValue *value in self.input) {
        [value pushValue];
    }
    
    lua_pcall(context.state, (int)self.input.count, (int)self.outputCount, 0);
    
    if (self.outputCount > 0) {
        [self loadOutputFromContext:context];
    }
    
    [self didExecuteFunctionInContext:context];
}

- (void)loadOutputFromContext:(WHALuaContext *)context {
    int top = lua_gettop(context.state);
    
    NSMutableArray *result = [NSMutableArray new];
    for (int stackPointer = (top - (int)self.outputCount) - 1; stackPointer <= top; stackPointer++) {
        Class<WHALuaValue> valueClass = [WHALuaGlobalFunction classFroValueAtIndex:stackPointer inContext:context];
        if (!valueClass) {
            NSAssert(NO, @"Unsupported return type");
            return;
        }
        WHALuaValue *value = [valueClass valueWithIndex:stackPointer withinContext:context];
        [result addObject:value];
    }
    self.output = [result copy];
}

#pragma mark - Notifications

// Temporary - create a protocol or mappin instead of those
- (void)willExecuteFunctionInContext:(WHALuaContext *)context {
}

- (void)didExecuteFunctionInContext:(WHALuaContext *)context {
}

// Temporary method - needs global class register
+ (Class<WHALuaValue>)classFroValueAtIndex:(NSInteger)index inContext:(WHALuaContext *)context {
    NSArray *classes = @[[WHALuaObject class],[WHALuaNumber class], [WHALuaString class]];
    
    for (Class<WHALuaValue> valueClass in classes) {
        if ([valueClass handlesValueAtIndex:index inContext:context]) {
            return valueClass;
        }
    }
    return nil;
}

@end
