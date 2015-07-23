//
//  WHALua.m
//  WHALua
//
//  Created by Szymon Kuczur on 14.07.2015.
//  Copyright (c) 2015 Whallalabs. All rights reserved.
//

#import "WHALuaContext.h"
#import "WHALuaContext+Static.h"

#import <Lua/lualib.h>
#import <Lua/lauxlib.h>

#import "WHALuaNumber.h"
#import "WHALuaObject.h"

@interface WHALuaContext ()

@property (assign, nonatomic, readwrite) lua_State *state;
@property (assign, nonatomic, getter = isStateOwner) BOOL stateOwner;

@end

@implementation WHALuaContext

- (void)dealloc {
    [self cleanup];
}

+ (instancetype)luaWithNewState {
    lua_State *state = luaL_newstate();
    
    if (!state) {
        return nil;
    }
    WHALuaContext *lua = [[WHALuaContext alloc] initWithState:state];
    lua.stateOwner = YES;
    [lua loadLibraries];
    return lua;
}

+ (instancetype)luaWithState:(lua_State *)state {
    if (!state) {
        return nil;
    }
    
    WHALuaContext *lua = [[WHALuaContext alloc] initWithState:state];
    return lua;
}

- (instancetype)initWithState:(lua_State *)state {
    self = [super init];
    if (self) {
        self.state = state;
    }
    return self;
}

- (void)cleanup {
    if (self.isStateOwner && self.state) {
        lua_close(self.state);
    }
}

- (void)addLuaPath:(NSString *)path {
    lua_getglobal(self.state, LUA_LOADLIBNAME);
    lua_getfield(self.state, -1, "path" );
    NSString *cur_path = [NSString stringWithUTF8String:lua_tostring(self.state, -1 )];
    cur_path = [cur_path stringByAppendingString:@";"];
    cur_path = [cur_path stringByAppendingString:path];
    cur_path = [cur_path stringByAppendingString:@"/?.lua"];
    lua_pop(self.state, 1 );
    lua_pushstring(self.state, [cur_path UTF8String]);
    lua_setfield(self.state, -2, "path" );
    lua_pop(self.state, 1 );
}

@end
