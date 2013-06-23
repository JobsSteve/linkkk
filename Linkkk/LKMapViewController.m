//
//  LKMapViewController.m
//  Linkkk
//
//  Created by Vincent Wen on 6/9/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import "LKMapViewController.h"
#import "LKPlaceViewController.h"
#import "LKLoadingView.h"

#import "LKPlace.h"
#import "LKProfile.h"

#import "UIBarButtonItem+Linkkk.h"
#import "UIViewController+Linkkk.h"

#import "BMapKit.h"

@interface LKMapViewController () <BMKMapViewDelegate>
{
    NSMutableDictionary *_places;
    
    BOOL _fetching;
}
@end

@implementation LKMapViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _places = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = [UIBarButtonItem customBackButtonWithTitle:@"地图" target:self action:@selector(backButtonSelected:)];
    
    // Map view setup
    _mapView.delegate = self;
    _mapView.zoomLevel = 15;
    _mapView.showsUserLocation = YES;
    _mapView.centerCoordinate = [LKProfile profile].address.geoPt;
    
    [self _fetchData:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[LKProfile profile] removeObserver:self forKeyPath:@"address"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[LKProfile profile] addObserver:self forKeyPath:@"address" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Observers

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"address"]) {
        _mapView.centerCoordinate = [LKProfile profile].address.geoPt;
        [self _fetchData:NO];
    }
}

#pragma mark - Selectors

- (void)backButtonSelected:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Map View Delegate

- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view
{
    LKPlace *annotationPlace;
    for (LKPlace *place in [_places allValues]) {
        if ([view.annotation.title isEqualToString:place.title]) {
            annotationPlace = place;
            break;
        }
    }
    if (annotationPlace) {
        LKPlaceViewController *placeViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"PlaceScene"];
        placeViewController.place = annotationPlace;
        [self.navigationController pushViewController:placeViewController animated:YES];
    }
}

- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (!_fetching) {
        [self _fetchData:YES];
    }
}

#pragma mark - Helper Functions

- (void)_fetchData:(BOOL)mapCenter
{
    _fetching = YES;
    NSLog(@"%d", _places.count);

    LKProfile *profile = [LKProfile profile];
    CLLocationCoordinate2D coord = mapCenter ? _mapView.centerCoordinate : profile.address.geoPt;
    NSString *url = [NSString stringWithFormat:@"http://www.linkkk.com/api/alpha/experience/search/?range=1&la=%f&lo=%f&limit=30&offset=0&order_by=score&format=json", coord.latitude, coord.longitude];
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
             [UIViewController showErrorView:[NSString stringWithFormat:@"数据加载失败, %d:%@", ((NSHTTPURLResponse *)response).statusCode, error]];
             return;
         }
         
         NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
         NSArray *array = [json objectForKey:@"objects"];
         [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
             if (![_places objectForKey:[obj objectForKey:@"id"]]) {
                 [_places setObject:[[LKPlace alloc] initWithJSON:obj] forKey:[obj objectForKey:@"id"]];
             }
         }];
         [self _updateMap];
     }];
}

- (void)_updateMap
{
    [_mapView removeAnnotations:[[_mapView annotations] mutableCopy]];
    
    for (LKPlace *place in [_places allValues]) {
        BMKPointAnnotation *annotation = [[BMKPointAnnotation alloc] init];
        annotation.coordinate = place.pt;
        annotation.title = place.title;
        annotation.subtitle = place.address;
        [_mapView addAnnotation:annotation];
    }
    
    _fetching = NO;
}

@end
