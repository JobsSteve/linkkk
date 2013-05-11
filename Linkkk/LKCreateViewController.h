//
//  LKCreateViewController.h
//  Linkkk
//
//  Created by Vincent Wen on 4/23/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"

@class BMKPoiInfo;

@protocol LKPlacePickerDelegate <NSObject>
- (void)didSelectPoi:(BMKPoiInfo *)poi;
- (void)didCancelPoi;
@end

@interface LKCreateViewController : UIViewController <HPGrowingTextViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, LKPlacePickerDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UITextField *titleField;
@property (nonatomic, strong) IBOutlet UIView *toolbarView;
@property (nonatomic, strong) IBOutlet UIView *imageContainerView;
@property (nonatomic, strong) IBOutlet HPGrowingTextView *textView;
@property (nonatomic, strong) IBOutlet UILabel *placeholderLabel;
@property (nonatomic, strong) IBOutlet UILabel *charCountLabel;
@property (nonatomic, strong) IBOutlet UILabel *placemarkLabel;
@property (nonatomic, strong) IBOutlet UIButton *locationButton;
@property (nonatomic, strong) IBOutlet UIButton *photoButton;

- (IBAction)cameraButtonSelected:(id)sender;

@end
