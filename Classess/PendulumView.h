//
//  PendulumView.h
//  PendulumView
//
//  Created by Apple on 14-1-19.
//  Copyright (c) 2014年 meng.wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PendulumView : UIView

- (id)initWithFrame:(CGRect)frame;
- (id)initWithFrame:(CGRect)frame ballColor:(UIColor *)ballColor;

- (void)startAnimating;
- (void)stopAnimating;
- (BOOL)isAnimating;

@end
