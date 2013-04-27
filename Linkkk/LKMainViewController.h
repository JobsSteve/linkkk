//
//  LKMainViewController.h
//  Linkkk
//
//  Created by Vincent Wen on 4/15/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SinaWeibo.h"

@protocol LKShakeProtocol <NSObject>
- (void)viewDidShake;
@end

@protocol LKLocationDelegate <NSObject>
- (void)locationUpdated:(NSString *)placemark;
@end

@interface LKMainViewController : UIViewController <SinaWeiboDelegate, LKShakeProtocol, LKLocationDelegate>

@property (nonatomic, strong) IBOutlet UIButton *nearbyButton;
@property (nonatomic, strong) IBOutlet UIButton *createButton;
@property (nonatomic, strong) IBOutlet UIButton *profileButton;

- (IBAction)nearbyButtonSelected:(id)sender;

@end