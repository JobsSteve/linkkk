//
//  LKPlaceView.m
//  Linkkk
//
//  Created by Vincent Wen on 4/16/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import "LKPlaceView.h"
#import "LKPlace.h"

#import "LKMainViewController.h"
#import "LKPlaceViewController.h"

#import "UIButton+WebCache.h"

@interface LKPlaceView ()
{
    CGRect initialFrame;
}
@end

@implementation LKPlaceView

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.alwaysBounceVertical = YES;
        
        _imageButtons = [NSMutableArray arrayWithCapacity:3];
        for (int i=0;i<3;i++) {
            UIButton *button = (UIButton *)[self viewWithTag:100+i];
            button.hidden = YES;
            [button addTarget:self action:@selector(_imageSelected:) forControlEvents:UIControlEventTouchUpInside];
            [_imageButtons addObject:button];
        }
    }
    return self;
}

- (void)setPlace:(LKPlace *)place
{
    _place = place;
    
    _titleLabel.text = _place.title;
    _addressLabel.text = [NSString stringWithFormat:@"距离%d米, %@", _place.distance, _place.address];
    _textView.text = _place.content;
    
    NSArray *album = _place.album;
    [album enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (_imageButtons.count > idx) {
            NSURL *url = [NSURL URLWithString:[[album objectAtIndex:idx] objectForKey:@"small"]];
            UIButton *button = [_imageButtons objectAtIndex:idx];
            [button setImageWithURL:url];
            button.hidden = NO;
        }
    }];
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (CGRectIsEmpty(initialFrame))
        initialFrame = _textView.frame;
    CGRect textViewFrame = initialFrame;
    textViewFrame.size = _textView.contentSize;
    if (_place.album.count == 0) textViewFrame.origin.y -= 96.0;
    _textView.frame = textViewFrame;
    
    CGRect containerFrame = _containerView.frame;
    containerFrame.origin.y = CGRectGetMaxY(textViewFrame) + 10;
    _containerView.frame = containerFrame;
    
    CGSize size = self.frame.size;
    size.height = CGRectGetHeight(self.frame) + CGRectGetHeight(_textView.frame) - 180;
    self.contentSize = size;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        [_shakeDelegate shakeViewDidShake];
    }
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)_imageSelected:(UIButton *)sender
{
    NSLog(@"selected");
    [_placeDelegate didSelectPhoto:sender];
}

@end
