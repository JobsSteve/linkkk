//
//  LKProfile.m
//  Linkkk
//
//  Created by Vincent Wen on 4/16/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import "LKProfile.h"

@implementation LKProfile

+ (LKProfile *)profile
{
    static LKProfile *profile = nil;
    if (profile == nil) {
        profile = [[LKProfile alloc] init];
    }
    return profile;
}

+ (void)login
{
    
}

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

@end
