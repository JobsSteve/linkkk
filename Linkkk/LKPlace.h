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
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *time_start;
@property (nonatomic, strong) NSString *time_end;
@property (nonatomic, strong) NSString *time_desc;
@property (nonatomic, strong) NSString *contact;
@property (nonatomic, strong) NSDictionary *author;

@property (nonatomic, strong) NSArray *album;

@property (nonatomic, assign) int placeID;
@property (nonatomic, assign) int fav_count;
@property (nonatomic, assign) int comment_count;
@property (nonatomic, assign) int score;
@property (nonatomic, assign) int distance;
@property (nonatomic, assign) BOOL hasFaved;
@property (nonatomic, assign) CLLocationCoordinate2D pt;

- (id)initWithJSON:(NSDictionary *)dict;

@end
