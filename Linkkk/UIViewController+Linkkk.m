//
//  UIViewController+Linkkk.m
//  Linkkk
//
//  Created by Vincent Wen on 5/6/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import "UIViewController+Linkkk.h"

@implementation UIViewController (Linkkk)

+ (void)showErrorView:(NSString *)description
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"数据加载失败" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
        [alertView show];
    });
}

@end
