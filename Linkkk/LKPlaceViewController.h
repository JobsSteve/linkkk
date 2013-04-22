//
//  LKPlaceViewController.h
//  Linkkk
//
//  Created by Vincent Wen on 4/21/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LKPlace;
@class LKPlaceView;

@interface LKPlaceViewController : UIViewController
@property (nonatomic, strong) LKPlace *place;
@property (nonatomic, strong) IBOutlet LKPlaceView *placeView;
@end
