//
//  WHALuaObject+Static.m
//  WHALua
//
//  Created by Szymon Kuczur on 16.07.2015.
//  Copyright (c) 2015 Whallalabs. All rights reserved.
//

#import "WHALuaObject+Static.h"

#import "WHALuaValue.h"
#import "WHALuaNumber.h"

#import <Lua/lualib.h>
#import <Lua/lauxlib.h>

// Keeps LUAValue classes for parsing
static NSArray *valuesArray;

#pragma mark - Memory management

int WHALua_release(lua_State *state){
    WHALuaContext *context = [WHALuaContext luaWithState:state];
    WHALuaObject *object = [WHALuaObject valueWithIndex:-1 withinContext:context];
    CFRelease((__bridge CFTypeRef)(object.value));
    return 0;
}

#pragma mark - Calling method

int configureInvocation(NSInvocation *invocation, WHALuaContext *context, NSMutableArray *retainArray) {
    NSUInteger argumentCount = [invocation.methodSignature numberOfArguments];
    
    NSUInteger argumentIndex;
    NSUInteger luaArgument;
    
    // in lua {name, self} - in objC {target, selector}, arguments are next
    for (argumentIndex = 2, luaArgument = 2; argumentIndex < argumentCount; argumentIndex++, luaArgument++) {
        NSString *argumentType = [NSString stringWithUTF8String:[invocation.methodSignature getArgumentTypeAtIndex:argumentIndex]];
        Class<WHALuaValue> valueClass = [WHALuaObject static_valueForType:argumentType];
        if (!valueClass) {
            return 0;
        }
        
        WHALuaValue *argument = [valueClass valueWithIndex:luaArgument withinContext:context];
        [invocation setArgument:[argument valuePointerForType:argumentType] atIndex:argumentIndex];
        // used to keep alive arguments, and pointers that they return, valid
        [retainArray addObject:argument];
    }
    return 1;
}

int resultFromInvocation(NSInvocation *invocation, WHALuaContext *context) {
    NSString *resultType = [NSString stringWithUTF8String:[invocation.methodSignature methodReturnType]];
    Class<WHALuaValue> valueClass = [WHALuaObject static_valueForType:resultType];
    if (!valueClass) {
        return 0;
    }
    
    WHALuaValue *result = [valueClass valueWithInvocation:invocation inContext:context];
    
    NSString *selectorName = NSStringFromSelector(invocation.selector);
    for (NSString *retainedSelectorName in @[@"alloc", @"new", @"copy", @"mutableCopy"]) {
        NSRange range = [selectorName rangeOfString:retainedSelectorName];
        BOOL shouldNotRetainObject = (range.location == 0 && valueClass == [WHALuaObject class]);
        if (shouldNotRetainObject) {
            ((WHALuaObject *)result).notRetained = YES;
        }
    }
    
    return (int)[result pushValue];
}

int WHALua_methodcall(lua_State *state){
    WHALuaContext *context = [WHALuaContext luaWithState:state];
    WHALuaObject *target = [[WHALuaObject alloc] initWithIndex:1 withinContext:context];
    if (target == nil || target.value == nil) {
        return 0;
    }
    
    const char *luaSelectorName = lua_tostring(context.state,lua_upvalueindex(1));
    NSString *selectorName = [NSString stringWithUTF8String:luaSelectorName];
    
    NSInvocation *invocation = [WHALuaObject static_invocationFromString:selectorName withTarget:target.value];
    
    NSMutableArray *retainArray = [@[] mutableCopy];
    if (!configureInvocation(invocation, context, retainArray)) {
        return 0;
    }
    
    [invocation invoke];
    return resultFromInvocation(invocation, context);
}

int WHALua_methodlookup(lua_State *state) {
    lua_pushvalue(state, -1);
    lua_pushcclosure(state, &WHALua_methodcall, 1);
    return 1;
}

@implementation WHALuaObject (Static)

+ (NSInvocation *)static_invocationFromString:(NSString *)selectorName withTarget:(id)target {
    // change _ in method names to objective c standard :
    selectorName = [selectorName stringByReplacingOccurrencesOfString:@"_" withString:@":"];
    SEL selector = NSSelectorFromString(selectorName);
    NSMethodSignature *signature = [target methodSignatureForSelector:selector];
    if (!signature) {
        // if no selector with that name try one with : at the end
        selectorName = [selectorName stringByAppendingString:@":"];
        selector = NSSelectorFromString(selectorName);
        signature = [target methodSignatureForSelector:selector];
    }
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setSelector:selector];
    [invocation setTarget:target];
    
    return invocation;
}

+ (Class<WHALuaValue>)static_valueForType:(NSString *)type {
    for (Class<WHALuaValue> valueClass in valuesArray) {
        if ([valueClass handlesType:type]) {
            return valueClass;
        }
    }
    return nil;
}

+ (void)static_registerValueType:(Class<WHALuaValue>)value {
    if (!valuesArray) {
        valuesArray = @[];
    }
    
    valuesArray = [valuesArray arrayByAddingObject:value];
}

+ (void)static_registerValueTypes:(NSArray *)values {
    if (!valuesArray) {
        valuesArray = @[];
    }
    
    valuesArray = [valuesArray arrayByAddingObjectsFromArray:values];
}

@end
