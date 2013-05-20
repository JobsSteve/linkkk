//
//  LKPlaceCell.h
//  Linkkk
//
//  Created by Vincent Wen on 4/16/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LKPlace;

@interface LKNearbyCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet UILabel *userLabel;
@property (strong, nonatomic) IBOutlet UILabel *favLabel;
@property (strong, nonatomic) IBOutlet UILabel *heartLabel;
@property (strong, nonatomic) IBOutlet UIImageView *photoView1;
@property (strong, nonatomic) IBOutlet UIImageView *photoView2;
@property (strong, nonatomic) IBOutlet UIImageView *photoView3;

@property (strong, nonatomic) LKPlace *place;

@end
