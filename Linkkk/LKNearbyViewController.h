//
//  LKNearbyViewController.h
//  Linkkk
//
//  Created by Vincent Wen on 4/16/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BMKMapView;

@protocol LKDropDownOptionsDelegate <NSObject>
- (void)dropDownOptionDidSelect:(int)option type:(int)type;
@end

@interface LKNearbyViewController : UIViewController <LKDropDownOptionsDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UIButton *sortButton;
@property (nonatomic, strong) IBOutlet UIButton *distButton;
@property (nonatomic, strong) IBOutlet UILabel *sortLabel;
@property (nonatomic, strong) IBOutlet UILabel *distLabel;

@property (nonatomic, strong) IBOutlet UIView *containerView;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet BMKMapView *mapView;

- (IBAction)distanceButtonSelected:(UIButton *)sender;
- (IBAction)sortingButtonSelected:(UIButton *)sender;

@end
