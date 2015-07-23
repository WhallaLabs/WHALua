//
//  WHALuaNumber.m
//  WHALua
//
//  Created by Szymon Kuczur on 15.07.2015.
//  Copyright (c) 2015 Whallalabs. All rights reserved.
//

#import "WHALuaNumber.h"

#include <Lua/lua.h>
#include <Lua/lauxlib.h>
#include <Lua/lualib.h>

// /////////////////////////////////////////////////////////////////////////////

typedef lua_Number (^WHALuaNumberConverter)(void *buffer);
typedef void * (^WHALuaNumberPointer)(WHALuaNumber *luaNumber);

// /////////////////////////////////////////////////////////////////////////////

@interface WHALuaNumber (){
    // ivars used only for pointers to well formed values;
    char _charValue;
    unsigned char _unsignedCharValue;
    double _doubleValue;
    float _floatValue;
    int _intValue;
    unsigned int _unsignedIntValue;
    long _longValue;
    unsigned long _unsignedLongValue;
    long long _longLongValue;
    unsigned long long _unsignedLongLongValue;
    short _shortValue;
    unsigned short _unsignedShortValue;
}

@property (assign, nonatomic) lua_Number value;

@end

// /////////////////////////////////////////////////////////////////////////////

@implementation WHALuaNumber

+ (NSDictionary *)handledTypes {
    return @{
             @"c":^lua_Number (void *buffer) { return (lua_Number) * (char *)buffer; },
             @"C":^lua_Number (void *buffer) { return (lua_Number) * (unsigned char *)buffer; },
             @"d":^lua_Number (void *buffer) { return (lua_Number) * (double *)buffer; },
             @"f":^lua_Number (void *buffer) { return (lua_Number) * (float *)buffer; },
             @"i":^lua_Number (void *buffer) { return (lua_Number) * (int *)buffer; },
             @"I":^lua_Number (void *buffer) { return (lua_Number) * (unsigned int *)buffer; },
             @"l":^lua_Number (void *buffer) { return (lua_Number) * (long *)buffer; },
             @"L":^lua_Number (void *buffer) { return (lua_Number) * (unsigned long *)buffer; },
             @"q":^lua_Number (void *buffer) { return (lua_Number) * (long long *)buffer; },
             @"Q":^lua_Number (void *buffer) { return (lua_Number) * (unsigned long long *)buffer; },
             @"s":^lua_Number (void *buffer) { return (lua_Number) * (short *)buffer; },
             @"S":^lua_Number (void *buffer) { return (lua_Number) * (unsigned short *)buffer; }
             };
}

+ (NSDictionary *)handledPointers {
    return @{
             @"c":^void * (WHALuaNumber *luaNumber) { luaNumber->_charValue = luaNumber.value; return &(luaNumber->_charValue); },
             @"C":^void * (WHALuaNumber *luaNumber) { luaNumber->_unsignedCharValue = luaNumber.value; return &(luaNumber->_unsignedCharValue); },
             @"d":^void * (WHALuaNumber *luaNumber) { luaNumber->_doubleValue = luaNumber.value; return &(luaNumber->_doubleValue); },
             @"f":^void * (WHALuaNumber *luaNumber) { luaNumber->_floatValue = luaNumber.value; return &(luaNumber->_floatValue); },
             @"i":^void * (WHALuaNumber *luaNumber) { luaNumber->_intValue = luaNumber.value; return &(luaNumber->_intValue); },
             @"I":^void * (WHALuaNumber *luaNumber) { luaNumber->_unsignedIntValue = luaNumber.value; return &(luaNumber->_unsignedIntValue); },
             @"l":^void * (WHALuaNumber *luaNumber) { luaNumber->_longValue = luaNumber.value; return &(luaNumber->_longValue); },
             @"L":^void * (WHALuaNumber *luaNumber) { luaNumber->_unsignedLongValue = luaNumber.value; return &(luaNumber->_unsignedLongValue); },
             @"q":^void * (WHALuaNumber *luaNumber) { luaNumber->_longLongValue = luaNumber.value; return &(luaNumber->_longLongValue); },
             @"Q":^void * (WHALuaNumber *luaNumber) { luaNumber->_unsignedLongLongValue = luaNumber.value; return &(luaNumber->_unsignedLongLongValue); },
             @"s":^void * (WHALuaNumber *luaNumber) { luaNumber->_shortValue = luaNumber.value; return &(luaNumber->_shortValue); },
             @"S":^void * (WHALuaNumber *luaNumber) { luaNumber->_unsignedShortValue = luaNumber.value; return &(luaNumber->_unsignedShortValue); }
             };
}

- (void)setValue:(lua_Number)value {
    [self willChangeValueForKey:@"value"];
    _value = value;
    _number = @(_value);
    [self didChangeValueForKey:@"value"];
}

- (void)setNumber:(NSNumber *)number {
    [self willChangeValueForKey:@"number"];
    _number = [number copy];
    _value = [number doubleValue];
    [self didChangeValueForKey:@"number"];
}

#pragma mark - WHALuaValue

- (void *)valuePointerForType:(NSString *)type; {
    WHALuaNumberPointer pointerBlock = [[self class] handledPointers][type];
    return pointerBlock(self);
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
    return lua_isnumber(context.state, (int)index);
}

- (NSInteger)pushValue {
    if (self.isGlobal) {
        lua_pushnumber(self.context.state, self.value);
        lua_setglobal(self.context.state, [self.name UTF8String]);
        NSInteger numberOfPushedValues = 1;
        return numberOfPushedValues;
    }
    
    lua_pushnumber(self.context.state, self.value);
    NSInteger numberOfPushedValues = 1;
    return numberOfPushedValues;
}

- (instancetype)initWithIndex:(NSInteger)index withinContext:(WHALuaContext *)context {
    self = [super initWithContext:context];
    if (self) {
        self.value = lua_tonumber(self.context.state, (int)index);
    }
    return self;
}

- (instancetype)initWithInvocation:(NSInvocation *)invocation inContext:(WHALuaContext *)context {
    self = [super initWithContext:context];
    if (self) {
        NSUInteger bufferLength = [invocation.methodSignature methodReturnLength];
        void *buffer = malloc(bufferLength);
        [invocation getReturnValue:buffer];
        NSString *resultType = [NSString stringWithUTF8String:[invocation.methodSignature methodReturnType]];
        
        WHALuaNumberConverter conversionBlock = [[self class] handledTypes][resultType];
        self.value = conversionBlock(buffer);
        free(buffer);
    }
    return self;
}

@end
