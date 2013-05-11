//
//  LKCreateViewController.h
//  Linkkk
//
//  Created by Vincent Wen on 4/23/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BMKPoiInfo;

@protocol LKPlacePickerDelegate <NSObject>
- (void)didSelectPoi:(BMKPoiInfo *)poi;
- (void)didCancelPoi;
@end

@interface LKCreateViewController : UIViewController <UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, LKPlacePickerDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UITextField *titleField;
@property (nonatomic, strong) IBOutlet UITextView *textView;
@property (nonatomic, strong) IBOutlet UILabel *placeholderLabel;
@property (nonatomic, strong) IBOutlet UILabel *charCountLabel;
@property (nonatomic, strong) IBOutlet UILabel *placemarkLabel;
@property (nonatomic, strong) IBOutlet UIButton *locationButton;
@property (nonatomic, strong) IBOutlet UIButton *photoButton;

- (IBAction)cameraButtonSelected:(id)sender;

@end
