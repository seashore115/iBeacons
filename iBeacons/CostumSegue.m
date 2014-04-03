//
//  CostumSegue.m
//  ar
//
//  Created by Apple on 13-11-4.
//  Copyright (c) 2013年 meng.wang. All rights reserved.
//

#import "CostumSegue.h"
#import <QuartzCore/QuartzCore.h>

@implementation CostumSegue
-(void)perform {
    
    UIViewController *sourceViewController = (UIViewController*)[self sourceViewController];
    UIViewController *destinationController = (UIViewController*)[self destinationViewController];
    
    CATransition* transition = [CATransition animation];
    transition.duration = .75;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = @"cameraIrisHollowOpen";
         //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade//kCATransitionPush
//         
//     animation.type = @"cube";
//     
//     
//     animation.type = @"suckEffect";
//     
//     
//     animation.type = @"oglFlip";
//     
//     
//     animation.type = @"rippleEffect";
//     
//     
//     animation.type = @"pageCurl";
//     
//     
//     animation.type = @"pageUnCurl";
//     
//     
//     animation.type = @"cameraIrisHollowOpen";
//     
//     
//     animation.type = @"cameraIrisHollowClose";
    
    
    
    transition.subtype = kCATransitionFromLeft; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
    
    
    
    [sourceViewController.navigationController.view.layer addAnimation:transition
                                                                forKey:kCATransition];
    
    [sourceViewController.navigationController pushViewController:destinationController animated:NO];
    
}

@end
