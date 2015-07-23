//
//  WHALuaContext.h
//  WHALua
//
//  Created by Szymon Kuczur on 14.07.2015.
//  Copyright (c) 2015 Whallalabs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "lua.h"

@class WHALuaRunnable;

@interface WHALuaContext : NSObject

@property (assign, nonatomic,readonly) lua_State *state;

+ (instancetype)luaWithNewState;
+ (instancetype)luaWithState:(lua_State *)state;

- (instancetype)initWithState:(lua_State *)state;
- (void)addLuaPath:(NSString *)path;

@end
