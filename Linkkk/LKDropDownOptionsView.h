//
//  LKDropDownOptionsView.h
//  Linkkk
//
//  Created by Vincent Wen on 5/22/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LKFilterDistance) {
    LKFilterDistance500,
    LKFilterDistance1000,
    LKFilterDistance3000,
    LKFilterDistance10000
};

typedef NS_ENUM(NSInteger, LKFilterSortBy) {
    LKFilterSortByDistance,
    LKFilterSortByFavourite,
    LKFilterSortByComment,
    LKFilterSortByDate
};

typedef NS_ENUM(NSInteger, LKFilterType) {
    LKFilterTypeDistance,
    LKFilterTypeSortBy
};

@protocol LKDropDownOptionsDelegate;

@interface LKDropDownOptionsView : UIView

@property (strong, nonatomic) NSArray *options;
@property (assign, nonatomic) LKFilterType filterType;
@property (assign, nonatomic) id<LKDropDownOptionsDelegate> delegate;

- (id)initWithOptions:(NSArray *)options type:(LKFilterType)type;
- (void)animateIn;
- (void)animateOut;

@end
