//
//  WHALua+Static.m
//  WHALua
//
//  Created by Szymon Kuczur on 15.07.2015.
//  Copyright (c) 2015 Whallalabs. All rights reserved.
//

#import "WHALuaContext+Static.h"

#import "WHALuaObject.h"

#import <Lua/lualib.h>
#import <Lua/lauxlib.h>

// /////////////////////////////////////////////////////////////////////////////

int WHALua_register(lua_State *state);
int WHALua_lookup_class(lua_State *state);
int WHALua_log(lua_State *state);
int WHALua_stringToObject(lua_State *state);
int WHALua_numberToObject(lua_State *state);
int WHALua_registerGlobals(lua_State *state);
static int WHALua_toObject(lua_State *state);

// /////////////////////////////////////////////////////////////////////////////

// static const cant be used to statically index an array
#define WHALuaLibName "WHALua"
static const char *WHALuaLibraryName = WHALuaLibName;

static const luaL_Reg WHALua_libraries[] = {
    {WHALuaLibName, WHALua_register},
    {NULL, NULL}
};

static const luaL_Reg WHALua_functions[] = {
    {"class",WHALua_lookup_class},
    {"log",WHALua_log},
    {NULL,NULL},
};

int WHALua_lookup_class(lua_State *state){
    NSString *string = [NSString stringWithUTF8String:lua_tostring(state,-1)];
    id theClass = NSClassFromString(string);
    
    if (theClass != nil) {
        WHALuaContext *context = [WHALuaContext luaWithState:state];
        WHALuaObject *object = [[WHALuaObject alloc] initWithContext:context];
        object.weak = YES;
        object.value = theClass;
        [object pushValue];
    } else {
        lua_pushnil(state);
    }
    return 1;
}

int WHALua_log(lua_State *state){
    NSString *message = [NSString stringWithUTF8String:lua_tostring(state,-1)];
    NSLog(@"%@",message);
    return 0;
}

#pragma mark - Global convenience

static int WHALua_toObject(lua_State *state) {
    // Order is important, numbers are sometimes treated as strings
    if (lua_isnumber(state, -1)) {
        return WHALua_numberToObject(state);
    }
    
    if (lua_isstring(state, -1)) {
        return WHALua_stringToObject(state);
    }
    
    return 0;
}

static int WHALua_toValue(lua_State *state) {
    WHALuaContext *context = [WHALuaContext luaWithState:state];
    WHALuaObject *object = [WHALuaObject valueWithIndex:-1 withinContext:context];
    
    BOOL isNumber = [object.value isKindOfClass:[NSNumber class]];
    if (isNumber) {
        NSNumber *numberObject = object.value;
        lua_pushnumber(state, [numberObject doubleValue]);
        return 1;
    }
    
    BOOL isString = [object.value isKindOfClass:[NSString class]];
    if (isString) {
        NSString *stringObject = object.value;
        lua_pushstring(state, [stringObject UTF8String]);
        return 1;
    }
    
    return 0;
}

int WHALua_stringToObject(lua_State *state) {
    NSString *stringObject = [NSString stringWithUTF8String:lua_tostring(state, -1)];
    WHALuaContext *context = [WHALuaContext luaWithState:state];
    WHALuaObject *object = [[WHALuaObject alloc] initWithContext:context];
    object.value = stringObject;
    return (int)[object pushValue];
}

int WHALua_numberToObject(lua_State *state) {
    NSNumber *numberObject = @(lua_tonumber(state, -1));
    WHALuaContext *context = [WHALuaContext luaWithState:state];
    WHALuaObject *object = [[WHALuaObject alloc] initWithContext:context];
    object.value = numberObject;
    return (int)[object pushValue];
}

#pragma mark - Initialization

int WHALua_register(lua_State *state){
    luaL_newlib(state,WHALua_functions);
    lua_pushvalue(state, -1);
    lua_setglobal(state, WHALuaLibraryName);
    
    return WHALua_registerGlobals(state);
}

int WHALua_registerGlobals(lua_State *state) {
    lua_pushcfunction(state, WHALua_toObject);
    lua_setglobal(state, "O");
    
    lua_pushcfunction(state, WHALua_toValue);
    lua_setglobal(state, "V");
    
    return 0;
}

@implementation WHALuaContext (Static)

- (void)loadLibraries {
    luaL_openlibs(self.state);
    const luaL_Reg *libraries = WHALua_libraries;
    for (; libraries->func; libraries++) {
        lua_pushcfunction(self.state,libraries->func);
        lua_pushstring(self.state,libraries->name);
        lua_call(self.state,1,0);
    }
}

@end
