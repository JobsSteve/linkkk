//
//  LKDefaults.m
//  Linkkk
//
//  Created by Vincent Wen on 5/22/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import "LKDefaults.h"

static NSString * const kDefaultsDistance = @"kDefaultsDistance";
static NSString * const kDefaultsSortBy = @"kDefaultsSortBy";

@implementation LKDefaults

+ (LKFilterDistance)distance
{
    // Defaults to 0
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [[defaults objectForKey:kDefaultsDistance] intValue];
}

+ (void)setDistance:(LKFilterDistance)distance
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:distance forKey:kDefaultsDistance];
}

+ (LKFilterSortBy)sortBy
{
    // Defaults to 0
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [[defaults objectForKey:kDefaultsSortBy] intValue];
}

+ (void)setSortBy:(LKFilterSortBy)sortBy
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:sortBy forKey:kDefaultsSortBy];
}

@end
