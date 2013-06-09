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
#import "LKSettingViewController.h"
#import "LKPlaceViewController.h"
#import "LKMapViewController.h"
#import "LKNearbyViewController.h"
#import "LKCreateViewController.h"
#import "LKProfileViewController.h"

#import "LKAppDelegate.h"
#import "LKProfile.h"
#import "LKMapManager.h"
#import "LKPlace.h"
#import "LKPlaceView.h"
#import "LKLoadingView.h"
#import "LKPlacePickerCell.h"

#import "UIButton+Linkkk.h"
#import "UIBarButtonItem+Linkkk.h"
#import "UIViewController+Linkkk.h"
#import "UIColor+Linkkk.h"
#import "CLPlacemark+Linkkk.h"

#import "SinaWeibo.h"
#import "BMapKit.h"

#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>

@interface LKMainViewController () <UIGestureRecognizerDelegate>
{
    LKNearbyViewController *_nearbyViewController;
    LKCreateViewController *_createViewController;
    LKProfileViewController *_profileViewController;
    LKPlaceViewController *_shakeViewController;
    LKLoginViewController *_loginViewController;
    LKSettingViewController *_settingViewController;
    UISearchBar *_searchBar;
    BOOL _isShowingSearchBar;
    
    NSArray *_results;
    
    int _shakeOffset;
    
    LKLoadingView *_loadingView;
}
@end

@implementation LKMainViewController

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        [LKProfile profile];
        [LKMapManager sharedInstance];
        
        _loadingView = [[LKLoadingView alloc] init];
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
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem customButtonWithIcon:@"" size:50.0 target:self action:@selector(_mapButtonSelected:)];
    
    // Custom Title
    UIButton *navButton = [UIBarButtonItem customTitleButtonWithString:@"当前：未知地址 " target:self action:@selector(_navButtonSelected:)];
    self.navigationItem.titleView = navButton;
    
    // Custom fonts
    _nearbyButton.titleLabel.font = [UIFont fontWithName:@"Entypo" size:70.0];
    _createButton.titleLabel.font = [UIFont fontWithName:@"Entypo" size:70.0];
    _profileButton.titleLabel.font = [UIFont fontWithName:@"Entypo" size:70.0];
    
    // Touch to dismiss
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_navButtonSelected:)];
    gesture.delegate = self;
    [_tableView addGestureRecognizer:gesture];
    
    // Update Location
    LKProfile *profile = [LKProfile profile];
    [profile addObserver:self forKeyPath:@"address" options:NSKeyValueObservingOptionNew context:NULL];
    
    // Register App Resign
    LKAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate addObserver:self forKeyPath:@"resignActiveNotifier" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![self _sinaweibo].isAuthValid)
        [self performSegueWithIdentifier:@"LoginSegue" sender:self];
    else {
        [self _login];
    }
    
    // Search Bar
    if (_searchBar == nil) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, -24, 320, 44)];
        _searchBar.tintColor = [UIColor whiteColor];
        _searchBar.delegate = self;
        _searchBar.hidden = YES;
        _searchBar.placeholder = @"输入想要查询的地址...";
        [_searchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"searchbar_bg"] forState:UIControlStateNormal];
        _isShowingSearchBar = NO;
        [[[UIApplication sharedApplication] keyWindow] addSubview:_searchBar];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Shake View Delegate

- (void)mainViewDidShake
{
    [self shakeViewDidShake];
}

- (void)shakeViewDidShake
{
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    [self _fetchData];
}

#pragma mark - Create View Delegate

- (void)hasCreated
{
    _createViewController = nil;
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
    } else {
        // DO NOTHING
    }
}

#pragma mark - Callbacks

- (IBAction)shakeButtonSelected:(id)sender
{
    [self mainViewDidShake];
}

- (void)_mapButtonSelected:(UIButton *)sender
{
    LKMapViewController *controller = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"MapScene"];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)_settingButtonSelected:(id)sender
{
    if (_settingViewController == nil) {
        _settingViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"SettingScene"];
    }
    
    [self.navigationController pushViewController:_settingViewController animated:YES];
}

