//
//  LKShareWeiboViewController.m
//  Linkkk
//
//  Created by Vincent Wen on 5/24/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import "LKShareWeiboViewController.h"
#import "LKAppDelegate.h"
#import "LKPlace.h"
#import "LKLoadingView.h"

#import "UIBarButtonItem+Linkkk.h"
#import "UIImageView+WebCache.h"

#import "SinaWeibo.h"
#import "MobClick.h"

@interface LKShareWeiboViewController () <SinaWeiboRequestDelegate>
{
    LKLoadingView *_loadingView;
    BOOL _uploading;
}

@end

@implementation LKShareWeiboViewController

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
    
    // Custom navigation
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem customBackButtonWithTitle:@"微博分享" target:self action:@selector(backButtonSelected:)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem customButtonWithIcon:@"✓" size:50.0 target:self action:@selector(doneButtonSelected:)];
    
    // Loading View
    _loadingView = [[LKLoadingView alloc] init];
    
    // Load image
    if (_place.album.count > 0) {
        [_imageView1 setImageWithURL:[NSURL URLWithString:[[_place.album objectAtIndex:0] objectForKey:@"square"]]];
    }
    if (_place.album.count > 1) {
        [_imageView2 setImageWithURL:[NSURL URLWithString:[[_place.album objectAtIndex:1] objectForKey:@"square"]]];
    }
    if (_place.album.count > 2) {
        [_imageView3 setImageWithURL:[NSURL URLWithString:[[_place.album objectAtIndex:2] objectForKey:@"square"]]];
    }
    
    // Format content
    NSString *string = _place.content;
    if (string.length > 115) {
        string = [string substringToIndex:117];
        string = [string stringByAppendingString:@"..."];
    }
    string = [NSString stringWithFormat:@"#大中华经历地图# %@ @连客Link", string];
    _textView.text = string;
    _textView.delegate = self;
    _label.text = [NSString stringWithFormat:@"%d/140", string.length];
    
    [_textView becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [MobClick event:@"share_scene_clicked"];
    [MobClick beginLogPageView:@"Share Weibo"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"Share Weibo"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Text View Delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    int length = range.location + text.length;
    if (length <= 140) {
        _label.text = [NSString stringWithFormat:@"%d/140", length];
        return YES;
    } else {
        _label.text = [NSString stringWithFormat:@"%d/140", range.location];
        return NO;
    }
}

#pragma mark - Weibo Delegates

- (void)request:(SinaWeiboRequest *)request didFailWithError:(NSError *)error
{
    [MobClick event:@"weibo_share_fail"];
    [_loadingView removeFromSuperview];
    _uploading = NO;
    [self _showAlert];
}

- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result
{
    if (result == nil || [result objectForKey:@"error"] != nil) {
        [MobClick event:@"weibo_share_error"];
        [_loadingView removeFromSuperview];
        _uploading = NO;
        [self _showAlert];
    } else {
        [MobClick event:@"weibo_share_success"];
        NSLog(@"WEIBO SUCCESS: %@", result);
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)_showAlert
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误" message:@"分享失败，请重试" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - Callback Handlers

- (void)backButtonSelected:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doneButtonSelected:(UIButton *)sender
{
    if (_uploading)
        return;
    _uploading = YES;
    
    SinaWeibo *weibo = ((LKAppDelegate *)[UIApplication sharedApplication].delegate).sinaweibo;
    
    if (_place.album.count == 0) {
        [MobClick event:@"weibo_share_text"];
        [weibo requestWithURL:@"statuses/update.json"
                       params:[NSMutableDictionary dictionaryWithObjectsAndKeys:_textView.text, @"status", nil]
                   httpMethod:@"POST"
                     delegate:self];
    }
    else {
        [MobClick event:@"weibo_share_image"];
        [weibo requestWithURL:@"statuses/upload.json"
                       params:[NSMutableDictionary dictionaryWithObjectsAndKeys:_textView.text, @"status", _imageView1.image, @"pic", nil]
                   httpMethod:@"POST"
                     delegate:self];
    }
    
    [_textView resignFirstResponder];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.view addSubview:_loadingView];
}

@end
