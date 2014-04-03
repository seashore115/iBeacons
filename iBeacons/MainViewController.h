//
//  MainViewController.h
//  iBeacons
//
//  Created by Apple on 14-3-3.
//  Copyright (c) 2014年 meng.wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuViewController.h"
#import "EAIntroView.h"

@interface MainViewController : UIViewController<EAIntroDelegate>
@property (strong, nonatomic) IBOutlet UITextField *textInputBox;

-(IBAction)viewDown:(id)sender;

@end
