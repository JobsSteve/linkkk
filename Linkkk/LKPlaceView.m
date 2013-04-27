//
//  LKPlaceView.m
//  Linkkk
//
//  Created by Vincent Wen on 4/16/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import "LKPlaceView.h"
#import "LKPlace.h"

@implementation LKPlaceView

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.alwaysBounceVertical = YES;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect textViewFrame = _textView.frame;
    textViewFrame.size = _textView.contentSize;
    _textView.frame = textViewFrame;
    
    CGRect containerFrame = _containerView.frame;
    containerFrame.origin.y = CGRectGetMaxY(textViewFrame) + 10;
    _containerView.frame = containerFrame;
    
    CGSize size = self.frame.size;
    size.height = CGRectGetHeight(self.frame) + CGRectGetHeight(_textView.frame) - 180;
    self.contentSize = size;
}

@end
