//
//  LKDefaults.h
//  Linkkk
//
//  Created by Vincent Wen on 5/22/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LKDropDownOptionsView.h"

@interface LKDefaults : NSObject

+ (LKFilterDistance)distance;
+ (void)setDistance:(LKFilterDistance)distance;

+ (LKFilterSortBy)sortBy;
+ (void)setSortBy:(LKFilterSortBy)sortBy;

@end
