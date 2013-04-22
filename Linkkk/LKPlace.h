//
//  LKPlace.h
//  Linkkk
//
//  Created by Vincent Wen on 4/21/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LKPlace : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *address;

@property (nonatomic, assign) int distance;
@property (nonatomic, assign) CLLocationCoordinate2D location;

- (id)initWithJSON:(NSDictionary *)dict;

@end
