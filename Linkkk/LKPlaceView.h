//
//  LKPlaceView.h
//  Linkkk
//
//  Created by Vincent Wen on 4/16/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LKShakeProtocol;

@interface LKPlaceView : UIScrollView

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UIView *containerView;

@property (strong, nonatomic) IBOutlet UIImageView *photoView1;
@property (strong, nonatomic) IBOutlet UIImageView *photoView2;
@property (strong, nonatomic) IBOutlet UIImageView *photoView3;

@property (nonatomic, assign) id<LKShakeProtocol> shakeDelegate;

@end
