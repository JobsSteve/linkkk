//
//  LKProfile.m
//  Linkkk
//
//  Created by Vincent Wen on 4/16/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import "LKProfile.h"
#import "LKAppDelegate.h"

#import "SinaWeibo.h"

/*
 We have two levels of login - Sina Weibo and Linkkk.
 We maintain a Sina Weibo session at all times. Thus, the user is always
     assumed to be logged in on Sina Weibo.
 We login
 */

@implementation LKProfile

+ (LKProfile *)profile
{
    static LKProfile *profile = nil;
    if (profile == nil) {
        profile = [[LKProfile alloc] init];
    }
    return profile;
}

- (BOOL)isLoggedIn
{
    return _csrf;
}

- (void)login
{
    SinaWeibo *weibo = ((LKAppDelegate *)[UIApplication sharedApplication].delegate).sinaweibo;
    
    NSString *post = [NSString stringWithFormat:@"uid=%@&access_token=%@&expires_in=%d", weibo.userID, weibo.accessToken, (int)weibo.expirationDate.timeIntervalSinceNow];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://map.linkkk.com/v5/app/login/"]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = postData;
    [request setValue:[NSString stringWithFormat:@"%d", [postData length]] forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSHTTPURLResponse *response;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSLog(@"%d, %@, %@", response.statusCode, response.allHeaderFields, string);
}

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

@end
