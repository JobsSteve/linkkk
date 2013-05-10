//
//  LKProfile.h
//  Linkkk
//
//  Created by Vincent Wen on 4/16/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class BMKAddrInfo;
@protocol LKLocationDelegate;

@interface LKProfile : NSObject

@property (strong, nonatomic, readonly) NSString *csrf;
@property (strong, nonatomic, readonly) NSString *cookie;
@property (strong, nonatomic) BMKAddrInfo *address; // KVO
@property (strong, nonatomic) BMKAddrInfo *current;

@property (strong, nonatomic) NSString *avatarURL;
@property (strong, nonatomic) NSString *username;

@property (assign, nonatomic) id<LKLocationDelegate> delegate;

+ (LKProfile *)profile;
- (void)login;
- (BOOL)isLoggedIn;

@end
