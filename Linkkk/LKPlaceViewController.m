//
//  LKPlaceViewController.m
//  Linkkk
//
//  Created by Vincent Wen on 4/21/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import "LKPlaceViewController.h"
#import "LKPlace.h"
#import "LKPlaceView.h"

@interface LKPlaceViewController ()

@end

@implementation LKPlaceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _placeView.titleLabel.text = _place.title;
    _placeView.addressLabel.text = _place.address;
    _placeView.textView.text = _place.content;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