- (void)_navButtonSelected:(id)sender
{
    _isShowingSearchBar = !_isShowingSearchBar;
    
    if (_isShowingSearchBar) {
        CABasicAnimation *animation1 = [CABasicAnimation animationWithKeyPath:@"position"];
        CGPoint position = self.view.layer.position;
        animation1.fromValue = [NSValue valueWithCGPoint:position];
        position.y += 44;
        animation1.toValue = [NSValue valueWithCGPoint:position];
        self.view.layer.position = position;
        animation1.duration = 0.2;
        
        CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"position"];
        position = self.navigationController.navigationBar.layer.position;
        animation2.fromValue = [NSValue valueWithCGPoint:position];
        position.y += 44;
        animation2.toValue = [NSValue valueWithCGPoint:position];
        self.navigationController.navigationBar.layer.position = position;
        animation2.duration = 0.2;
        
        CABasicAnimation *animation3 = [CABasicAnimation animationWithKeyPath:@"position"];
        position = _searchBar.layer.position;
        animation3.fromValue = [NSValue valueWithCGPoint:position];
        position.y += 44;
        animation3.toValue = [NSValue valueWithCGPoint:position];
        _searchBar.layer.position = position;
        animation3.duration = 0.2;
        
        [self.view.layer addAnimation:animation1 forKey:@"animation1"];
        [self.navigationController.navigationBar.layer addAnimation:animation2 forKey:@"animation2"];
        [_searchBar.layer addAnimation:animation3 forKey:@"animation3"];
        
        UIButton *titleButton = (UIButton *)self.navigationItem.titleView;
        NSString *title = [titleButton.titleLabel.text substringToIndex:titleButton.titleLabel.text.length-1];
        [titleButton setTitleWithString:[title stringByAppendingString:@""]];
        
        _tableView.hidden = NO;
        _searchBar.hidden = NO;
        self.navigationItem.rightBarButtonItem.customView.hidden = YES;
        [_searchBar becomeFirstResponder];
    } else {
        CABasicAnimation *animation1 = [CABasicAnimation animationWithKeyPath:@"position"];
        CGPoint position = self.view.layer.position;
        animation1.fromValue = [NSValue valueWithCGPoint:position];
        position.y -= 44;
        animation1.toValue = [NSValue valueWithCGPoint:position];
        self.view.layer.position = position;
        animation1.duration = 0.2;
        
        CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"position"];
        position = self.navigationController.navigationBar.layer.position;
        animation2.fromValue = [NSValue valueWithCGPoint:position];
        position.y -= 44;
        animation2.toValue = [NSValue valueWithCGPoint:position];
        self.navigationController.navigationBar.layer.position = position;
        animation2.duration = 0.2;
        
        CABasicAnimation *animation3 = [CABasicAnimation animationWithKeyPath:@"position"];
        position = _searchBar.layer.position;
        animation3.fromValue = [NSValue valueWithCGPoint:position];
        position.y -= 44;
        animation3.toValue = [NSValue valueWithCGPoint:position];
        _searchBar.layer.position = position;
        animation3.duration = 0.2;
        animation3.delegate = self;
        
        [self.view.layer addAnimation:animation1 forKey:@"animation1"];
        [self.navigationController.navigationBar.layer addAnimation:animation2 forKey:@"animation2"];
        [_searchBar.layer addAnimation:animation3 forKey:@"animation3"];
        
        UIButton *titleButton = (UIButton *)self.navigationItem.titleView;
        NSString *title = [titleButton.titleLabel.text substringToIndex:titleButton.titleLabel.text.length-1];
        [titleButton setTitleWithString:[title stringByAppendingString:@""]];
        
        _tableView.hidden = YES;
        self.navigationItem.rightBarButtonItem.customView.hidden = NO;
        [_searchBar resignFirstResponder];
    }
}

- (IBAction)nearbyButtonSelected:(id)sender
{
    _nearbyViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"NearbyScene"];
    
    [self.navigationController pushViewController:_nearbyViewController animated:YES];
}

- (IBAction)createButtonSelected:(id)sender
{
    if (_createViewController == nil) {
        _createViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"CreateScene"];
        _createViewController.delegate = self;
    }
    
    [self.navigationController pushViewController:_createViewController animated:YES];
}

#pragma mark - Gesture Delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // If the view that is touched is not the view associated with this view's table view, but
    // is one of the sub-views, we should not recognize the touch.
    if (touch.view != _tableView && [touch.view isDescendantOfView:_tableView]) {
        return NO;
    }
    return YES;
}

#pragma mark - Animation Delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    _searchBar.hidden = YES;
}

