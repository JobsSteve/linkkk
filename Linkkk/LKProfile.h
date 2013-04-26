//
//  LKProfile.h
//  Linkkk
//
//  Created by Vincent Wen on 4/16/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol LKLocationDelegate;

@interface LKProfile : NSObject <CLLocationManagerDelegate>

@property (strong, nonatomic, readonly) NSString *csrf;
@property (strong, nonatomic, readonly) NSString *cookie;
@property (strong, nonatomic, readonly) CLLocation *location;
@property (strong, nonatomic, readonly) CLPlacemark *placemark;

@property (assign, nonatomic) id<LKLocationDelegate> delegate;

+ (LKProfile *)profile;
- (void)login;
- (BOOL)isLoggedIn;

@end
