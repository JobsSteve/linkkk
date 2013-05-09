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

#import <QuartzCore/QuartzCore.h>

@interface LKLoginViewController ()

@end

@implementation LKLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    CGRect frame = [UIScreen mainScreen].bounds;
    frame.origin.y = -20;
    _splashView.frame = frame;
    _splashView.image = [UIImage imageNamed:((CGRectGetHeight(frame) == 480) ? @"Default" : @"Default-568h")];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    CGPoint position = _loginButton.layer.position;
    animation.fromValue = [NSValue valueWithCGPoint:position];
    position.y -= 100;
    animation.toValue = [NSValue valueWithCGPoint:position];
    animation.duration = 0.5;
    _loginButton.layer.position = position;
    [_loginButton.layer addAnimation:animation forKey:@"animation"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (IBAction)login:(id)sender
{
    [_sinaweibo logIn];
    _spinner.hidden = NO;
    _loginButton.enabled = NO;
}

#pragma mark -

@end
