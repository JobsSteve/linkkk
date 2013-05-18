//
//  LKProfileViewController.m
//  Linkkk
//
//  Created by Vincent Wen on 4/16/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import "LKProfileViewController.h"
#import "LKProfile.h"
#import "LKPlace.h"
#import "LKNearbyCell.h"
#import "LKPlaceViewController.h"

#import "UIViewController+Linkkk.h"
#import "UIBarButtonItem+Linkkk.h"
#import "UIColor+Linkkk.h"

#import "UIImageView+WebCache.h"

@interface LKProfileViewController ()
{
    NSMutableArray *_favPlaces;
    NSMutableArray *_myPlaces;
}
@end

@implementation LKProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = [UIBarButtonItem customBackButtonWithTarget:self action:@selector(backButtonSelected:)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem customButtonWithName:@"注销" target:self action:@selector(logoutButtonSelected:)];
    
    // Customize Seg Control
    UIFont *font = [UIFont fontWithName:@"Entypo" size:40.0];
    [_segControl setTitleTextAttributes:@{UITextAttributeFont:font, UITextAttributeTextColor:[UIColor specialBlue]} forState:UIControlStateHighlighted];
    [_segControl setTitleTextAttributes:@{UITextAttributeFont:font, UITextAttributeTextColor:[UIColor lightGrayColor]} forState:UIControlStateNormal];
    [_segControl setBackgroundImage:[UIImage imageNamed:@"profile_seg_fg"] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [_segControl setBackgroundImage:[UIImage imageNamed:@"profile_seg_bg"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [_segControl setDividerImage:[UIImage imageNamed:@"profile_seg_div"] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [_segControl addTarget:self action:@selector(_segControlDidSelect:) forControlEvents:UIControlEventValueChanged];
    
    LKProfile *profile = [LKProfile profile];
    if (profile.username == nil) {
        [profile addObserver:self forKeyPath:@"username" options:NSKeyValueObservingOptionNew context:NULL];
    } else {
        _username.text = profile.username;
        [_imageView setImageWithURL:[NSURL URLWithString:profile.avatarURL]];
    }
    
    [self _fetchFav];
    [self _fetchMine];
}

- (void)viewWillAppear:(BOOL)animated
{
    [_favTableView deselectRowAtIndexPath:[_favTableView indexPathForSelectedRow] animated:YES];
    [_myTableView deselectRowAtIndexPath:[_myTableView indexPathForSelectedRow] animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - KVO Handlers

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    dispatch_async(dispatch_get_main_queue(), ^{
        LKProfile *profile = [LKProfile profile];
        _username.text = profile.username;
        [_imageView setImageWithURL:[NSURL URLWithString:profile.avatarURL]];
    });
}

#pragma mark - Callbacks

- (void)logoutButtonSelected:(UIButton *)sender
{
    [_sinaweibo logOut];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)backButtonSelected:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)_segControlDidSelect:(UISegmentedControl *)sender
{
    _favTableView.hidden = !_favTableView.hidden;
    _myTableView.hidden = !_myTableView.hidden;
}

- (void)_fetchFav
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://map.linkkk.com/api/alpha/favourited/"]];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (data == nil || error != nil) {
            [self showErrorView:[NSString stringWithFormat:@"数据加载失败, %d:%@", ((NSHTTPURLResponse *)response).statusCode, error]];
            return;
        }
        // Parse user info
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        NSArray *array = [json objectForKey:@"objects"];
        _favPlaces = [[NSMutableArray alloc] initWithCapacity:[array count]];
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [_favPlaces addObject:[[LKPlace alloc] initWithJSON:[obj objectForKey:@"exp"]]];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_favTableView reloadData];
        });
    }];
}

- (void)_fetchMine
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://map.linkkk.com/api/alpha/experience/created/"]];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (data == nil || error != nil) {
            [self showErrorView:[NSString stringWithFormat:@"数据加载失败, %d:%@", ((NSHTTPURLResponse *)response).statusCode, error]];
            return;
        }
        // Parse user info
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        NSArray *array = [json objectForKey:@"objects"];
        _myPlaces = [[NSMutableArray alloc] initWithCapacity:[array count]];
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [_myPlaces addObject:[[LKPlace alloc] initWithJSON:obj]];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_myTableView reloadData];
        });
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _favTableView)
        return _favPlaces.count;
    // tableView == _myTableView
    return _myPlaces.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _favTableView) {
        static NSString *cellIdentifier = @"FavCell";
        LKNearbyCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[LKNearbyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.place = [_favPlaces objectAtIndex:indexPath.row];
        return cell;
    } else { // tableView == _myTableView
        static NSString *cellIdentifier = @"MyCell";
        LKNearbyCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[LKNearbyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.place = [_myPlaces objectAtIndex:indexPath.row];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _favTableView) {
        LKPlace *place = [_favPlaces objectAtIndex:indexPath.row];
        if (place.album.count == 0)
            return 100.0;
        return 196.0;
    } else { // tableView == _myTableView
        LKPlace *place = [_myPlaces objectAtIndex:indexPath.row];
        if (place.album.count == 0)
            return 100.0;
        return 196.0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    // This will create a "invisible" footer. Eliminates extra separators
    return 0.01f;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"FavPlaceSegue"]) {
        LKPlaceViewController *placeViewController = (LKPlaceViewController *)segue.destinationViewController;
        placeViewController.place = [_favPlaces objectAtIndex:[_favTableView indexPathForSelectedRow].row];
    }
    if ([segue.identifier isEqualToString:@"MyPlaceSegue"]) {
        LKPlaceViewController *placeViewController = (LKPlaceViewController *)segue.destinationViewController;
        placeViewController.place = [_myPlaces objectAtIndex:[_myTableView indexPathForSelectedRow].row];
    }
}

@end
