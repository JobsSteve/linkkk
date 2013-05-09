//
//  LKSettingViewController.m
//  Linkkk
//
//  Created by Vincent Wen on 5/8/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import "LKSettingViewController.h"

#import "UIBarButtonItem+Linkkk.h"

@interface LKSettingViewController ()

@end

@implementation LKSettingViewController

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
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem customBackButtonWithTitle:@"设置" target:self action:@selector(backButtonSelected:)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

#pragma mark - Callbacks

- (void)backButtonSelected:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
