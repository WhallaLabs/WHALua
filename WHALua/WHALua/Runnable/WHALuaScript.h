//
//  WHALuaScript.h
//  WHALua
//
//  Created by Szymon Kuczur on 14.07.2015.
//  Copyright (c) 2015 Whallalabs. All rights reserved.
//

#import "WHALuaRunnable.h"

@interface WHALuaScript : WHALuaRunnable

- (instancetype)initWithString:(NSString *)string;
- (instancetype)initWithFile:(NSString *)path;

@end
