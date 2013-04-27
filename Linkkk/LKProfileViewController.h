//
//  LKProfileViewController.h
//  Linkkk
//
//  Created by Vincent Wen on 4/16/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SinaWeibo.h"

@interface LKProfileViewController : UIViewController

@property (strong, nonatomic) SinaWeibo *sinaweibo;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *username;

- (IBAction)logout:(id)sender;

@end
