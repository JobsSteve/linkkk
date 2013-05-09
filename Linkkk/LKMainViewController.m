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
#import "LKNearbyViewController.h"
#import "LKCreateViewController.h"
#import "LKProfileViewController.h"

#import "LKAppDelegate.h"
#import "LKProfile.h"
#import "LKPlace.h"
#import "LKPlaceView.h"
#import "LKLoadingView.h"
#import "LKPlacePickerCell.h"

#import "UIBarButtonItem+Linkkk.h"
#import "UIViewController+Linkkk.h"
#import "UIColor+Linkkk.h"
#import "CLPlacemark+Linkkk.h"

#import "SinaWeibo.h"

#import <QuartzCore/QuartzCore.h>

@interface LKMainViewController ()
{
    LKNearbyViewController *_nearbyViewController;
    LKCreateViewController *_createViewController;
    LKProfileViewController *_profileViewController;
    LKPlaceViewController *_shakeViewController;
    LKLoginViewController *_loginViewController;
    LKSettingViewController *_settingViewController;
    UISearchBar *_searchBar;
    BOOL _isShowingSearchBar;
    
    NSMutableArray *_places;
    NSMutableArray *_results;
}
@end

@implementation LKMainViewController

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        _places = [NSMutableArray arrayWithCapacity:10];
        _results = [NSMutableArray arrayWithCapacity:10];
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
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem customButtonWithIcon:@"⚙" size:50.0 target:self action:@selector(_settingButtonSelected:)];
    
    // Custom Title
    UIButton *navButton = [UIBarButtonItem customTitleButtonWithString:@"当前：未知地址 "];
    [navButton addTarget:self action:@selector(_navButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = navButton;
    
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
    
    // Search Bar
    if (_searchBar == nil) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, -24, 320, 44)];
        _searchBar.tintColor = [UIColor whiteColor];
        _searchBar.delegate = self;
        _searchBar.placeholder = @"输入想要查询的地址...";
        [_searchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"searchbar_bg"] forState:UIControlStateNormal];
        _isShowingSearchBar = NO;
        [[[UIApplication sharedApplication] keyWindow] addSubview:_searchBar];
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

#pragma mark - Callbacks

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
        
        _tableView.hidden = NO;
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
        
        [self.view.layer addAnimation:animation1 forKey:@"animation1"];
        [self.navigationController.navigationBar.layer addAnimation:animation2 forKey:@"animation2"];
        [_searchBar.layer addAnimation:animation3 forKey:@"animation3"];
        
        _tableView.hidden = YES;
        self.navigationItem.rightBarButtonItem.customView.hidden = NO;
        [_searchBar resignFirstResponder];
    }
}

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
        NSString *name = placemark.city;
        UIButton *titleButton = (UIButton *)self.navigationItem.titleView;
        NSString *title = (placemark == nil) ? @"当前：未知地址 " : [NSString stringWithFormat:@"当前：%@ ", name];
        [titleButton setTitleWithString:title];
        
        LKPlacePickerCell *cell = (LKPlacePickerCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        if (cell != nil) {
            name = (placemark.thoroughfare == nil) ? @"" : placemark.thoroughfare;
            if (placemark.subLocality != nil) name = [name stringByAppendingFormat:@", %@", placemark.subLocality];
            if (placemark.locality != nil) name = [name stringByAppendingFormat:@", %@", placemark.locality];
            cell.subHeadingLabel.text = name;
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
    return section == 0 ? 1 : _results.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    // This will create a "invisible" footer. Eliminates extra separators
    return 0.01f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PlacePickerCell";
    LKPlacePickerCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (indexPath.section == 0) {
        cell.headingLabel.text = @"当前地址";
        cell.subHeadingLabel.text = @"未知";
        return cell;
    }
    NSArray *terms = [[_results objectAtIndex:indexPath.row] objectForKey:@"terms"];
    if (terms == nil || terms.count == 0)
        return cell;
    cell.headingLabel.text = [[terms objectAtIndex:0] objectForKey:@"value"];
    NSString *address = @"";
    if (terms.count > 1) address = [[terms objectAtIndex:1] objectForKey:@"value"];
    if (terms.count > 2) address = [address stringByAppendingFormat:@", %@", [[terms objectAtIndex:2] objectForKey:@"value"]];
    if (terms.count > 3) address = [address stringByAppendingFormat:@", %@", [[terms objectAtIndex:3] objectForKey:@"value"]];
    cell.subHeadingLabel.text = address;
    
    return cell;
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
    } else {
        LKPlacePickerCell *cell = (LKPlacePickerCell *)[tableView cellForRowAtIndexPath:indexPath];
        NSString *string = [cell.headingLabel.text stringByAppendingFormat:@", %@", cell.subHeadingLabel.text];
        NSString *title = [NSString stringWithFormat:@"当前：%@ ", cell.headingLabel.text];
        [(UIButton *)self.navigationItem.titleView setTitleWithString:title];
        [self _geocode:string];
        [self _navButtonSelected:nil];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - Search Bar Delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self _fetchCities];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
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
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         if (data == nil || error != nil) {
             [self showErrorView:[NSString stringWithFormat:@"数据加载失败, %d:%@", ((NSHTTPURLResponse *)response).statusCode, error]];
             return;
         }
         
         NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
         NSArray *array = [json objectForKey:@"objects"];
         [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
             [_places addObject:[[LKPlace alloc] initWithJSON:obj]];
         }];
         [self _updateView:loadingView];
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

- (void)_fetchCities
{
    if (_searchBar.text.length == 0)
    {
        [_results removeAllObjects];
        [self.tableView reloadData];
        return;
    }
    
    CLLocationCoordinate2D coord = [LKProfile profile].location.coordinate;
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&language=zh-CH&types=(cities)&location=%f,%f&radius=500&sensor=true&key=AIzaSyCc1TGG_Fb-er_y74L0zL8-10euOTr352k", [_searchBar.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], coord.latitude, coord.longitude];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (data == nil || error != nil) {
            [self showErrorView:[NSString stringWithFormat:@"数据加载失败, %d:%@", ((NSHTTPURLResponse *)response).statusCode, error]];
            return;
        }
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        [_results removeAllObjects];
        NSArray *predictions = [json objectForKey:@"predictions"];
        [predictions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [_results addObject:obj];
        }];
        [self.tableView reloadData];
    }];
}

- (CLLocationCoordinate2D)_geocode:(NSString *)name
{
    NSString *urlString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true", [name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSURLResponse *response;
    NSError *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (data == nil || error != nil) {
        [self showErrorView:[NSString stringWithFormat:@"数据加载失败, %d:%@", ((NSHTTPURLResponse *)response).statusCode, error]];
        return CLLocationCoordinateZero;
    }
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    NSArray *results = [json objectForKey:@"results"];
    if (results.count == 0)
        return CLLocationCoordinateZero;
    NSDictionary *location = [[[results objectAtIndex:0] objectForKey:@"geometry"] objectForKey:@"location"];
    NSLog(@"%@", location);
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([[location objectForKey:@"lat"] floatValue], [[location objectForKey:@"lng"] floatValue]);
    if (coord.latitude == 0 || coord.longitude == 0)
        return CLLocationCoordinateZero;
    return coord;
}

@end
