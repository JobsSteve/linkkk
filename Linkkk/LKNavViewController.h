//
//  LKNavViewController.h
//  Linkkk
//
//  Created by Vincent Wen on 5/10/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class BMKMapView;

@interface LKNavViewController : UIViewController

@property (strong, nonatomic) IBOutlet BMKMapView *mapView;

@property (assign, nonatomic) CLLocationCoordinate2D from;
@property (assign, nonatomic) CLLocationCoordinate2D to;

@end
