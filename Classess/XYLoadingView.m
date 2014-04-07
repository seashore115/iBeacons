//
//  XYLoadingView.m
//
//  Created by Apple on 7/25/12.
//  Copyright (c) 2012 meng.wang. All rights reserved.
//

#import "XYLoadingView.h"

@implementation XYLoadingView

@synthesize message = _message;

+(id)loadingViewWithMessage:(NSString *)message
{
    return [[XYLoadingView alloc] initWithMessaege:message];
}

-(id)initWithMessaege:(NSString *)message
{
    self = [self init];
    if(self)
    {
        self.message = message;
    }
    return self;
}

-(void)show
{
    [[XYAlertViewManager sharedAlertViewManager] show:self];
}

-(void)dismiss
{
    [[XYAlertViewManager sharedAlertViewManager] dismiss:self];
}

-(void)dismissWithMessage:(NSString*)message
{
    [[XYAlertViewManager sharedAlertViewManager] dismissLoadingView:self withFailedMessage:message];
}

@end