#pragma mark - KVO Handlers

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"address"]) {
        // Navigation bar
        BMKAddrInfo *address = [LKProfile profile].address;
        UIButton *titleButton = (UIButton *)self.navigationItem.titleView;
        NSString *name = address.addressComponent.streetName;
        if (name == nil) name = address.addressComponent.district;
        NSString *prefix = ([LKProfile profile].current == address) ? @"当前" : @"设定";
        NSString *title = [NSString stringWithFormat:@"%@：%@ ", prefix, name];
        [titleButton setTitleWithString:title];
        
        LKPlacePickerCell *cell = (LKPlacePickerCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        if (cell != nil) {
            cell.headingLabel.text = @"当前位置";
            cell.subHeadingLabel.text = [LKProfile profile].current.strAddr;
        }
        
        // Shakeview controller
        _shakeOffset = 0;
    } else if ([keyPath isEqualToString:@"resignActiveNotifier"]) {
        if (_isShowingSearchBar) {
            [self _navButtonSelected:nil];
        }
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1)
        return _results.count;
    if (_searchBar.text.length == 0 /* && section == 0 */)
        return 1; // show current
    return 0; // show nothing when user starts the search
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    // FIX: eliminates extra separators
    return 0.01f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PlacePickerCell";
    LKPlacePickerCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (indexPath.section == 0) {
        cell.headingLabel.text = @"当前位置";
        cell.subHeadingLabel.text = [LKProfile profile].current.strAddr;
        return cell;
    }
    BMKPoiInfo *poi = [_results objectAtIndex:indexPath.row];
    cell.headingLabel.text = poi.name;
    cell.subHeadingLabel.text = poi.address;
    
    return cell;
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LKProfile *profile = [LKProfile profile];
    if (indexPath.section == 0) {
        profile.address = profile.current;
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self _navButtonSelected:nil];
    } else {
        BMKPoiInfo *poi = (BMKPoiInfo *)[_results objectAtIndex:indexPath.row];
        [[LKMapManager sharedInstance] reverseGeocode:poi.pt withCompletionHandler:^(BMKAddrInfo *address, int error) {
            profile.address = address;
        }];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self _navButtonSelected:nil];
    }
}

#pragma mark - Search Bar Delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length == 0)
    {
        _results = nil;
        [self.tableView reloadData];
        return;
    }
    
    [[LKMapManager sharedInstance] poiSearchNearby:searchText withCompletionHandler:^(NSArray *results) {
        _results = results;
        [self.tableView reloadData];
    }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    // FIX: avoid showing what's under the tableview
    // [searchBar resignFirstResponder];
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
    static BOOL fetching = NO;
    NSLog(@"fetching %d", fetching);
    if (fetching)
        return;
    fetching = YES;
    
    LKProfile *profile = [LKProfile profile];
    CLLocationCoordinate2D coord = profile.address.geoPt;
    NSString *url = [NSString stringWithFormat:@"http://map.linkkk.com/api/alpha/experience/shake/?la=%f&lo=%f&limit=1&offset=%d&format=json", coord.latitude, coord.longitude, _shakeOffset++];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.navigationController.visibleViewController.view addSubview:_loadingView];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         [_loadingView removeFromSuperview];
         if (data == nil || error != nil) {
             [UIViewController showErrorView:[NSString stringWithFormat:@"数据加载失败, %d:%@", ((NSHTTPURLResponse *)response).statusCode, error]];
             return;
         }
         
         NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
         NSArray *array = [json objectForKey:@"objects"];
         if (array.count > 0) {
             LKPlace *place = [[LKPlace alloc] initWithJSON:[array objectAtIndex:0]];
             _shakeViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"PlaceScene"];
             _shakeViewController.shakeDelegate = self;
             _shakeViewController.place = place;
             _shakeViewController.navigationItem.rightBarButtonItem = [UIBarButtonItem customButtonWithImage:[UIImage imageNamed:@"shake_normal"] target:self action:@selector(shakeViewDidShake)];
             if (self.navigationController.visibleViewController == self) {
                 [self.navigationController pushViewController:_shakeViewController animated:YES];
             } else {
                 [self.navigationController popToViewController:self animated:NO];
                 [self.navigationController pushViewController:_shakeViewController animated:NO];
             }
         }
         fetching = NO;
     }];
}

@end
