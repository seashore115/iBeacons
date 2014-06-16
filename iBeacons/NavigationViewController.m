//
//  NavigationViewController.m
//  iBeacons
//
//  Created by Apple on 14-6-3.
//  Copyright (c) 2014年 meng.wang. All rights reserved.
//

#import "NavigationViewController.h"
#import "MRoundedButton.h"
#import "UIImageView+LBBlurredImage.h"

@interface NavigationViewController ()

@end

@implementation NavigationViewController

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
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
//    [imageView setImageToBlur:[UIImage imageNamed:@"mcc"] completionBlock:NULL];
    [self.view addSubview:imageView];
    
    CGFloat backgroundViewHeight = ceilf(CGRectGetHeight([UIScreen mainScreen].bounds)/3);
    CGFloat backgroundViewWidth = CGRectGetWidth(self.view.bounds);
    CGRect backgroundRect = CGRectMake(0,
                                       backgroundViewHeight,
                                       backgroundViewWidth,
                                       backgroundViewHeight);
    MRHollowBackgroundView *backgroundView = [[MRHollowBackgroundView alloc] initWithFrame:backgroundRect];
    backgroundView.foregroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    [self.view addSubview:backgroundView];
    CGFloat buttonSize=140;
    CGRect buttonRect = CGRectMake((backgroundViewWidth - buttonSize) / 2.0,
                                   (backgroundViewHeight - buttonSize) / 2.0,
                                   buttonSize,
                                   buttonSize);
    MRoundedButton *button = [[MRoundedButton alloc] initWithFrame:buttonRect
                                                       buttonStyle:MRoundedButtonSubtitle
                                              appearanceIdentifier:[NSString stringWithFormat:@"%d",  1]];
    button.backgroundColor = [UIColor clearColor];
    button.textLabel.text = @"Where am I";
    button.textLabel.font = [UIFont boldSystemFontOfSize:80];
    button.detailTextLabel.text = @"";
    button.detailTextLabel.font = [UIFont systemFontOfSize:30];
    [backgroundView addSubview:button];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
