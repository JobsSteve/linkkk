//
//  UIBarButtonItem+Linkkk.m
//  Linkkk
//
//  Created by Vincent Wen on 4/26/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import "UIBarButtonItem+Linkkk.h"
#import "UIColor+Linkkk.h"

@implementation UIBarButtonItem (Linkkk)

+ (UIBarButtonItem *)customBackButtonWithTarget:(id)target action:(SEL)action
{
    return [UIBarButtonItem customButtonWithIcon:@"" Target:target action:action];
}

+ (UIBarButtonItem *)customButtonWithIcon:(NSString *)icon Target:(id)target action:(SEL)action
{
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
    backButton.titleLabel.font = [UIFont fontWithName:@"Entypo" size:80.0];
    [backButton setTitle:icon forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor specialBlue] forState:UIControlStateNormal];
    [backButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:backButton];
}

+ (UIBarButtonItem *)customButtonWithName:(NSString *)name target:(id)target action:(SEL)action
{
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    backButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [backButton setTitle:name forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor specialBlue] forState:UIControlStateNormal];
    [backButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:backButton];
}

+ (UILabel *)customTitleLabelWithString:(NSString *)title
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = [UIFont boldSystemFontOfSize:20.0];
    label.textColor = [UIColor specialBlue];
    label.text = title;
    [label sizeToFit];
    return label;
}

@end
