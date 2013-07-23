//
//  LKLoginViewController.m
//  Linkkk
//
//  Created by Vincent Wen on 4/15/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import "LKLoginViewController.h"
#import "LKMainViewController.h"

#import "UIColor+Linkkk.h"

#import "SinaWeibo.h"
#import "MobClick.h"

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
    
    _loginButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"用新浪微博登录 "];
    NSRange range = NSMakeRange(string.length - 1, 1);
    [string addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Entypo" size:25.0] range:range];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor specialBlue] range:NSMakeRange(0, string.length)];
    [_loginButton setAttributedTitle:string forState:UIControlStateNormal];
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"Login"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"Login"];
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
