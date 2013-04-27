//
//  LKPlaceViewController.h
//  Linkkk
//
//  Created by Vincent Wen on 4/21/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SinaWeiboRequest.h"

@class LKPlace;
@class LKPlaceView;

@protocol LKShakeProtocol;

@interface LKPlaceViewController : UIViewController <SinaWeiboRequestDelegate>

@property (nonatomic, strong) LKPlace *place;
@property (nonatomic, strong) IBOutlet LKPlaceView *placeView;

@property (nonatomic, strong) IBOutlet UIButton *flagButton;
@property (nonatomic, strong) IBOutlet UIButton *favButton;
@property (nonatomic, strong) IBOutlet UIButton *mapButton;
@property (nonatomic, strong) IBOutlet UIButton *shareButton;

@property (nonatomic, assign) id<LKShakeProtocol> shakeDelegate;

- (IBAction)navButtonSelected:(UIButton *)sender;
- (IBAction)shareButtonSelected:(UIButton *)sender;

- (void)updateView;

@end
