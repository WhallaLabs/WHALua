//
//  WHALuaObject.h
//  WHALua
//
//  Created by Szymon Kuczur on 15.07.2015.
//  Copyright (c) 2015 Whallalabs. All rights reserved.
//

#import "WHALuaValue.h"

@interface WHALuaObject : WHALuaValue

@property (strong, nonatomic) id value;
@property (assign, nonatomic, getter = isWeak) BOOL weak;
@property (assign, nonatomic, getter = isNotRetained) BOOL notRetained;

@end
