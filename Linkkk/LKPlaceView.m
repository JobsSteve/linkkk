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
    [_titleLabel sizeToFit];
    _addressLabel.text = [NSString stringWithFormat:@"距离%d米, %@, %@", _place.distance, _place.location, _place.address];
    [_addressLabel sizeToFit];
    _textView.text = _place.content;
    
    NSArray *album = _place.album;
    [album enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (_imageButtons.count > idx) {
            NSURL *url = [NSURL URLWithString:[[album objectAtIndex:idx] objectForKey:@"square"]];
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
    
    CGRect titleFrame = _titleLabel.frame;
    
    CGRect addressFrame = _addressLabel.frame;
    addressFrame.origin.y = CGRectGetMaxY(titleFrame) + 12.0;
    _addressLabel.frame = addressFrame;
    
    for (UIButton *button in _imageButtons) {
        CGRect imageFrame = button.frame;
        imageFrame.origin.y = CGRectGetMaxY(addressFrame) + 15.0;
        button.frame = imageFrame;
    }
    
    if (CGRectIsEmpty(initialFrame))
        initialFrame = _textView.frame;
    CGRect textViewFrame = initialFrame;
    textViewFrame.size = _textView.contentSize;
    if (_place.album.count == 0) {
        textViewFrame.origin.y = CGRectGetMaxY(addressFrame) + 12.0;
    } else {
        textViewFrame.origin.y = CGRectGetMaxY(((UIButton *)[_imageButtons objectAtIndex:0]).frame) + 5.0;
    }
    _textView.frame = textViewFrame;
    
    CGSize size = self.frame.size;
    size.height = CGRectGetMaxY(_textView.frame) + 0.0;
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
