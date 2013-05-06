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

#import "UIViewController+Linkkk.h"
#import "UIBarButtonItem+Linkkk.h"
#import "UIColor+Linkkk.h"

#import "UIImageView+WebCache.h"

@interface LKProfileViewController ()
{
    NSMutableArray *_places;
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
    
    LKProfile *profile = [LKProfile profile];
    if (profile.username == nil) {
        [profile addObserver:self forKeyPath:@"username" options:NSKeyValueObservingOptionNew context:NULL];
    } else {
        _username.text = profile.username;
        [_imageView setImageWithURL:[NSURL URLWithString:profile.avatarURL]];
    }
    
    [self _fetchFav];
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
        _places = [[NSMutableArray alloc] initWithCapacity:[array count]];
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [_places addObject:[[LKPlace alloc] initWithJSON:[obj objectForKey:@"exp"]]];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_favTableView reloadData];
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
    return _places.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"FavCell";
    LKNearbyCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[LKNearbyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.place = [_places objectAtIndex:indexPath.row];
    
    return cell;
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

@end
