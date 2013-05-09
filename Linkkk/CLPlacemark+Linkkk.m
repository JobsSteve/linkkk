//
//  CLPlacemark+Linkkk.m
//  Linkkk
//
//  Created by Vincent Wen on 5/8/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import "CLPlacemark+Linkkk.h"

const CLLocationCoordinate2D CLLocationCoordinateZero = {0.0, 0.0};

@implementation CLPlacemark (Linkkk)

- (NSString *)city
{
    NSString *name = self.locality;
    if (name == nil) name = self.subLocality;
    if (name == nil) name = self.subAdministrativeArea;
    if (name == nil) name = self.administrativeArea;
    return name;
}

@end
