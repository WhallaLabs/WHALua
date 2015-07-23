//
//  WHALuaScript.m
//  WHALua
//
//  Created by Szymon Kuczur on 14.07.2015.
//  Copyright (c) 2015 Whallalabs. All rights reserved.
//

#import "WHALuaScript.h"

#import "WHALuaContext.h"

#import <Lua/lualib.h>
#import <Lua/lauxlib.h>

@interface WHALuaScript ()

@property (copy, nonatomic) NSString *scriptString;

@end

@implementation WHALuaScript

- (instancetype)initWithString:(NSString *)string {
    self = [super init];
    if (self) {
        self.scriptString = string;
    }
    return self;
}

- (instancetype)initWithFile:(NSString *)path {
    NSError *error;
    NSString *contentsOfFile = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        return nil;
    }
    self = [self initWithString:contentsOfFile];
    return self;
}

- (void)exexuteWithContext:(WHALuaContext *)context {
    NSString *script = self.scriptString;
    if (luaL_loadbuffer(context.state, [script UTF8String], [script length], nil) || lua_pcall(context.state, 0, 0, 0)) {
        NSLog(@"lua error: %s",lua_tostring(context.state, -1));
    }
}

@end
