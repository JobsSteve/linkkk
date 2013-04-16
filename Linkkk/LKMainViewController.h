//
//  LKMainViewController.h
//  Linkkk
//
//  Created by Vincent Wen on 4/15/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SinaWeibo.h"

@protocol LKLoginDelegate <NSObject>
- (void)dismiss;
@end

@interface LKMainViewController : UIViewController <LKLoginDelegate, SinaWeiboDelegate>

@end