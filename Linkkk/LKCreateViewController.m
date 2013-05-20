//
//  LKCreateViewController.m
//  Linkkk
//
//  Created by Vincent Wen on 4/23/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import "LKCreateViewController.h"
#import "LKPlacePickerViewController.h"
#import "LKMainViewController.h"
#import "LKProfile.h"
#import "LKMapManager.h"
#import "LKLoadingView.h"

#import "UIButton+Linkkk.h"
#import "UIBarButtonItem+Linkkk.h"
#import "UIViewController+Linkkk.h"
#import "UIColor+Linkkk.h"
#import "UIImage+Linkkk.h"

#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>

#import "BMapKit.h"
#import "AGImagePickerController.h"

static NSString * const kHTTPBoundary = @"----------FDfdsf8HShdS80SDJFsf302S";

@interface LKCreateViewController () <NSURLConnectionDataDelegate>
{
    LKProfile *_profile;
    BMKPoiInfo *_poi;

    int _imageBeingUploaded;
    NSArray *_imageButtons;
    NSArray *_progressLabels;
    NSMutableArray *_assets;
    NSMutableArray *_imageIDs;
    NSMutableData *_uploadResponseData;
    
    CGRect _textViewFrame;
    LKLoadingView *_loadingView;
}
@end

@implementation LKCreateViewController

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _profile = [LKProfile profile];
        
        _assets = [NSMutableArray arrayWithCapacity:5];
        _imageIDs = [NSMutableArray arrayWithCapacity:5];
        
        _loadingView = [[LKLoadingView alloc] init];
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
    
    // Text View setup
    _textView.delegate = self;
    _textView.font = [UIFont systemFontOfSize:15.0];
    _textView.minNumberOfLines = 3;
    _textView.maxNumberOfLines = 20;
    
    // Register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];
    
    _photoButton.titleLabel.font = [UIFont fontWithName:@"Entypo" size:50.0];
    _locationButton.titleLabel.font = [UIFont fontWithName:@"Entypo" size:50.0];
    
    // Custom navigation
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem customBackButtonWithTitle:@"创建" target:self action:@selector(backButtonSelected:)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem customButtonWithIcon:@"✓" size:50.0 target:self action:@selector(doneButtonSelected:)];
    
    // Image Views
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:5];
    for (int i=0;i<5;i++) {
        UIButton *button = (UIButton *)[self.view viewWithTag:100+i];
        [button addTarget:self action:@selector(_discardImage:) forControlEvents:UIControlEventTouchUpInside];
        [array addObject:button];
    }
    _imageButtons = [NSArray arrayWithArray:array];
    
    // Progress Labels
    array = [NSMutableArray arrayWithCapacity:5];
    for (int i=0;i<5;i++) {
        [array addObject:[self.view viewWithTag:200+i]];
    }
    _progressLabels = [NSArray arrayWithArray:array];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (CGRectIsEmpty(_textViewFrame))
        _textViewFrame = _textView.frame;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Keyboard Handlers

- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    int length = range.location + text.length;
    if (length <= 140) {
        _charCountLabel.text = [NSString stringWithFormat:@"%d/140", length];
        _placeholderLabel.hidden = length != 0;
        return YES;
    } else {
        _charCountLabel.text = [NSString stringWithFormat:@"%d/140", range.location];
        return NO;
    }
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView didChangeHeight:(float)height
{
    CGRect frame = _imageContainerView.frame;
    frame.origin.y = CGRectGetMaxY(_textView.frame) + 10.0;
    _imageContainerView.frame = frame;
    [self _calculateContentSize];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect frame = self.view.frame;
    frame.size.height -= 40.0; // Toolbar height
    _scrollView.frame = frame;
    [self _calculateContentSize];
    
    [UIView beginAnimations:nil context:NULL];
    CGRect toolbarFrame = _toolbarView.frame;
    toolbarFrame.origin.y = keyboardRect.origin.y - CGRectGetHeight(toolbarFrame) - 64.0; // convert point
    _toolbarView.frame = toolbarFrame;
    [UIView setAnimationDuration:[[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    [UIView commitAnimations];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect frame = self.view.frame;
    frame.size.height -= CGRectGetHeight(keyboardRect) + 40.0; // Toolbar height
    _scrollView.frame = frame;
    [self _calculateContentSize];
    
    [UIView beginAnimations:nil context:NULL];
    CGRect toolbarFrame = _toolbarView.frame;
    toolbarFrame.origin.y = keyboardRect.origin.y - CGRectGetHeight(toolbarFrame) - 64.0; // convert point
    _toolbarView.frame = toolbarFrame;
    [UIView setAnimationDuration:[[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    [UIView commitAnimations];
}

- (void)_calculateContentSize
{
    CGFloat maxY = (_assets.count == 0) ? CGRectGetMaxY(_textView.frame) : CGRectGetMaxY(_imageContainerView.frame);
    _scrollView.contentSize = CGSizeMake(320.0, maxY + 10);
}

- (void)didTapScreen:(id)sender
{
    [_titleField resignFirstResponder];
    [_textView resignFirstResponder];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PlacePickerScene"]) {
        LKPlacePickerViewController *viewController = (LKPlacePickerViewController *)segue.destinationViewController;
        viewController.placeholder = _poi.name;
        viewController.delegate = self;
    }
}

#pragma mark - Callback Handlers

- (void)doneButtonSelected:(id)sender
{
    if (_titleField.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入标题" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
        [alert show];
        return;
    }
    if (_titleField.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入内容" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
        [alert show];
        return;
    }
    if (_poi == nil)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请选择地址" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [self _enableUI:NO];
    BOOL hasImage = (_assets.count != 0);
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    LKLoadingView *loadingView = [[LKLoadingView alloc] init];
    [self.view addSubview:loadingView];
    
    if (hasImage) {
        // TODO: timer/spinner hack, should be on a separate thread
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(_uploadImageAndPostInfo) userInfo:nil repeats:NO];
    } else {
        [self _postInfoWithImage:hasImage];
    }
    
    return;
}

- (void)_postInfoWithImage:(BOOL)hasImage
{
    
    NSString *content = _textView.text;
    NSString *title = _titleField.text;
    
    dispatch_async(dispatch_queue_create("post_info_queue", NULL), ^{
        NSString *city = _poi.city == nil ? @"未知城市" : _poi.city;
        NSString *address = _poi.address == nil ? @"未知地址" : _poi.address;
        NSString *name = _poi.name == nil ? @"未知地名" : _poi.name;
        NSMutableDictionary *dict = [@{@"content":content,
                                     @"latitude":[NSNumber numberWithFloat:_poi.pt.latitude],
                                     @"longitude":[NSNumber numberWithFloat:_poi.pt.longitude],
                                     @"city":city,
                                     @"address":address,
                                     @"location":name,
                                     @"title":title} mutableCopy];
        if (hasImage) {
            [dict setValue:_imageIDs forKey:@"album"];
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
            [_loadingView removeFromSuperview];
            // [self _enableUI:YES]; unnecessary as we pop
            [self.navigationController popViewControllerAnimated:YES];
            [self.delegate hasCreated];
        });
        
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%d, %@, %@", response.statusCode, response, string);
    });
}

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
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    ALAssetsLibrary *library = [AGImagePickerController defaultAssetsLibrary];
    [library writeImageToSavedPhotosAlbum:[image CGImage] orientation:image.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error) {
            NSLog(@"ERROR: cannot save photo. %@", error);
            return;
        }
        [library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
            if (_assets.count >= 5) {
                return;
            }
            [_assets addObject:asset];
            if (!_poi) [self _updateCoordinateFromAsset:asset];
            UIButton *imageButton = [_imageButtons objectAtIndex:_assets.count - 1];
            imageButton.image = [UIImage imageWithCGImage:asset.thumbnail];
            imageButton.hidden = NO;
            _photoButton.selected = YES;
            [self dismissViewControllerAnimated:YES completion:nil];
        } failureBlock:^(NSError *error) {
            NSLog(@"ERROR: failed to retrieve photo, %@", error);
        }];
    }];
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
        AGImagePickerController *imagePickerController = [[AGImagePickerController alloc] initWithFailureBlock:^(NSError *error)
        {
            if (error == nil)
            {
                [self dismissViewControllerAnimated:YES completion:nil];
            } else
            {
                NSLog(@"Error: %@", error);
                
                // Wait for the view controller to show first and hide it after that
                double delayInSeconds = 0.5;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [self dismissViewControllerAnimated:YES completion:nil];
                });
            }
        } andSuccessBlock:^(NSArray *info) {
            [_imageButtons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                UIButton *button = (UIButton *)obj;
                button.image = nil;
                button.hidden = YES;
            }];
            _assets = [NSMutableArray arrayWithArray:info];
            [_assets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                ALAsset *asset = obj;
                if (!_poi) [self _updateCoordinateFromAsset:asset];
                UIButton *imageButton = [_imageButtons objectAtIndex:idx];
                imageButton.image = [UIImage imageWithCGImage:asset.thumbnail];
                imageButton.hidden = NO;
            }];
            _photoButton.selected = YES;
            
            // FIX: unbalanced view controller bug
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self dismissViewControllerAnimated:YES completion:nil];
            });
        }];
        imagePickerController.selection = _assets;
        imagePickerController.maximumNumberOfPhotosToBeSelected = 5;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
}

#pragma mark - Place Picker Delegate

- (void)didSelectPoi:(BMKPoiInfo *)poi
{
    _poi = poi;
    if (_poi.city == nil || _poi.address == nil) {
        [[LKMapManager sharedInstance] reverseGeocode:_poi.pt withCompletionHandler:^(BMKAddrInfo *addr, int error) {
            // Failed to reverse geocode
            if (addr.strAddr == nil) {
                _poi = nil;
                _locationButton.selected = NO;
                return;
            }
            if (_poi.city == nil) _poi.city = addr.addressComponent.city;
            if (_poi.address == nil) {
                _poi.address = addr.strAddr;
                _placemarkLabel.text = _poi.address;
            }
        }];
    }
    
    _placemarkLabel.text = _poi.name;
    _locationButton.selected = YES;
}

