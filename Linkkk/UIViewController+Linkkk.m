//
//  UIViewController+Linkkk.m
//  Linkkk
//
//  Created by Vincent Wen on 5/6/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import "UIViewController+Linkkk.h"

@implementation UIViewController (Linkkk)

- (void)showErrorView:(NSString *)description
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误" message:description delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
    [alertView show];
}

@end