//
//  LKPlace.m
//  Linkkk
//
//  Created by Vincent Wen on 4/21/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import "LKPlace.h"

@implementation LKPlace

- (id)initWithJSON:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        _title = @"我的戏剧俱乐部";
        _content = [[dict objectForKey:@"content"] copy];
        _address = [[dict objectForKey:@"location"] copy];
        _distance = [[dict objectForKey:@"distance"] intValue];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@\n%@\n%@\n%@", [super description], _title, _address, _content];
}

@end
