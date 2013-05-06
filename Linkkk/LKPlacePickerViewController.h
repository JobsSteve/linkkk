//
//  LKPlacePickerViewController.h
//  Linkkk
//
//  Created by Vincent Wen on 5/6/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LKPlacePickerViewController : UITableViewController <UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) UILabel *placemarkLabel;

@end
