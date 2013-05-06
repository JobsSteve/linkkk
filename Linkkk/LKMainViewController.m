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
#import "LKLoadingView.h"

#import "UIBarButtonItem+Linkkk.h"

#import "SinaWeibo.h"

#import <QuartzCore/CALayer.h>

@interface LKMainViewController ()
{
    LKNearbyViewController *_nearbyViewController;
    LKCreateViewController *_createViewController;
    LKProfileViewController *_profileViewController;
    LKPlaceViewController *_shakeViewController;
    LKLoginViewController *_loginViewController;
    
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
    LKProfile *profile = [LKProfile profile];
    [profile addObserver:self forKeyPath:@"placemark" options:NSKeyValueObservingOptionNew context:NULL];
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
    [self performSegueWithIdentifier:@"ShakeSegue" sender:nil];
}

- (void)shakeViewDidShake
{
    // TODO: update bottom controls (fav)
    if (_places.count == 0) {
        [self _fetchData];
    }
    else {
        [self _updateView:nil];
    }
}

#pragma mark - Story Board

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"LoginSegue"]) {
        _loginViewController = ((LKLoginViewController *)segue.destinationViewController);
        _loginViewController.sinaweibo = [self _sinaweibo];
    } else if ([segue.identifier isEqualToString:@"ProfileSegue"]) {
        LKProfileViewController *profileViewController = ((LKProfileViewController *)segue.destinationViewController);
        profileViewController.sinaweibo = [self _sinaweibo];
    } else if ([segue.identifier isEqualToString:@"ShakeSegue"]) {
        _shakeViewController = ((LKPlaceViewController *)segue.destinationViewController);
        _shakeViewController.shakeDelegate = self;
        [_shakeViewController view];
        [self shakeViewDidShake];
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

- (IBAction)createButtonSelected:(id)sender
{
    if (_createViewController == nil) {
        _createViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"CreateScene"];
    }
    
    [self.navigationController pushViewController:_createViewController animated:YES];
}

#pragma mark - KVO Handlers

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"placemark"]) {
        CLPlacemark *placemark = [LKProfile profile].placemark;
        NSString *name = placemark.locality;
        if (name == nil) name = placemark.subLocality;
        if (name == nil) name = placemark.subAdministrativeArea;
        if (name == nil) name = placemark.administrativeArea;
        UILabel *titleLabel = (UILabel *)self.navigationItem.titleView;
        if (placemark == nil)
            titleLabel.text = @"当前：未知地址";
        else
            titleLabel.text = [NSString stringWithFormat:@"当前：%@", name];
        [titleLabel sizeToFit];
    }
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
    [self _restoreButtons];
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
    [self _restoreButtons];
}

#pragma mark - Helper Functions

- (void)_dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_restoreButtons
{
    _loginViewController.spinner.hidden = YES;
    _loginViewController.loginButton.enabled = YES;
}

// Linkkk login
- (void)_login
{
    LKProfile *profile = [LKProfile profile];
    [profile login];
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
    _shakeViewController.placeView.hidden = YES;
    LKLoadingView *loadingView = [[LKLoadingView alloc] init];
    [_shakeViewController.view addSubview:loadingView];
    
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
         [self performSelectorOnMainThread:@selector(_updateView:) withObject:loadingView waitUntilDone:NO];
     }];
}

- (void)_updateView:(UIView *)loadingView
{
    _shakeViewController.placeView.hidden = NO;
    [loadingView removeFromSuperview];
    
    if (_places.count > 0) {
        _shakeViewController.place = [_places objectAtIndex:0];
        [_places removeObjectAtIndex:0];
        [_shakeViewController updateView];
    }
}

@end
