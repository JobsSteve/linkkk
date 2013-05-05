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
    
    // Keyboard setup
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapScreen:)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    [_titleField becomeFirstResponder];
    
    // Register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];
    
    _photoButton.titleLabel.font = [UIFont fontWithName:@"Entypo" size:60.0];
    _locationButton.titleLabel.font = [UIFont fontWithName:@"Entypo" size:60.0];
    
    CLPlacemark *placemark = _profile.placemark;
    _placemarkLabel.text = [NSString stringWithFormat:@"%@, %@, %@", placemark.name, placemark.thoroughfare, placemark.locality];
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem customBackButtonWithTarget:self action:@selector(backButtonSelected:)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem customButtonWithIcon:@"✓" Target:self action:@selector(doneButtonSelected:)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Keyboard Handlers

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (range.location + text.length <= 140) {
        _charCountLabel.text = [NSString stringWithFormat:@"%d/140", range.location + text.length];
        return YES;
    } else {
        _charCountLabel.text = [NSString stringWithFormat:@"%d/140", range.location];
        return NO;
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    // TODO: animation
    _scrollView.frame = self.view.frame;
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect frame = self.view.frame;
    frame.size.height -= CGRectGetHeight(keyboardRect);
    _scrollView.frame = frame;
}

- (void)didTapScreen:(id)sender
{
    [_titleField resignFirstResponder];
    [_textView resignFirstResponder];
}

#pragma mark - Callback Handlers

- (void)doneButtonSelected:(id)sender
{
    NSLog(@"done");
}

/*
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
 */

#pragma mark - Callbacks

- (void)backButtonSelected:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
