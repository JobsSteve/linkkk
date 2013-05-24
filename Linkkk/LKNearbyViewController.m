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
#import "LKLoadingView.h"
#import "LKDropDownOptionsView.h"

#import "LKPlace.h"
#import "LKProfile.h"
#import "LKDefaults.h"

#import "UIBarButtonItem+Linkkk.h"
#import "UIViewController+Linkkk.h"
#import "UIColor+Linkkk.h"

#import "BMapKit.h"

#import <QuartzCore/QuartzCore.h>

static NSString * const kDistanceOptions[] = {
    @"1公里内", @"2公里内", @"5公里内", @"10公里内"
};

static NSString * const kSortByOptions[] = {
    @"距离最近的", @"最多喜欢的", @"最多评论的", @"最近更新的"
};

@interface LKNearbyViewController () <BMKMapViewDelegate>
{
    int _selectedRow;
    NSMutableArray *_places;
    
    BOOL _hasMore;
    int _offset;
    
    UITableViewCell *_loadCell;
    UILabel *_loadLabel;
    UIActivityIndicatorView *_loadSpinner;
    
    LKDropDownOptionsView *_sortingView;
    LKDropDownOptionsView *_distanceView;
    UIView *_overlayView;
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
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem customBackButtonWithTitle:@"附近" target:self action:@selector(backButtonSelected:)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem customButtonWithIcon:@"" size:50.0 target:self action:@selector(mapButtonSelected:)];
    
    _sortLabel.font = [UIFont fontWithName:@"Entypo" size:30.0];
    _distLabel.font = [UIFont fontWithName:@"Entypo" size:30.0];
    [_sortButton setTitle:kSortByOptions[[LKDefaults sortBy]] forState:UIControlStateNormal];
    [_sortButton setTitle:kSortByOptions[[LKDefaults sortBy]] forState:UIControlStateHighlighted];
    [_distButton setTitle:kDistanceOptions[[LKDefaults distance]] forState:UIControlStateNormal];
    [_distButton setTitle:kDistanceOptions[[LKDefaults distance]] forState:UIControlStateHighlighted];
    
    // Filters
    _overlayView = [[UIView alloc] initWithFrame:self.tableView.frame];
    _overlayView.backgroundColor = [UIColor whiteColor];
    _overlayView.alpha = 0.5;
    _overlayView.hidden = YES;
    [_overlayView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(overlaySelected)]];
    [self.tableView insertSubview:_overlayView belowSubview:self.tableView.tableHeaderView];
    
    _distanceView = [[LKDropDownOptionsView alloc] initWithOptions:@[@"1公里内", @"2公里内", @"5公里内", @"10公里内"] type:LKFilterTypeDistance];
    _distanceView.delegate = self;
    [self.tableView insertSubview:_distanceView belowSubview:self.tableView.tableHeaderView];
    
    _sortingView = [[LKDropDownOptionsView alloc] initWithOptions:@[@"距离最近的", @"最多喜欢的", @"最多评论的", @"最近更新的"] type:LKFilterTypeSortBy];
    _sortingView.delegate = self;
    [self.tableView insertSubview:_sortingView belowSubview:self.tableView.tableHeaderView];
    
    // Map view setup
    _mapView.delegate = self;
    _mapView.zoomLevel = 14;
    
    // Fetch Data
    [self _fetchData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
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
        return 110.0;
    return 214.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    // This will create a "invisible" footer. Eliminates extra separators
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01f;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) { // load more cell
        [self _fetchData];
    }
}

#pragma mark - Map View Delegate

- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{
    LKPlace *annotationPlace;
    for (LKPlace *place in _places) {
        if ([view.annotation.title isEqualToString:place.title]) {
            annotationPlace = place;
            break;
        }
    }
//    for (UIView *view in [[[_mapView subviews] objectAtIndex:0] subviews]) {
//        if ([[[view class] description] isEqualToString:@"ActionPaopaoView"])
//            view.backgroundColor = [UIColor redColor];
//    }
    if (annotationPlace) {
        LKPlaceViewController *placeViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"PlaceScene"];
        placeViewController.place = annotationPlace;
        [self.navigationController pushViewController:placeViewController animated:YES];
    }
}

