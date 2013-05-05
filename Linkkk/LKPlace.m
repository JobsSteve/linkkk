//
//  LKPlace.m
//  Linkkk
//
//  Created by Vincent Wen on 4/21/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import "LKPlace.h"
#import "LKProfile.h"

@implementation LKPlace

- (id)initWithJSON:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        _title = [[dict objectForKey:@"title"] copy];
        _content = [[dict objectForKey:@"content"] copy];
        _address = [[dict objectForKey:@"location"] copy];
        _album = [[dict objectForKey:@"album"] copy];
        _placeID = [[dict objectForKey:@"id"] intValue];
        _distance = [[dict objectForKey:@"distance"] intValue];
        _hasFaved = [[dict objectForKey:@"has_faved"] boolValue];
        _fav_count = [[dict objectForKey:@"count_favourite"] intValue];
        _like_count = [[dict objectForKey:@"count_like"] intValue];
        _comment_count = [[dict objectForKey:@"count_comment"] intValue];
        _location.latitude = [[dict objectForKey:@"latitude"] floatValue];
        _location.longitude = [[dict objectForKey:@"longitude"] floatValue];
        
        _author = [[dict objectForKey:@"realuser"] copy];
        
        NSLog(@"%@", dict);
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@\n%@\n%@\n%@", [super description], _title, _address, _content];
}

@end
