//
//  WHALuaObject+Static.h
//  WHALua
//
//  Created by Szymon Kuczur on 16.07.2015.
//  Copyright (c) 2015 Whallalabs. All rights reserved.
//

#import "WHALuaObject.h"

extern int WHALua_release(lua_State *state);

extern int WHALua_methodcall(lua_State *state);
extern int WHALua_methodlookup(lua_State *state);

@protocol WHALuaValue;

@interface WHALuaObject (Static)

+ (void)static_registerValueType:(Class<WHALuaValue>)value;
+ (void)static_registerValueTypes:(NSArray *)values;

+ (NSInvocation *)static_invocationFromString:(NSString *)selectorName withTarget:(id)target;
+ (Class<WHALuaValue>)static_valueForType:(NSString *)type;

@end
