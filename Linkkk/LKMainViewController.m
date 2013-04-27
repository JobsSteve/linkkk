//
//  LKMainViewController.m
//  Linkkk
//
//  Created by Vincent Wen on 4/15/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import "LKMainViewController.h"
#import "LKMainView.h"

#import "LKLoginViewController.h"
#import "LKNearbyViewController.h"
#import "LKCreateViewController.h"
#import "LKProfileViewController.h"

#import "LKAppDelegate.h"
#import "LKProfile.h"
#import "LKPlace.h"

#import "UIBarButtonItem+Linkkk.h"

#import "SinaWeibo.h"

#import <QuartzCore/CALayer.h>

@interface LKMainViewController ()
{
    LKNearbyViewController *_nearbyViewController;
    LKCreateViewController *_createViewController;
    LKProfileViewController *_profileViewController;
}
@end

@implementation LKMainViewController

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ((LKMainView *)self.view).delegate = self;
    
    self.title = @"首页";
    
    // Custom Navigation Bar
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    
    // Custom Title
    self.navigationItem.titleView = [UIBarButtonItem customTitleLabelWithString:@"当前：未知地址"];
    
    // Custom fonts
    _nearbyButton.titleLabel.font = [UIFont fontWithName:@"Entypo" size:80.0];
    _createButton.titleLabel.font = [UIFont fontWithName:@"Entypo" size:80.0];
    _profileButton.titleLabel.font = [UIFont fontWithName:@"Entypo" size:80.0];
    
    // Update Location
    LKProfile *profile = [LKProfile profile];
    profile.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    if (![self _sinaweibo].isAuthValid)
        [self performSegueWithIdentifier:@"LoginSegue" sender:self];
    else {
        [self _login];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.view becomeFirstResponder];
    [super viewWillAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [self.view resignFirstResponder];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Shake View Delegate

- (void)viewDidShake
{
    [self performSegueWithIdentifier:@"NearbySegue" sender:nil];
}

#pragma mark - Push View Controllers

- (IBAction)nearbyButtonSelected:(id)sender
{
    if (_nearbyViewController == nil) {
        _nearbyViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"NearbyScene"];
    }
    
    [self.navigationController pushViewController:_nearbyViewController animated:YES];
}

#pragma mark - Sina Weibo Handlers

- (SinaWeibo *)_sinaweibo
{
    static SinaWeibo *weibo = nil;
    if (weibo == nil) {
        weibo = ((LKAppDelegate *)[UIApplication sharedApplication].delegate).sinaweibo;
        weibo.delegate = self;
    }
    return weibo;
}

- (void)_storeAuthData
{
    SinaWeibo *sinaweibo = [self _sinaweibo];
    
    NSDictionary *authData = [NSDictionary dictionaryWithObjectsAndKeys:
                              sinaweibo.accessToken, @"AccessTokenKey",
                              sinaweibo.expirationDate, @"ExpirationDateKey",
                              sinaweibo.userID, @"UserIDKey",
                              sinaweibo.refreshToken, @"refresh_token", nil];
    [[NSUserDefaults standardUserDefaults] setObject:authData forKey:@"SinaWeiboAuthData"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)_removeAuthData
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SinaWeiboAuthData"];
}

#pragma mark Sina Weibo Delegate

- (void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo
{
    NSLog(@"WEIBO: did login");
    [self _storeAuthData];
    [self _dismiss];
    [self _login];
}

- (void)sinaweiboDidLogOut:(SinaWeibo *)sinaweibo
{
    NSLog(@"WEIBO: did logout");
    [self _removeAuthData];
}

- (void)sinaweiboLogInDidCancel:(SinaWeibo *)sinaweibo
{
    NSLog(@"WEIBO: did cancel");
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo accessTokenInvalidOrExpired:(NSError *)error
{
    NSLog(@"WEIBO: access token expired %@", error);
    [self _removeAuthData];
    [self performSegueWithIdentifier:@"LoginSegue" sender:self];
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo logInDidFailWithError:(NSError *)error
{
    NSLog(@"WEIBO: login failed: %@", error);
}

#pragma mark - Helper Functions

- (void)_dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Linkkk login
- (void)_login
{
    LKProfile *profile = [LKProfile profile];
    [profile login];
}

- (void)locationUpdated:(NSString *)placemark
{
    UILabel *titleLabel = (UILabel *)self.navigationItem.titleView;
    titleLabel.text = [NSString stringWithFormat:@"当前：%@", placemark];
    [titleLabel sizeToFit];
}

@end
