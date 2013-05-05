//
//  LKLoadingView.m
//  Linkkk
//
//  Created by Vincent Wen on 5/5/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import "LKLoadingView.h"

#import <QuartzCore/CALayer.h>

@implementation LKLoadingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        CGRect bounds = [UIScreen mainScreen].bounds;
        CGRect rect = CGRectMake(0, 0, 120, 100);
        self.frame = rect;
        self.center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds) - 100);
        self.backgroundColor = [UIColor blackColor];
        self.alpha = 0.8;
        self.layer.cornerRadius = 10;
        
        UILabel *label = [[UILabel alloc] init];
        label.text = @"加载中";
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont boldSystemFontOfSize:18.0];
        label.backgroundColor = [UIColor clearColor];
        [label sizeToFit];
        label.center = CGPointMake(60, 80);
        [self addSubview:label];
        
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        spinner.center = CGPointMake(60, 40);
        [self addSubview:spinner];
        [spinner startAnimating];
    }
    return self;
}

@end
