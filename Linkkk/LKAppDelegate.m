//
//  LKAppDelegate.m
//  Linkkk
//
//  Created by Vincent Wen on 4/15/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import "LKAppDelegate.h"
#import "LKMapManager.h"

#import "SinaWeibo.h"
#import "BMapKit.h"
#import "MobClick.h"

#define kAppKey             @"2279872707"
#define kAppSecret          @"e0a3ff6db611f960c7e3f1765407c9d7"
#define kAppRedirectURI     @"http://www.linkkk.com"
#define kMapKey             @"FB1C88AF3B39EB16C330E6F5841C4D3D387AD96E"
#define kWechatAppID        @"wx76dd1c6028793dbe"
#define kWechatAppKey       @"d2f78bdc088622e6e6deab2c2491514b"
#define kUmengAppKey        @"51dcd74456240b7c75007aa5"

@implementation LKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Umeng
    [MobClick startWithAppkey:kUmengAppKey];// reportPolicy:(ReportPolicy) REALTIME channelId:nil];
    //[MobClick setLogEnabled:YES];
    
    // WeChat
    [WXApi registerApp:kWechatAppID];
    
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
    
    // Initialize Baidu Map
    _mapManager = [[BMKMapManager alloc] init];
    if (![_mapManager start:kMapKey generalDelegate:nil])
    {
        NSLog(@"ERROR: baidu map manager failed to load");
    } else {
        LKMapManager *manager = [LKMapManager sharedInstance];
        [manager initSearch];
    }
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // BUG: In-call status bar
    self.resignActiveNotifier = _resignActiveNotifier;
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
    return [_sinaweibo handleOpenURL:url] & [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [_sinaweibo handleOpenURL:url] & [WXApi handleOpenURL:url delegate:self];
}

#pragma mark - WeChat Delegate

- (void)onReq:(BaseReq *)req
{
    
}

- (void)onResp:(BaseResp *)resp
{
    
}

@end
