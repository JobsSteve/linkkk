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

+ (LKPlace *)randomPlace
{
    LKProfile *profile = [LKProfile profile];
    CLLocationCoordinate2D coord = profile.location.coordinate;
    NSString *post = [NSString stringWithFormat:@"range=0&latitude=%f&longitude=%f&limit=10&offset=0", coord.latitude, coord.longitude];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://map.linkkk.com/api/alpha/experience/search/"]];
    request.HTTPMethod = @"GET";
    request.HTTPBody = postData;
    [request setValue:[NSString stringWithFormat:@"%d", [postData length]] forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSHTTPURLResponse *response;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSLog(@"%d, %@", response.statusCode, string);
    
    LKPlace *place = [[LKPlace alloc] initWithJSON:nil];
    return place;
}

- (id)initWithJSON:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        _title = [[dict objectForKey:@"title"] copy];
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
