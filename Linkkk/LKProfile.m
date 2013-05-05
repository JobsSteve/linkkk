//
//  LKProfile.m
//  Linkkk
//
//  Created by Vincent Wen on 4/16/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import "LKProfile.h"
#import "LKAppDelegate.h"
#import "LKMainViewController.h"

#import "SinaWeibo.h"

/*
 We have two levels of login - Sina Weibo and Linkkk.
 We maintain a Sina Weibo session at all times. Thus, the user is always
     assumed to be logged in on Sina Weibo.
 We attempt to login to Linkkk whenever the LKProfile is being instantiated.
 */

@interface LKProfile ()
@property (strong, nonatomic) CLLocationManager *locationManager;
@end

@implementation LKProfile

+ (LKProfile *)profile
{
    static LKProfile *profile = nil;
    if (profile == nil) {
        profile = [[LKProfile alloc] init];
    }
    return profile;
}

- (id)init
{
    self = [super init];
    if (self) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        _locationManager.distanceFilter = 500; // movement threshold for new events
        [_locationManager startUpdatingLocation];
    }
    return self;
}

- (BOOL)isLoggedIn
{
    return _csrf;
}

- (BOOL)hasProfile
{
    return _username;
}

- (void)login
{
    if ([self isLoggedIn]) {
        if ([self hasProfile])
            return;
        [self getProfile];
        return;
    }
    
    SinaWeibo *weibo = ((LKAppDelegate *)[UIApplication sharedApplication].delegate).sinaweibo;
    
    NSString *post = [NSString stringWithFormat:@"uid=%@&access_token=%@&expires_in=%d", weibo.userID, weibo.accessToken, (int)weibo.expirationDate.timeIntervalSinceNow];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://map.linkkk.com/v5/app/login/"]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = postData;
    [request setValue:[NSString stringWithFormat:@"%d", [postData length]] forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        NSString *string = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        
        NSString *cookie = [httpResponse.allHeaderFields objectForKey:@"Set-Cookie"];
        _cookie = cookie;
        NSRange range = [cookie rangeOfString:@"XSRF-TOKEN="];
        cookie = [cookie substringFromIndex:range.location + range.length];
        range = [cookie rangeOfString:@";"];
        _csrf = [cookie substringToIndex:range.location];
        NSLog(@"%d, %@, Cookie: %@", httpResponse.statusCode, string, cookie);
        
        [self getProfile];
        
        // Parse user info
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        NSLog(@"%@", json);
    }];
}

- (void)getProfile
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://map.linkkk.com/api/alpha/myself/"]];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        // Parse user info
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        NSDictionary *profile = [[json objectForKey:@"objects"] objectAtIndex:0];
        _avatarURL = [profile objectForKey:@"avatar_url"];
        self.username = [profile objectForKey:@"nickname"];
        NSLog(@"%@", profile);
    }];
}

#pragma mark - Location Manager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation* location = [locations lastObject];
    _location = location;
    [manager stopUpdatingLocation];
    
    [self _reverseGeocoding];
}

#pragma mark - Helper Functions

- (void)_reverseGeocoding
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:_location completionHandler:^(NSArray *placemarks, NSError *error)
    {
        if ([placemarks count] > 0)
        {
            self.placemark = [placemarks objectAtIndex:0];
        }
    }];
}

@end
