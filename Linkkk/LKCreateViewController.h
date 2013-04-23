//
//  LKCreateViewController.h
//  Linkkk
//
//  Created by Vincent Wen on 4/23/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LKCreateViewController : UIViewController

@property (nonatomic, strong) IBOutlet UITextField *titleField;
@property (nonatomic, strong) IBOutlet UITextView *textView;
@property (nonatomic, strong) IBOutlet UILabel *charCountLabel;
@property (nonatomic, strong) IBOutlet UILabel *placemarkLabel;

- (IBAction)doneButtonDidSelect:(id)sender;

@end
