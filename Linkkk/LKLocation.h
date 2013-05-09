//
//  LKLocation.h
//  Linkkk
//
//  Created by Vincent Wen on 5/8/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface LKLocation : NSObject

@property (assign, nonatomic) CLLocationCoordinate2D coord;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *address;

@end
