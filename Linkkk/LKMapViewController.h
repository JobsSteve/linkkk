//
//  LKMapViewController.h
//  Linkkk
//
//  Created by Vincent Wen on 6/9/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BMKMapView;

@interface LKMapViewController : UIViewController

@property (nonatomic, strong) IBOutlet BMKMapView *mapView;

@end
