//
//  LKMapManager.h
//  Linkkk
//
//  Created by Vincent Wen on 5/9/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class BMKAddrInfo;
@class BMKSuggestionResult;

@interface LKMapManager : NSObject

+ (LKMapManager *)sharedInstance;
- (void)initSearch;
- (void)suggestionSearch:(NSString *)string withCompletionHandler:(void (^)(BMKSuggestionResult *))block;
- (void)reverseGeocode:(CLLocationCoordinate2D)coordinate withCompletionHandler:(void (^)(BMKAddrInfo *))block;
- (void)poiSearchNearby:(NSString *)string withCompletionHandler:(void (^)(NSArray *))block;

@end
