//
//  LKLoginViewController.h
//  Linkkk
//
//  Created by Vincent Wen on 4/15/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SinaWeibo;
@protocol LKLoginDelegate;

@interface LKLoginViewController : UIViewController

@property (assign, nonatomic) id<LKLoginDelegate> delegate;
@property (strong, nonatomic) SinaWeibo *sinaweibo;

- (IBAction)login:(id)sender;

@end
