//
//  LKCreateViewController.m
//  Linkkk
//
//  Created by Vincent Wen on 4/23/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import "LKCreateViewController.h"
#import "LKProfile.h"

#import "UIBarButtonItem+Linkkk.h"

#import <CoreLocation/CoreLocation.h>

@interface LKCreateViewController ()
{
    LKProfile *_profile;
}
@end

@implementation LKCreateViewController

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _profile = [LKProfile profile];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CLPlacemark *placemark = _profile.placemark;
    _placemarkLabel.text = [NSString stringWithFormat:@"%@, %@, %@", placemark.name, placemark.thoroughfare, placemark.locality];
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem customBackButtonWithTarget:self action:@selector(backButtonSelected:)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Callback Handlers

- (IBAction)doneButtonDidSelect:(id)sender
{
    CLLocationCoordinate2D coord = _profile.location.coordinate;
    NSDictionary *dict = @{@"content":@"blah blah blah",
                           @"latitude":[NSNumber numberWithFloat:coord.latitude],
                           @"longitude":[NSNumber numberWithFloat:coord.longitude],
                           @"city":@"Waterloo",
                           @"location":@"University of Waterloo",
                           @"title":@"My favourite place in the world"};
    NSData *postData = [NSJSONSerialization dataWithJSONObject:dict options:NULL error:nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://map.linkkk.com/api/alpha/experience/"]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = postData;
    [request setValue:[NSString stringWithFormat:@"%d", [postData length]] forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[LKProfile profile].csrf forHTTPHeaderField:@"X-XSRF-TOKEN"];
    [request setValue:[LKProfile profile].cookie forHTTPHeaderField:@"Cookie"];
    
    NSHTTPURLResponse *response;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%d, %@, %@", response.statusCode, response, string);
}

#pragma mark - Callbacks

- (void)backButtonSelected:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
