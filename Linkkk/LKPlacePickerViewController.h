//
//  LKPlacePickerViewController.h
//  Linkkk
//
//  Created by Vincent Wen on 5/6/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LKPlacePickerDelegate;

@interface LKPlacePickerViewController : UITableViewController <UISearchBarDelegate>

@property (assign, nonatomic) id<LKPlacePickerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@end
