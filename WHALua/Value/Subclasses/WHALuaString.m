//
//  WHALuaString.m
//  WHALua
//
//  Created by Szymon Kuczur on 17.07.2015.
//  Copyright (c) 2015 Whallalabs. All rights reserved.
//

#import "WHALuaString.h"

@interface WHALuaString ()

@property (assign, nonatomic) const char *stringValue;

@end

@implementation WHALuaString

+ (NSArray *)handledTypes {
    return @[
             @"*",
             @"r*"
             ];
}

- (void)setString:(NSString *)string {
    [self willChangeValueForKey:@"string"];
    _string = [string copy];
    _stringValue = [self.string UTF8String];
    [self didChangeValueForKey:@"string"];
}

- (void)setStringValue:(const char *)stringValue {
    [self willChangeValueForKey:@"stringValue"];
    _stringValue = stringValue;
    _string = [NSString stringWithUTF8String:_stringValue];
    [self didChangeValueForKey:@"stringValue"];
}

#pragma mark - WHALuaValue

- (void *)valuePointerForType:(NSString *)type; {
    return (void *)&_stringValue;
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
    return lua_isstring(context.state, (int)index);
}

- (NSInteger)pushValue {
    lua_pushstring(self.context.state, [self.string UTF8String]);
    
    if (self.isGlobal) {
        lua_setglobal(self.context.state, [self.name UTF8String]);
    }
    
    NSInteger numberOfPushedValues = 1;
    return numberOfPushedValues;
}

- (instancetype)initWithIndex:(NSInteger)index withinContext:(WHALuaContext *)context {
    self = [super initWithContext:context];
    if (self) {
        const char *cString = lua_tostring(self.context.state, (int)index);
        self.string = [NSString stringWithUTF8String:cString];
    }
    return self;
}

- (instancetype)initWithInvocation:(NSInvocation *)invocation inContext:(WHALuaContext *)context {
    self = [super initWithContext:context];
    if (self) {
        NSUInteger bufferLength = [invocation.methodSignature methodReturnLength];
        void *buffer = malloc(bufferLength);
        [invocation getReturnValue:buffer];
        
        self.string = [NSString stringWithUTF8String:buffer];
        free(buffer);
    }
    return self;
}

@end
