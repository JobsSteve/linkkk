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

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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
    containerFrame.origin.y = CGRectGetMaxY(textViewFrame) + 20;
    _containerView.frame = containerFrame;
    
    CGSize size = self.frame.size;
    size.height = CGRectGetHeight(self.frame) + CGRectGetHeight(_textView.frame) - 100;
    self.contentSize = size;
}

@end
