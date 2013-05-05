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
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem customButtonWithName:@"注销" target:self action:@selector(logoutButtonSelected:)];
    
    LKProfile *profile = [LKProfile profile];
    if (profile.username == nil) {
        [profile addObserver:self forKeyPath:@"username" options:NSKeyValueObservingOptionNew context:NULL];
    } else {
        _username.text = profile.username;
        [_imageView setImageWithURL:[NSURL URLWithString:profile.avatarURL]];
    }
    
    [self _fetchFav];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - KVO Handlers

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self performSelectorOnMainThread:@selector(updateUI:) withObject:nil waitUntilDone:NO];
}

- (void)updateUI:(id)sender
{
    LKProfile *profile = [LKProfile profile];
    _username.text = profile.username;
    [_imageView setImageWithURL:[NSURL URLWithString:profile.avatarURL]];
}

#pragma mark - Callbacks

- (void)logoutButtonSelected:(UIButton *)sender
{
    [_sinaweibo logOut];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)backButtonSelected:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)_fetchFav
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://map.linkkk.com/api/alpha/favourited/"]];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        // Parse user info
        if (data != nil) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSLog(@"%@", json);
        }
    }];
}

@end
