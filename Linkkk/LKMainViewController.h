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

@interface LKMainViewController : UIViewController <SinaWeiboDelegate, LKShakeProtocol>

@end