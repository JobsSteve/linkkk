//
//  LKProfile.h
//  Linkkk
//
//  Created by Vincent Wen on 4/16/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LKProfile : NSObject

@property (strong, nonatomic) NSString *csrf;

+ (LKProfile *)profile;
- (void)login;
- (BOOL)isLoggedIn;

@end
