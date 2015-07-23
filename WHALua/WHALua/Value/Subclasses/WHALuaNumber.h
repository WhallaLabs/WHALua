//
//  WHALuaNumber.h
//  WHALua
//
//  Created by Szymon Kuczur on 15.07.2015.
//  Copyright (c) 2015 Whallalabs. All rights reserved.
//

#import "WHALuaValue.h"

@interface WHALuaNumber : WHALuaValue

@property (copy, nonatomic) NSNumber *number;

@end
