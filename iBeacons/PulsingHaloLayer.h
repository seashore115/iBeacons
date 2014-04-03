
//
//  Created by Apple on 12/5/13.
//  Copyright (c) 2013 Apple. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>


@interface PulsingHaloLayer : CALayer

@property (nonatomic, assign) CGFloat radius;                   // default:60pt
@property (nonatomic, assign) NSTimeInterval animationDuration; // default:3s
@property (nonatomic, assign) NSTimeInterval pulseInterval; // default is 0s

@end