#pragma mark - Callbacks

- (void)dropDownOptionDidSelect:(int)option type:(int)type
{
    _overlayView.hidden = YES;
    if (type == LKFilterTypeSortBy) {
        [_sortButton setTitle:kSortByOptions[option] forState:UIControlStateNormal];
        [_sortButton setTitle:kSortByOptions[option] forState:UIControlStateHighlighted];
    }
    if (type == LKFilterTypeDistance) {
        [_distButton setTitle:kDistanceOptions[option] forState:UIControlStateNormal];
        [_distButton setTitle:kDistanceOptions[option] forState:UIControlStateHighlighted];
    }
    // Clear and fetch data
    _offset = 0;
    _hasMore = YES;
    [_places removeAllObjects];
    [self.tableView reloadData];
    [self _fetchData];
}

- (void)distanceButtonSelected:(UIButton *)sender
{
    if (_distanceView.alpha == 1.0) {
        [_distanceView animateOut];
        _overlayView.hidden = YES;
    } else {
        [_distanceView animateIn];
        _overlayView.hidden = NO;
    }
    
    if (_sortingView.alpha == 1.0) {
        [_sortingView animateOut];
    }
}

- (void)sortingButtonSelected:(UIButton *)sender
{
    if (_sortingView.alpha == 1.0) {
        [_sortingView animateOut];
        _overlayView.hidden = YES;
    } else {
        [_sortingView animateIn];
        _overlayView.hidden = NO;
    }
    
    if (_distanceView.alpha == 1.0) {
        [_distanceView animateOut];
    }
}

- (void)overlaySelected
{
    if (_distanceView.alpha == 1.0) {
        [_distanceView animateOut];
    }
    if (_sortingView.alpha == 1.0) {
        [_sortingView animateOut];
    }
    _overlayView.hidden = YES;
}

- (void)mapButtonSelected:(UIButton *)sender
{
    [UIView transitionFromView:_tableView toView:_mapView duration:0.7 options:UIViewAnimationOptionTransitionFlipFromRight completion:nil];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem customButtonWithIcon:@"☰" size:50.0 target:self action:@selector(listButtonSelected:)];
}

- (void)listButtonSelected:(UIButton *)sender
{
    [UIView transitionFromView:_mapView toView:_tableView duration:0.7 options:UIViewAnimationOptionTransitionFlipFromRight completion:nil];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem customButtonWithIcon:@"" size:50.0 target:self action:@selector(mapButtonSelected:)];
}

- (void)backButtonSelected:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Helper Functions

static const int kDistances[] = {1, 2, 5, 10};
static NSString * const kSortBy[] = {@"distance", @"score", @"comment", @"modified"};

- (void)_fetchData
{
    LKProfile *profile = [LKProfile profile];
    CLLocationCoordinate2D coord = profile.address.geoPt;
    NSString *url = [NSString stringWithFormat:@"http://map.linkkk.com/api/alpha/experience/search/?range=%d&la=%f&lo=%f&limit=10&offset=%d&order_by=%@&format=json", kDistances[[LKDefaults distance]], coord.latitude, coord.longitude, _offset, kSortBy[[LKDefaults sortBy]]];
    NSLog(@"Fetch data url: %@", url);
    _offset += 10;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    LKLoadingView *loadingView = [[LKLoadingView alloc] init];
    [self.view addSubview:loadingView];
    _distButton.enabled = NO;
    _sortButton.enabled = NO;
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
        _distButton.enabled = YES;
        _sortButton.enabled = YES;
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
        [self _updateMap];
    }];
}

- (void)_updateMap
{
    _mapView.showsUserLocation = YES;
    _mapView.centerCoordinate = [LKProfile profile].address.geoPt;
    
    for (LKPlace *place in _places) {
        BMKPointAnnotation *annotation = [[BMKPointAnnotation alloc] init];
        annotation.coordinate = place.pt;
        annotation.title = place.title;
        annotation.subtitle = place.address;
        [_mapView addAnnotation:annotation];
    }
}

@end
