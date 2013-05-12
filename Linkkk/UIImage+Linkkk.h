//
//  UIImage+Linkkk.h
//  Linkkk
//
//  Created by Vincent Wen on 5/11/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Linkkk)

- (UIImage *)normalizedImage;
+ (float)strategicRatioWithDataSize:(int)size;
+ (CGSize)strategicSizeWithImageSize:(CGSize)size;

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

@end
