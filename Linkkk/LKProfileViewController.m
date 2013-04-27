//
//  LKProfileViewController.m
//  Linkkk
//
//  Created by Vincent Wen on 4/16/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import "LKProfileViewController.h"
#import "LKProfile.h"

#import "UIBarButtonItem+Linkkk.h"

#import "UIImageView+WebCache.h"

@interface LKProfileViewController ()

@end

@implementation LKProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = [UIBarButtonItem customBackButtonWithTarget:self action:@selector(backButtonSelected:)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem customButtonWithName:@"注销" target:self action:@selector(logout:)];
    
    LKProfile *profile = [LKProfile profile];
    _username.text = profile.username;
    [_imageView setImageWithURL:[NSURL URLWithString:profile.avatarURL]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Callbacks

- (IBAction)logout:(id)sender
{
    [_sinaweibo logOut];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)backButtonSelected:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
