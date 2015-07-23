//
//  WHALuaObject.m
//  WHALua
//
//  Created by Szymon Kuczur on 15.07.2015.
//  Copyright (c) 2015 Whallalabs. All rights reserved.
//

#import "WHALuaObject.h"
#import "WHALuaObject+Static.h"

#import "WHALuaNumber.h"
#import "WHALuaString.h"

// /////////////////////////////////////////////////////////////////////////////

static const char *WHALuaObjectStorageMetatableIndex = "__whalua_id";

// /////////////////////////////////////////////////////////////////////////////

@interface WHALuaObject ()

@end

// /////////////////////////////////////////////////////////////////////////////

@implementation WHALuaObject

+ (NSArray *)handledTypes {
    // object and class
    return @[
             @"@",
             @"#"
             ];
}

+ (void)initialize {
    [super initialize];
    [self static_registerValueTypes:@[
                                      [WHALuaObject class],
                                      [WHALuaNumber class],
                                      [WHALuaString class],
                                      ]];
}

#pragma mark - WHALuaValue

- (void *)valuePointerForType:(NSString *)type; {
    return (void *)(&_value);
}

+ (BOOL)handlesType:(NSString *)type {
    for (NSString *handledType in [self handledTypes]) {
        BOOL typeMatch = [handledType isEqualToString:type];
        if (typeMatch) {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)handlesValueAtIndex:(NSInteger)index inContext:(WHALuaContext *)context {
    if (index < 0) {
        index = lua_gettop(context.state) + (index + 1);
    }
    
    BOOL isTable = lua_istable(context.state, (int)index);
    if (!isTable) {
        return NO;
    }
    
    lua_pushstring(context.state, WHALuaObjectStorageMetatableIndex);
    lua_gettable(context.state, (int)index);
    BOOL result = NO;
    if (lua_isuserdata(context.state, -1)) {
        result = YES;
    }
    lua_pop(context.state, 1); // remove table entry value
    
    return result;
}

- (NSInteger)pushValue {
    [self pushValueToLua];
    NSInteger numberOfPushedValues = 1;
    return numberOfPushedValues;
}

- (instancetype)initWithIndex:(NSInteger)index withinContext:(WHALuaContext *)context {
    self = [super initWithContext:context];
    if (self) {
        self.value = [self objectAtStackIndex:index];
    }
    return self;
}

- (instancetype)initWithInvocation:(NSInvocation *)invocation inContext:(WHALuaContext *)context {
    self = [super initWithContext:context];
    if (self) {
        CFTypeRef result;
        [invocation getReturnValue:&result];
        self.value = (__bridge id)(result);
    }
    return self;
}

#pragma mark - Loading from lua

- (id)objectAtStackIndex:(NSInteger)stackIndex {
    lua_State *state = self.context.state;
    
    // if negative index - get from the top of the stack
    if (stackIndex < 0) {
        stackIndex = lua_gettop(state) + (stackIndex + 1);
    }
    
    id result = nil;
    if (lua_istable(state, (int)stackIndex)) {
        lua_pushstring(state, WHALuaObjectStorageMetatableIndex);
        int val = lua_gettop(state);
        lua_gettable(state, (int)stackIndex);
        result = (__bridge id)(lua_touserdata(state,val));
    }
    
    return result;
}

#pragma mark - Pushing Values

- (void)pushValueToLua {
    if (!self.isWeak && !self.isNotRetained) {
        CFRetain((__bridge CFTypeRef)(self.value));
    }
    void *pointer = (__bridge void *)(self.value);
    
    lua_newtable(self.context.state);
    NSInteger data = lua_gettop(self.context.state);
    lua_pushstring(self.context.state, WHALuaObjectStorageMetatableIndex);
    lua_pushlightuserdata(self.context.state, pointer);
    
    lua_settable(self.context.state, (int)data);
    
    lua_newtable(self.context.state);
    [self configureMetatable];
    lua_setmetatable(self.context.state,(int)data);
    
    if (self.isGlobal) {
        lua_setglobal(self.context.state, [self.name UTF8String]);
    }
}

- (void)configureMetatable {
    // not defined function hook
    int metatable = lua_gettop(self.context.state);
    lua_pushstring(self.context.state,"__index");
    lua_pushcfunction(self.context.state,&WHALua_methodlookup);
    lua_settable(self.context.state,metatable);
    
    if (!self.isWeak) {
        // garbage collection hook
        lua_pushstring(self.context.state,"__gc");
        lua_pushcfunction(self.context.state,&WHALua_release);
        lua_settable(self.context.state,metatable);
    }
}

@end
