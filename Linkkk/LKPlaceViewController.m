//
//  LKPlaceViewController.m
//  Linkkk
//
//  Created by Vincent Wen on 4/21/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import "LKPlaceViewController.h"
#import "LKPlace.h"
#import "LKPlaceView.h"
#import "LKProfile.h"
#import "LKAppDelegate.h"

#import "LKNavViewController.h"

#import "UIViewController+Linkkk.h"
#import "UIBarButtonItem+Linkkk.h"
#import "UIColor+Linkkk.h"

#import "UIImageView+WebCache.h"

#import "SinaWeibo.h"
#import "BMapKit.h"

#import <CoreLocation/CoreLocation.h>

@interface LKPlaceViewController ()

@end

@implementation LKPlaceViewController

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
    self.navigationItem.titleView = [UIBarButtonItem customTitleLabelWithString:@"攻略"];
    
    self.placeView.shakeDelegate = _shakeDelegate;
    
    [self updateView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.placeView becomeFirstResponder];
    [super viewWillAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [self.placeView resignFirstResponder];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Sina Weibo Delegates

- (void)request:(SinaWeiboRequest *)request didFailWithError:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"失败" message:error.description delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
    [alertView show];
    NSLog(@"FAILED: %@", error);
}

- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"成功" message:nil delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
    [alertView show];
    NSLog(@"SUCCESS: %@", result);
}

#pragma mark - Segue Callbacks

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"NavSegue"]) {
        LKNavViewController *navViewController = (LKNavViewController *)segue.destinationViewController;
        navViewController.from = [LKProfile profile].address.geoPt;
        navViewController.to = _place.location;
    }
}

#pragma mark - Alert View Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
        return;
    
    NSString *post = [NSString stringWithFormat:@"exp_id=%d&format=json&reason=%@", _place.placeID, [alertView textFieldAtIndex:0].text];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://map.linkkk.com/v5/report/exp/"]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = postData;
    [request setValue:[NSString stringWithFormat:@"%d", [postData length]] forHTTPHeaderField:@"Content-Length"];
    [request setValue:[LKProfile profile].csrf forHTTPHeaderField:@"X-XSRF-TOKEN"];
    [request setValue:[LKProfile profile].cookie forHTTPHeaderField:@"Cookie"];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (data == nil || error != nil) {
            [self showErrorView:[NSString stringWithFormat:@"数据加载失败, %d:%@", ((NSHTTPURLResponse *)response).statusCode, error]];
            return;
        }
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        if ([[json objectForKey:@"status"] isEqualToString:@"okay"]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"成功" message:@"举报成功" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
            [alertView show];
        }
    }];
}

#pragma mark - Callbacks

- (void)backButtonSelected:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)flagButtonSelected:(UIButton *)sender
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"举报" message:@"请输入原因" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"提交", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertView.delegate = self;
    [alertView show];
}

- (IBAction)favButtonSelected:(UIButton *)sender
{
    NSString *post = [NSString stringWithFormat:@"exp_id=%d&format=json", _place.placeID];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *urlString = _place.hasFaved ? @"http://map.linkkk.com/v5/unfavourite/exp/" : @"http://map.linkkk.com/v5/favourite/exp/";
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = postData;
    [request setValue:[NSString stringWithFormat:@"%d", [postData length]] forHTTPHeaderField:@"Content-Length"];
    [request setValue:[LKProfile profile].csrf forHTTPHeaderField:@"X-XSRF-TOKEN"];
    [request setValue:[LKProfile profile].cookie forHTTPHeaderField:@"Cookie"];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (data == nil || error != nil) {
            [self showErrorView:[NSString stringWithFormat:@"数据加载失败, %d:%@", ((NSHTTPURLResponse *)response).statusCode, error]];
            return;
        }
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        NSLog(@"%@", json);
        if (![[json objectForKey:@"status"] isEqualToString:@"okay"]) {
            [self showErrorView:@"Server failure"];
        } else {
            _place.hasFaved = !_place.hasFaved;
            _favButton.titleLabel.textColor = _place.hasFaved ? [UIColor redColor] : [UIColor specialBlue];
        }
    }];
}

- (IBAction)shareButtonSelected:(UIButton *)sender
{
    SinaWeibo *weibo = ((LKAppDelegate *)[UIApplication sharedApplication].delegate).sinaweibo;
    
    if (_place.album.count > 0) {
        NSString *string = _place.content;
        if (string.length > 118) {
            string = [string substringToIndex:120];
            string = [string stringByAppendingString:@"..."];
        }
        string = [NSString stringWithFormat:@"#大中华经历地图# %@ @连客Link", string];
        [weibo requestWithURL:@"statuses/upload.json"
                       params:[NSMutableDictionary dictionaryWithObjectsAndKeys:string, @"status", _placeView.photoView1.image, @"pic", nil]
                   httpMethod:@"POST"
                     delegate:self];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"失败" message:@"暂不能分享无图碎片" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)updateView
{
    _placeView.titleLabel.text = _place.title;
    _placeView.addressLabel.text = [NSString stringWithFormat:@"距离%d米, %@", _place.distance, _place.address];
    _placeView.textView.text = _place.content;
    
    _flagButton.titleLabel.font = [UIFont fontWithName:@"Entypo" size:60.0];
    _favButton.titleLabel.font = [UIFont fontWithName:@"Entypo" size:60.0];
    _mapButton.titleLabel.font = [UIFont fontWithName:@"Entypo" size:60.0];
    _shareButton.titleLabel.font = [UIFont fontWithName:@"Entypo" size:60.0];
    
    if (_place.hasFaved)
        _favButton.titleLabel.textColor = [UIColor redColor];
    
    NSArray *album = _place.album;
    if (album.count > 0) {
        NSURL *url = [NSURL URLWithString:[[album objectAtIndex:0] objectForKey:@"small"]];
        [_placeView.photoView1 setImageWithURL:url];
    }
    if (album.count > 1) {
        NSURL *url = [NSURL URLWithString:[[album objectAtIndex:1] objectForKey:@"small"]];
        [_placeView.photoView2 setImageWithURL:url];
    }
    if (album.count > 2) {
        NSURL *url = [NSURL URLWithString:[[album objectAtIndex:2] objectForKey:@"small"]];
        [_placeView.photoView3 setImageWithURL:url];
    }
    
    [_placeView setNeedsLayout];
}

@end
