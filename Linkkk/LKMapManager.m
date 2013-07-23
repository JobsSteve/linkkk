//
//  LKMapManager.m
//  Linkkk
//
//  Created by Vincent Wen on 5/9/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import "LKMapManager.h"
#import "LKProfile.h"
#import "BMapKit.h"

@interface LKMapManager () <BMKSearchDelegate>
{
    BMKSearch *_search;
    void (^_reverseGeocodeHandler)(BMKAddrInfo *, int error);
    void (^_suggestionHandler)(BMKSuggestionResult *);
    void (^_poiNearbyHandler)(NSArray *);
    void (^_driveSearchHandler)(BMKPlanResult *);
}

@end

@implementation LKMapManager

+ (LKMapManager *)sharedInstance
{
    static LKMapManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)initSearch
{
    _search = [[BMKSearch alloc] init];
    _search.delegate = self;
}

- (void)suggestionSearch:(NSString *)string withCompletionHandler:(void (^)(BMKSuggestionResult *))block
{
    _suggestionHandler = block;
    [_search suggestionSearch:string];
}

- (void)reverseGeocode:(CLLocationCoordinate2D)coordinate withCompletionHandler:(void (^)(BMKAddrInfo *, int error))block
{
    _reverseGeocodeHandler = block;
    [_search reverseGeocode:coordinate];
}

- (void)poiSearchNearby:(NSString *)string withCompletionHandler:(void (^)(NSArray *))block;
{
    _poiNearbyHandler = block;
    [_search poiSearchNearBy:string center:[LKProfile profile].address.geoPt radius:1000000 pageIndex:0];
}

- (void)drivingSearchFrom:(CLLocationCoordinate2D)from to:(CLLocationCoordinate2D)to withCompletionHandler:(void (^)(BMKPlanResult *))block
{
    _driveSearchHandler = block;
	BMKPlanNode *start = [[BMKPlanNode alloc] init];
	start.pt = from;
	BMKPlanNode *end = [[BMKPlanNode alloc] init];
	end.pt = to;
    [_search drivingSearch:nil startNode:start endCity:nil endNode:end];
}

#pragma mark Delegates

- (void)onGetSuggestionResult:(BMKSuggestionResult *)result errorCode:(int)error
{
    if (error) {
        NSLog(@"ERROR: Baidu Maps onGetSuggestionResult %d", error);
        return;
    }
    _suggestionHandler(result);
}

- (void)onGetAddrResult:(BMKAddrInfo *)result errorCode:(int)error
{
    if (error) {
        NSLog(@"ERROR: Baidu Maps onGetAddrResult %d, %@", error, result);
    }
    _reverseGeocodeHandler(result, error);
}

- (void)onGetPoiResult:(NSArray *)poiResultList searchType:(int)type errorCode:(int)error
{
    if (error) {
        NSLog(@"ERROR: Baidu Maps onGetPoiResult %d", error);
        return;
    }
    _poiNearbyHandler([[poiResultList objectAtIndex:0] poiInfoList]);
}

- (void)onGetDrivingRouteResult:(BMKPlanResult *)result errorCode:(int)error
{
    if (error) {
        NSLog(@"ERROR: Baidu Maps onGetDrivingRouteResult %d", error);
        return;
    }
    _driveSearchHandler(result);
}

@end
