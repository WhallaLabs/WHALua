//
//  WHARunnable.m
//  WHALua
//
//  Created by Szymon Kuczur on 14.07.2015.
//  Copyright (c) 2015 Whallalabs. All rights reserved.
//

#import "WHALuaRunnable.h"

@implementation WHALuaRunnable

- (void)exexuteWithContext:(WHALuaContext*)context {
    NSException *exception = [NSException exceptionWithName:@"exexuteWithContext: Not implemented"
                                                     reason:@"" userInfo:nil];
    [exception raise];
}

@end
