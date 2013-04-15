//
//  LKLoginViewController.m
//  Linkkk
//
//  Created by Vincent Wen on 4/15/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import "LKLoginViewController.h"
#import "LKMainViewController.h"

#import "SinaWeibo.h"

@interface LKLoginViewController ()

@end

@implementation LKLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_sinaweibo release];
    
    [super dealloc];
}

#pragma mark -

- (IBAction)login:(id)sender
{
    [_sinaweibo logIn];
}

#pragma mark -

@end
