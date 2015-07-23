//
//  WHARunnable.h
//  WHALua
//
//  Created by Szymon Kuczur on 14.07.2015.
//  Copyright (c) 2015 Whallalabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WHALuaContext;

@interface WHALuaRunnable : NSObject

- (void)exexuteWithContext:(WHALuaContext *)context;

@end
