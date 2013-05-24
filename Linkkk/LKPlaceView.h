//
//  LKPlaceView.h
//  Linkkk
//
//  Created by Vincent Wen on 4/16/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LKPlace;
@protocol LKShakeProtocol;
@protocol LKPlaceDelegate;

@interface LKPlaceView : UIScrollView

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet UILabel *contactLabel;
@property (strong, nonatomic) IBOutlet UILabel *hoursLabel;
@property (strong, nonatomic) IBOutlet UILabel *contactIconLabel;
@property (strong, nonatomic) IBOutlet UILabel *hoursIconLabel;
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UIView *infoView;
@property (strong, nonatomic) NSMutableArray *imageButtons;

@property (strong, nonatomic) LKPlace *place;

@property (nonatomic, assign) id<LKShakeProtocol> shakeDelegate;
@property (nonatomic, assign) id<LKPlaceDelegate> placeDelegate;

@end
