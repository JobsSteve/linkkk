//
//  LKMainView.h
//  Linkkk
//
//  Created by Vincent Wen on 4/21/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LKShakeProtocol;

@interface LKMainView : UIView

@property (nonatomic, strong) id<LKShakeProtocol> delegate;

@end
