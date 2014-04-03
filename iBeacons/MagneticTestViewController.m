//
//  MagneticTestViewController.m
//  iBeacons
//
//  Created by Apple on 14-3-18.
//  Copyright (c) 2014年 meng.wang. All rights reserved.
//

#import "MagneticTestViewController.h"

@interface MagneticTestViewController ()

@end

@implementation MagneticTestViewController
@synthesize roomNameMagnetic;
@synthesize uploadFloorPlanIdMagnetic;
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
    NSLog(@"%@",roomNameMagnetic);
    NSLog(@"%@",uploadFloorPlanIdMagnetic);
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
