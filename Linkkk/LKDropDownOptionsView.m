//
//  LKDropDownOptionsView.m
//  Linkkk
//
//  Created by Vincent Wen on 5/22/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import "LKDropDownOptionsView.h"
#import "LKNearbyViewController.h"
#import "LKDefaults.h"

#import "UIButton+Linkkk.h"

#import <QuartzCore/QuartzCore.h>

static const int kTableHeaderHeight = 34.0;
static const int kCellHeight = 60.0;
static const int kButtonTagOffset = 100;

@interface LKDropDownOptionsView ()
{
    NSMutableArray *_buttons;
    
    UILabel *_checkmark;
}
@end

@implementation LKDropDownOptionsView

- (id)initWithOptions:(NSArray *)options type:(LKFilterType)type
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _options = options;
        _filterType = type;
        
        int count = _options.count;
        CGFloat height = count * kCellHeight;
        self.alpha = 0.0;
        self.backgroundColor = [UIColor whiteColor];
        self.frame = CGRectMake(0, kTableHeaderHeight - height, 320, height);
        
        for (int i=0;i<count;i++) {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(20, i * kCellHeight, 280, kCellHeight)];
            [button setTitle:[_options objectAtIndex:i]];
            [button setTitleFont:[UIFont systemFontOfSize:20.0]];
            [button setTitleColor:[UIColor darkGrayColor]];
            [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
            [button addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
            button.backgroundColor = [UIColor whiteColor];
            button.tag = kButtonTagOffset + i;
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            button.clipsToBounds = NO;
            [self addSubview:button];
            [_buttons addObject:button];
            
            UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(-20, kCellHeight - 1, 320, 1)];
            divider.backgroundColor = [UIColor lightGrayColor];
            [button addSubview:divider];
        }
        
        // Checkmark
        _checkmark = [[UILabel alloc] init];
        _checkmark.font = [UIFont fontWithName:@"Entypo" size:50.0];
        _checkmark.text = @"✓";
        _checkmark.textColor = [UIColor darkGrayColor];
        _checkmark.backgroundColor = [UIColor clearColor];
        [_checkmark sizeToFit];
        [self addSubview:_checkmark];
        
        if (_filterType == LKFilterTypeDistance) {
            [self setCheckmarkAtIndex:[LKDefaults distance]];
        }
        if (_filterType == LKFilterTypeSortBy) {
            [self setCheckmarkAtIndex:[LKDefaults sortBy]];
        }
    }
    return self;
}

- (void)animateIn
{
    CABasicAnimation *animation1 = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation1.fromValue = [NSNumber numberWithFloat:0.0];
    animation1.toValue = [NSNumber numberWithFloat:1.0];
    animation1.duration = 0.2;
    self.alpha = 1.0;
    [self.layer addAnimation:animation1 forKey:@"animation1"];
    
    CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"position"];
    CGPoint position = self.layer.position;
    CGFloat height = CGRectGetHeight(self.frame);
    animation2.fromValue = [NSValue valueWithCGPoint:position];
    position.y += height;
    animation2.toValue = [NSValue valueWithCGPoint:position];
    self.layer.position = position;
    animation2.duration = 0.2;
    [self.layer addAnimation:animation2 forKey:@"animation2"];
}

- (void)animateOut
{
    CABasicAnimation *animation1 = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation1.fromValue = [NSNumber numberWithFloat:1.0];
    animation1.toValue = [NSNumber numberWithFloat:0.0];
    animation1.duration = 0.2;
    self.alpha = 0.0;
    [self.layer addAnimation:animation1 forKey:@"animation1"];
    
    CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"position"];
    CGPoint position = self.layer.position;
    CGFloat height = CGRectGetHeight(self.frame);
    animation2.fromValue = [NSValue valueWithCGPoint:position];
    position.y -= height;
    animation2.toValue = [NSValue valueWithCGPoint:position];
    self.layer.position = position;
    animation2.duration = 0.2;
    [self.layer addAnimation:animation2 forKey:@"animation2"];
}

- (void)buttonSelected:(UIButton *)sender
{
    int index = sender.tag - kButtonTagOffset;
    if (_filterType == LKFilterTypeDistance)
        [LKDefaults setDistance:index];
    if (_filterType == LKFilterTypeSortBy)
        [LKDefaults setSortBy:index];
    [self animateOut];
    [self setCheckmarkAtIndex:index];
    [_delegate dropDownOptionDidSelect:index type:_filterType];
}

- (void)setCheckmarkAtIndex:(int)index
{
    _checkmark.center = CGPointMake(280, index * kCellHeight + 30.0);
}

@end
