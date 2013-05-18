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
#import "UIColor+Linkkk.h"

#import "BMapKit.h"

#import <QuartzCore/CALayer.h>

@interface LKNearbyViewController ()
{
    int _selectedRow;
    NSMutableArray *_places;
    
    BOOL _hasMore;
    int _offset;
    
    UITableViewCell *_loadCell;
    UILabel *_loadLabel;
    UIActivityIndicatorView *_loadSpinner;
}
@end

@implementation LKNearbyViewController

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _hasMore = YES;
        _places = [NSMutableArray arrayWithCapacity:10];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return _places.count;
    // section == 1
    if (_places.count == 0 || !_hasMore) // When there is nothing, do not display "load more"
        return 0;
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (indexPath.section == 0) {
        static NSString *cellIdentifier = @"NearbyCell";
        LKNearbyCell *nearbyCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        nearbyCell.place = [_places objectAtIndex:indexPath.row];
        cell = nearbyCell;
    } else if (indexPath.section == 1) {
        if (_loadCell == nil) {
            _loadCell = [[UITableViewCell alloc] init];
            _loadCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            _loadLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 15, 200, 50)];
            _loadLabel.textColor = [UIColor specialBlue];
            _loadLabel.font = [UIFont boldSystemFontOfSize:18.0];
            _loadLabel.text = @"加载更多";
            [_loadCell addSubview:_loadLabel];
            
            _loadSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            _loadSpinner.color = [UIColor specialBlue];
            _loadSpinner.center = CGPointMake(155, 38);
            [_loadCell addSubview:_loadSpinner];
        }
        cell = _loadCell;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) // Load more cell
        return 80.0;
    LKPlace *place = [_places objectAtIndex:indexPath.row];
    if (place.album.count == 0)
        return 100.0;
    return 196.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    // This will create a "invisible" footer. Eliminates extra separators
    return 0.01f;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) { // load more cell
        [self _fetchData];
    }
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
    CLLocationCoordinate2D coord = profile.address.geoPt;
    NSString *url = [NSString stringWithFormat:@"http://map.linkkk.com/api/alpha/experience/search/?range=10&la=%f&lo=%f&limit=10&offset=%d&order_by=-score&format=json", coord.latitude, coord.longitude, _offset];
    _offset += 10;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    LKLoadingView *loadingView = [[LKLoadingView alloc] init];
    [self.view addSubview:loadingView];
    if (_loadCell != nil) {
        _loadLabel.hidden = YES;
        [_loadSpinner startAnimating];
        _loadCell.userInteractionEnabled = NO;
    }
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
    {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [loadingView removeFromSuperview];
        if (_loadCell != nil) {
            _loadLabel.hidden = NO;
            [_loadSpinner stopAnimating];
            _loadCell.userInteractionEnabled = YES;
        }
        
        if (data == nil || error != nil) {
            [self showErrorView:[NSString stringWithFormat:@"数据加载失败, %d:%@", ((NSHTTPURLResponse *)response).statusCode, error]];
            return;
        }
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        NSArray *array = [json objectForKey:@"objects"];
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [_places addObject:[[LKPlace alloc] initWithJSON:obj]];
        }];
        if (array.count == 0)
            _hasMore = NO;
        [self.tableView reloadData];
    }];
}

@end