- (void)didCancelPoi
{
    _poi = nil;
    _placemarkLabel.text = @"请选择地点";
    _locationButton.selected = NO;
}

#pragma mark - Helper

- (void)_discardImage:(UIButton *)sender
{
    int idx = sender.tag - 100;
    for (int i=idx;i<_assets.count-1;i++) {
        UIButton *leftButton = (UIButton *)[_imageButtons objectAtIndex:i];
        UIButton *rightButton = (UIButton *)[_imageButtons objectAtIndex:i+1];
        leftButton.image = rightButton.image;
    }
    UIButton *lastButton = ((UIButton *)[_imageButtons objectAtIndex:_assets.count-1]);
    lastButton.image = nil;
    lastButton.hidden = YES;
    
    [_assets removeObjectAtIndex:idx];
    if (_assets.count == 0) {
        _photoButton.selected = NO;
        [self _calculateContentSize];
    }
}

- (void)_updateCoordinateFromAsset:(ALAsset *)asset
{
    CLLocation *location = [asset valueForProperty:ALAssetPropertyLocation];
    if (location.coordinate.latitude == 0 || location.coordinate.longitude == 0)
        return;
    BMKPoiInfo *poi = [[BMKPoiInfo alloc] init];
    poi.pt = location.coordinate;
    [self didSelectPoi:poi];
}

- (void)_enableUI:(BOOL)enabled
{
    self.navigationItem.rightBarButtonItem.enabled = enabled;
    _textView.userInteractionEnabled = enabled;
    _titleField.userInteractionEnabled = enabled;
    _locationButton.enabled = enabled;
    _photoButton.enabled = enabled;
    _imageContainerView.userInteractionEnabled = enabled; // cheap way to disable photo buttons
}

- (void)_postInfoFailed
{
    [self _enableUI:YES];
    _imageBeingUploaded = 0;
    [_imageIDs removeAllObjects];
    [_progressLabels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ((UILabel *)obj).hidden = YES;
    }];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"创建失败, 请重新尝试" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
    [alert show];
}

- (void)_uploadImageAndPostInfo
{
    // Post info
    if (_imageBeingUploaded >= _assets.count) {
        [self _postInfoWithImage:YES];
        return;
    }
    ((UILabel *)[_progressLabels objectAtIndex:_imageBeingUploaded]).hidden = NO;
    ALAsset *asset = [_assets objectAtIndex:_imageBeingUploaded];
    CGImageRef imageRef = asset.defaultRepresentation.fullResolutionImage;
    
    // resize and orient
    UIImage *image = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:[[asset valueForProperty:ALAssetPropertyOrientation] intValue]];
    image = [image normalizedImage];
    CGSize size = [UIImage strategicSizeWithImageSize:image.size];
    NSLog(@"Upload image: %@, size: %@, new size: %@", image, NSStringFromCGSize(image.size), NSStringFromCGSize((size)));
    image = [UIImage imageWithImage:image scaledToSize:size];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://map.linkkk.com/winterfell/upload/ios/"]];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setTimeoutInterval:60];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[LKProfile profile].csrf forHTTPHeaderField:@"X-XSRF-TOKEN"];
    [request setValue:[LKProfile profile].cookie forHTTPHeaderField:@"Cookie"];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", kHTTPBoundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    NSLog(@"Image size before: %d", imageData.length);
    imageData = UIImageJPEGRepresentation(image, [UIImage strategicRatioWithDataSize:imageData.length]);
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", kHTTPBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:imageData];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", kHTTPBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];
    [request setValue:[NSString stringWithFormat:@"%d", body.length] forHTTPHeaderField:@"Content-Length"];
    NSLog(@"Image size after: %d", imageData.length);
    
    [NSURLConnection connectionWithRequest:request delegate:self];
    _uploadResponseData = [[NSMutableData alloc] init]; // prepare to receive data
}

#pragma mark - NSURLConnection Delegate

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    UILabel *label = (UILabel *)[_progressLabels objectAtIndex:_imageBeingUploaded];
    label.text = [NSString stringWithFormat:@"%d%%", 100*totalBytesWritten/totalBytesExpectedToWrite];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_uploadResponseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // TODO: exception catch
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:_uploadResponseData options:kNilOptions error:nil];
    if (json && [[json objectForKey:@"status"] isEqualToString:@"okay"]) {
        [_imageIDs addObject:[[json objectForKey:@"data"] objectForKey:@"id"]];
        _imageBeingUploaded++;
        [self _uploadImageAndPostInfo];
        return;
    } else {
        [self _postInfoFailed];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"ERROR: uploading failed %@", error);
    [self _postInfoFailed];
}

@end
