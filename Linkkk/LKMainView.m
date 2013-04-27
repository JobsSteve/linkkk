//
//  LKMainView.m
//  Linkkk
//
//  Created by Vincent Wen on 4/21/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import "LKMainView.h"
#import "LKMainViewController.h"

@implementation LKMainView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        [_delegate mainViewDidShake];
    }
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

@end
