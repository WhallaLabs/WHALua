//
//  WHALuaValue.m
//  WHALua
//
//  Created by Szymon Kuczur on 15.07.2015.
//  Copyright (c) 2015 Whallalabs. All rights reserved.
//

#import "WHALuaValue.h"

// /////////////////////////////////////////////////////////////////////////////

@interface WHALuaValue ()

@property (assign, nonatomic, readwrite, getter = isGlobal) BOOL global;
@property (copy, nonatomic, readwrite) NSString *name;
@property (strong, nonatomic, readwrite) WHALuaContext *context;

@end


// /////////////////////////////////////////////////////////////////////////////

@implementation WHALuaValue

- (instancetype)initWithContext:(WHALuaContext *)context {
    self = [super init];
    if (self) {
        self.context = context;
    }
    return self;
}

- (instancetype)initWithGlobalName:(NSString *)name inContext:(WHALuaContext *)context {
    self = [self initWithContext:context];
    if (self) {
        self.global = YES;
        self.name = name;
    }
    return self;
}

#pragma mark - WHALuaValue

- (void *)valuePointerForType:(NSString *)type; {
    NSAssert(NO, @"valuePointerForType: not implemnented");
    return nil;
}

+ (BOOL)handlesType:(NSString *)type {
    NSAssert(NO, @"handlesType: not implemnented");
    return NO;
}

+ (BOOL)handlesValueAtIndex:(NSInteger)index inContext:(WHALuaContext *)context {
    NSAssert(NO, @"handlesValueAtIndex: inContext: not implemnented");
    return NO;
}

- (NSInteger)pushValue {
    NSAssert(NO, @"pushValueToContext: not implemented");
    return 0;
}

+ (instancetype)valueWithIndex:(NSInteger)index withinContext:(WHALuaContext *)context {
    id object = [[self alloc] initWithIndex:index withinContext:context];
    return object;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"

- (instancetype)initWithIndex:(NSInteger)index withinContext:(WHALuaContext *)context {
    NSAssert(NO, @"initWithIndex: withinContext: not implemented");
    return nil;
}

#pragma clang diagnostic pop

+ (instancetype)valueWithInvocation:(NSInvocation *)invocation inContext:(WHALuaContext *)context {
    id object = [[self alloc] initWithInvocation:invocation inContext:context];
    return object;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"

- (instancetype)initWithInvocation:(NSInvocation *)invocation inContext:(WHALuaContext *)context {
    NSAssert(NO, @"initWithInvocation: inContext: not implemented");
    return nil;
}

#pragma clang diagnostic pop

@end
