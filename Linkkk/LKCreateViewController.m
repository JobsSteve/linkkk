//
//  LKCreateViewController.m
//  Linkkk
//
//  Created by Vincent Wen on 4/23/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import "LKCreateViewController.h"
#import "LKPlacePickerViewController.h"
#import "LKProfile.h"
#import "LKLoadingView.h"

#import "UIBarButtonItem+Linkkk.h"
#import "UIViewController+Linkkk.h"
#import "UIColor+Linkkk.h"

#import <CoreLocation/CoreLocation.h>

static NSString * const kHTTPBoundary = @"----------FDfdsf8HShdS80SDJFsf302S";

@interface LKCreateViewController ()
{
    LKProfile *_profile;
    UIImage *_image;
    int _imageID;
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
    _placemarkLabel.text = [NSString stringWithFormat:@"%@, %@, %@", placemark.thoroughfare, placemark.subLocality, placemark.locality];
    
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
//    [_titleField resignFirstResponder];
//    [_textView resignFirstResponder];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PlacePickerScene"]) {
        LKPlacePickerViewController *viewController = (LKPlacePickerViewController *)segue.destinationViewController;
        viewController.placemarkLabel = _placemarkLabel;
    }
}

#pragma mark - Callback Handlers

- (void)doneButtonSelected:(id)sender
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    LKLoadingView *loadingView = [[LKLoadingView alloc] init];
    [self.view addSubview:loadingView];

    dispatch_async(dispatch_queue_create("queue", NULL), ^{
        [self _uploadImage];
        CLLocationCoordinate2D coord = [self _geocode];
        NSMutableDictionary *dict = [@{@"content":_textView.text,
                                     @"latitude":[NSNumber numberWithFloat:coord.latitude],
                                     @"longitude":[NSNumber numberWithFloat:coord.longitude],
                                     @"city":_profile.placemark.locality,
                                     @"location":_placemarkLabel.text,
                                     @"title":_titleField.text} mutableCopy];
        if (_imageID != 0) {
            [dict setValue:[NSArray arrayWithObject:[NSNumber numberWithInt:_imageID]] forKey:@"album"];
        }
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
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [loadingView removeFromSuperview];
            [self.navigationController popViewControllerAnimated:YES];
        });
        
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%d, %@, %@", response.statusCode, response, string);
    });
}

#pragma mark - Callbacks

- (void)backButtonSelected:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)cameraButtonSelected:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"相册", nil];
    [actionSheet showInView:self.view];
}

#pragma mark - Image Picker Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    _image = [info objectForKey:UIImagePickerControllerOriginalImage];
    _photoButton.titleLabel.textColor = [UIColor specialBlue];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.sourceType = UIImagePickerControllerSourceTypeCamera;
        controller.delegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    }
    if (buttonIndex == 1) {
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        controller.delegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    }
}

#pragma mark - Helper

- (void)_uploadImage
{
    // Upload image
    if (_image == nil)
        return;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://map.linkkk.com/winterfell/upload/"]];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[LKProfile profile].csrf forHTTPHeaderField:@"X-XSRF-TOKEN"];
    [request setValue:[LKProfile profile].cookie forHTTPHeaderField:@"Cookie"];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", kHTTPBoundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    NSData *imageData = UIImageJPEGRepresentation(_image, 1.0);
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", kHTTPBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:imageData];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", kHTTPBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];
    [request setValue:[NSString stringWithFormat:@"%d", [body length]] forHTTPHeaderField:@"Content-Length"];
    
    NSHTTPURLResponse *response;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    if (data == nil) {
        NSLog(@"ERROR uploading image");
        return;
    }
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    _imageID = [[[json objectForKey:@"data"] objectForKey:@"id"] intValue];
    NSLog(@"%d, %@", response.statusCode, json);
}

- (CLLocationCoordinate2D)_geocode
{
    CLPlacemark *placemark = _profile.placemark;
    NSString *defaultAddress = [NSString stringWithFormat:@"%@, %@, %@", placemark.thoroughfare, placemark.subLocality, placemark.locality];
    if ([defaultAddress isEqualToString:_placemarkLabel.text]) {
        return _profile.location.coordinate;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true", [_placemarkLabel.text stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSURLResponse *response;
    NSError *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (data == nil || error != nil) {
        [self showErrorView:[NSString stringWithFormat:@"数据加载失败, %d:%@", ((NSHTTPURLResponse *)response).statusCode, error]];
        return _profile.location.coordinate;
    }
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    NSArray *results = [json objectForKey:@"results"];
    if (results.count == 0)
        return _profile.location.coordinate;
    NSDictionary *location = [[[results objectAtIndex:0] objectForKey:@"geometry"] objectForKey:@"location"];
    NSLog(@"%@", location);
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([[location objectForKey:@"lat"] floatValue], [[location objectForKey:@"lng"] floatValue]);
    if (coord.latitude == 0 || coord.longitude == 0)
        return _profile.location.coordinate;
    return coord;
}

@end
