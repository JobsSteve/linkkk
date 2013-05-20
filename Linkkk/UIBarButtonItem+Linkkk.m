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
    return [UIBarButtonItem customButtonWithIcon:@"" size:50.0 target:target action:action];
}

+ (UIBarButtonItem *)customBackButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action
{
    CGRect frame = CGRectMake(0, 0, 150, 30);
    UIView *view = [[UIView alloc] initWithFrame:frame];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(40, 2, 2, 26)];
    imageView.image = [UIImage imageNamed:@"verticalpixel"];
    [view addSubview:imageView];
    
    CGRect labelFrame = CGRectMake(55, 0, 95, 30);
    UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
    label.font = [UIFont boldSystemFontOfSize:18];
    label.textColor = [UIColor specialBlue];
    label.text = title;
    [label sizeToFit];
    labelFrame.size.width = CGRectGetWidth(label.frame);
    label.frame = labelFrame;
    [view addSubview:label];
    
    frame.size.width = CGRectGetMaxX(label.frame) + 10.0;
    view.frame = frame;
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
    backButton.titleLabel.font = [UIFont fontWithName:@"Entypo" size:50.0];
    [backButton setTitle:@"" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor specialBlue] forState:UIControlStateNormal];
    [backButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:backButton];
    
    return [[UIBarButtonItem alloc] initWithCustomView:view];
}

+ (UIBarButtonItem *)customRightButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action
{
    CGRect frame = CGRectMake(0, 0, 85, 30);
    UIView *view = [[UIView alloc] initWithFrame:frame];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 2, 2, 26)];
    imageView.image = [UIImage imageNamed:@"verticalpixel"];
    [view addSubview:imageView];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(13, 0, 80, 44)];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:title];
    NSRange range = NSMakeRange(title.length - 1, 1);
    [string addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Entypo" size:30.0] range:range];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor specialBlue] range:NSMakeRange(0, string.length)];
    [button setAttributedTitle:string forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    [view addSubview:button];
    
    return [[UIBarButtonItem alloc] initWithCustomView:view];
}

+ (UIBarButtonItem *)customButtonWithIcon:(NSString *)icon size:(CGFloat)size target:(id)target action:(SEL)action
{
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
    backButton.titleLabel.font = [UIFont fontWithName:@"Entypo" size:size];
    [backButton setTitle:icon forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor specialBlue] forState:UIControlStateNormal];
    [backButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:backButton];
}

+ (UIBarButtonItem *)customButtonWithName:(NSString *)name target:(id)target action:(SEL)action
{
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    backButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [backButton setTitle:name forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor specialBlue] forState:UIControlStateNormal];
    [backButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:backButton];
}

+ (UILabel *)customTitleLabelWithString:(NSString *)title
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = [UIFont boldSystemFontOfSize:18.0];
    label.textColor = [UIColor specialBlue];
    label.text = title;
    [label sizeToFit];
    return label;
}

+ (UIButton *)customTitleButtonWithString:(NSString *)title target:(id)target action:(SEL)action
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 44)];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:title];
    NSRange range = NSMakeRange(title.length - 1, 1);
    [string addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Entypo" size:30.0] range:range];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor specialBlue] range:NSMakeRange(0, string.length)];
    [button setAttributedTitle:string forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    return button;
}

@end
