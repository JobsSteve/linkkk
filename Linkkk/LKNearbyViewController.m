//
//  LKNearbyViewController.m
//  Linkkk
//
//  Created by Vincent Wen on 4/16/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import "LKNearbyViewController.h"
#import "LKNearbyCell.h"
#import "LKPlaceViewController.h"
#import "LKPlace.h"
#import "LKProfile.h"
#import "LKLoadingView.h"

#import "UIBarButtonItem+Linkkk.h"
#import "UIViewController+Linkkk.h"

#import <QuartzCore/CALayer.h>

@interface LKNearbyViewController ()
{
    int _selectedRow;
    NSMutableArray *_places;
}
@end

@implementation LKNearbyViewController

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem customBackButtonWithTarget:self action:@selector(backButtonSelected:)];
    
    [self _fetchData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    LKPlaceViewController *viewController = [segue destinationViewController];
    viewController.place = [_places objectAtIndex:[self.tableView indexPathForSelectedRow].row];
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
    static NSString *cellIdentifier = @"NearbyCell";
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

#pragma mark - Callbacks

- (void)backButtonSelected:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Helper Functions

- (void)_fetchData
{
    LKProfile *profile = [LKProfile profile];
    CLLocationCoordinate2D coord = profile.location.coordinate;
    NSString *url = [NSString stringWithFormat:@"http://map.linkkk.com/api/alpha/experience/search/?range=10&la=%f&lo=%f&limit=10&offset=0&order_by=-score&format=json", coord.latitude, coord.longitude];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    LKLoadingView *loadingView = [[LKLoadingView alloc] init];
    [self.view addSubview:loadingView];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
    {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [loadingView removeFromSuperview];
        
        if (data == nil || error != nil) {
            [self showErrorView:[NSString stringWithFormat:@"数据加载失败, %d:%@", ((NSHTTPURLResponse *)response).statusCode, error]];
            return;
        }
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        NSArray *array = [json objectForKey:@"objects"];
        _places = [[NSMutableArray alloc] initWithCapacity:[array count]];
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [_places addObject:[[LKPlace alloc] initWithJSON:obj]];
        }];
        [self.tableView reloadData];
    }];
}

@end
