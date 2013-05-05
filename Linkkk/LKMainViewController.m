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
#import "LKPlaceViewController.h"
#import "LKNearbyViewController.h"
#import "LKCreateViewController.h"
#import "LKProfileViewController.h"

#import "LKAppDelegate.h"
#import "LKProfile.h"
#import "LKPlace.h"
#import "LKPlaceView.h"

#import "UIBarButtonItem+Linkkk.h"

#import "SinaWeibo.h"

#import <QuartzCore/CALayer.h>

@interface LKMainViewController ()
{
    LKNearbyViewController *_nearbyViewController;
    LKCreateViewController *_createViewController;
    LKProfileViewController *_profileViewController;
    LKPlaceViewController *_shakeViewController;
    
    NSMutableArray *_places;
}
@end

@implementation LKMainViewController

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        _places = [NSMutableArray arrayWithCapacity:10];
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
    // TODO: only call once
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

- (void)mainViewDidShake
{
    [self performSegueWithIdentifier:@"NearbySegue" sender:nil];
}

- (void)shakeViewDidShake
{
    if (_places.count == 0) {
        [self _fetchData];
    }
    else {
        _shakeViewController.place = [_places objectAtIndex:0];
        [_places removeObjectAtIndex:0];
        [self _updateView];
    }
}

#pragma mark - Story Board

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"LoginSegue"]) {
        LKLoginViewController *loginViewController = ((LKLoginViewController *)segue.destinationViewController);
        loginViewController.sinaweibo = [self _sinaweibo];
    } else if ([segue.identifier isEqualToString:@"ProfileSegue"]) {
        LKProfileViewController *profileViewController = ((LKProfileViewController *)segue.destinationViewController);
        profileViewController.sinaweibo = [self _sinaweibo];
    } else if ([segue.identifier isEqualToString:@"NearbySegue"]) {
        _shakeViewController = ((LKPlaceViewController *)segue.destinationViewController);
        _shakeViewController.shakeDelegate = self;
        if (_places.count == 0) {
            [self _fetchData];
        }
        else {
            _shakeViewController.place = [_places objectAtIndex:0];
            [_places removeObjectAtIndex:0];
        }
    } else {
        // DO NOTHING
    }
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

- (void)_fetchData
{
    static int offset = 0;
    LKProfile *profile = [LKProfile profile];
    CLLocationCoordinate2D coord = profile.location.coordinate;
    NSString *url = [NSString stringWithFormat:@"http://map.linkkk.com/api/alpha/experience/search/?range=100&la=%f&lo=%f&limit=10&offset=%d&order_by=-score&format=json", coord.latitude, coord.longitude, offset];
    offset += 10;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         NSLog(@"Fetch data: %d", ((NSHTTPURLResponse *)response).statusCode);
         
         NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
         NSArray *array = [json objectForKey:@"objects"];
         [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
             [_places addObject:[[LKPlace alloc] initWithJSON:obj]];
         }];
         // TODO: refactor threading
         [self performSelectorOnMainThread:@selector(_updateView) withObject:nil waitUntilDone:NO];
     }];
}

- (void)_updateView
{
    if (_places.count > 0) {
        _shakeViewController.place = [_places objectAtIndex:0];
        [_places removeObjectAtIndex:0];
        [_shakeViewController updateView];
    }
}

@end
