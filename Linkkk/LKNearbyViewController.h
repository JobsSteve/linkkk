//
//  LKNearbyViewController.h
//  Linkkk
//
//  Created by Vincent Wen on 4/16/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LKDropDownOptionsDelegate <NSObject>
- (void)dropDownOptionDidSelect:(int)option type:(int)type;
@end

@interface LKNearbyViewController : UITableViewController <LKDropDownOptionsDelegate>

@property (nonatomic, strong) IBOutlet UIButton *sortButton;
@property (nonatomic, strong) IBOutlet UIButton *distButton;
@property (nonatomic, strong) IBOutlet UILabel *sortLabel;
@property (nonatomic, strong) IBOutlet UILabel *distLabel;

- (IBAction)distanceButtonSelected:(UIButton *)sender;
- (IBAction)sortingButtonSelected:(UIButton *)sender;

@end
