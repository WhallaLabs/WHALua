//
//  WHALuaString.h
//  WHALua
//
//  Created by Szymon Kuczur on 17.07.2015.
//  Copyright (c) 2015 Whallalabs. All rights reserved.
//

#import "WHALuaValue.h"

@interface WHALuaString : WHALuaValue

@property (copy, nonatomic) NSString *string;

@end
