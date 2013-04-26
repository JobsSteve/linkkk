//
//  LKAppDelegate.m
//  Linkkk
//
//  Created by Vincent Wen on 4/15/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import "LKAppDelegate.h"

#import "SinaWeibo.h"

#define kAppKey             @"2279872707"
#define kAppSecret          @"e0a3ff6db611f960c7e3f1765407c9d7"
#define kAppRedirectURI     @"http://map.linkkk.com"

@implementation LKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    // Sina Weibo Defaults
    _sinaweibo = [[SinaWeibo alloc] initWithAppKey:kAppKey appSecret:kAppSecret appRedirectURI:kAppRedirectURI ssoCallbackScheme:@"linkkk.weibo" andDelegate:nil];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *auth = [defaults objectForKey:@"SinaWeiboAuthData"];
    if ([auth objectForKey:@"AccessTokenKey"] && [auth objectForKey:@"ExpirationDateKey"] && [auth objectForKey:@"UserIDKey"])
    {
        _sinaweibo.accessToken = [auth objectForKey:@"AccessTokenKey"];
        _sinaweibo.expirationDate = [auth objectForKey:@"ExpirationDateKey"];
        _sinaweibo.userID = [auth objectForKey:@"UserIDKey"];
    }
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [_sinaweibo handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [_sinaweibo handleOpenURL:url];
}

@end
