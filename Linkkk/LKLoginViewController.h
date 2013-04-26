//
//  LKLoginViewController.h
//  Linkkk
//
//  Created by Vincent Wen on 4/15/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SinaWeibo;

@interface LKLoginViewController : UIViewController

@property (strong, nonatomic) SinaWeibo *sinaweibo;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (strong, nonatomic) IBOutlet UIImageView *splashView;

- (IBAction)login:(id)sender;

@end
