//
//  UIButton+Linkkk.m
//  Linkkk
//
//  Created by Vincent Wen on 5/11/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import "UIButton+Linkkk.h"
#import "UIColor+Linkkk.h"

@implementation UIButton (Linkkk)

- (void)setTitleWithString:(NSString *)title
{
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:title];
    NSRange range = NSMakeRange(title.length - 1, 1);
    [string addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Entypo" size:30.0] range:range];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor specialBlue] range:NSMakeRange(0, string.length)];
    [self setAttributedTitle:string forState:UIControlStateNormal];
    [self sizeToFit];
}

- (void)setImage:(UIImage *)image
{
    [self setImage:image forState:UIControlStateNormal];
}

- (UIImage *)image
{
    return [self imageForState:UIControlStateNormal];
}

@end
