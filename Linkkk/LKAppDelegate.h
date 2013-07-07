//
//  LKAppDelegate.h
//  Linkkk
//
//  Created by Vincent Wen on 4/15/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXApi.h"

@class SinaWeibo;
@class BMKMapManager;

@interface LKAppDelegate : UIResponder <UIApplicationDelegate, WXApiDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (assign, nonatomic) BOOL resignActiveNotifier;
@property (readonly, nonatomic) SinaWeibo *sinaweibo;
@property (readonly, nonatomic) BMKMapManager *mapManager;

@end
