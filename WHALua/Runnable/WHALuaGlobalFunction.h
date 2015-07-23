//
//  WHALuaGlobalFunction.h
//  WHALua
//
//  Created by Szymon Kuczur on 17.07.2015.
//  Copyright (c) 2015 Whallalabs. All rights reserved.
//

#import "WHALuaRunnable.h"

@interface WHALuaGlobalFunction : WHALuaRunnable

@property (copy, nonatomic, readonly) NSString *name;
@property (copy, nonatomic) NSArray *input;
@property (copy, nonatomic, readonly) NSArray *output;
@property (assign, nonatomic) NSInteger outputCount;

- (instancetype)initWithGlobalName:(NSString *)name;

- (void)willExecuteFunctionInContext:(WHALuaContext *)context;
- (void)didExecuteFunctionInContext:(WHALuaContext *)context;

@end
