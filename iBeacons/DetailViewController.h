//
//  DetailViewController.h
//  iBeacons
//
//  Created by Apple on 14-3-5.
//  Copyright (c) 2014年 meng.wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "FXLabel.h"
#import "REMenu.h"



@interface DetailViewController : UIViewController<CLLocationManagerDelegate>{
//    UILabel *xLabel;
//    UILabel *yLabel;
//    UILabel *zLabel;
    CLLocationManager *locationManager;
   
}
//@property (strong, nonatomic) IBOutlet UILabel *iBeaconName;
//@property (strong, nonatomic) IBOutlet UILabel *iBeaconDistance;
//@property (strong, nonatomic) IBOutlet UILabel *xLabel;
//@property (strong, nonatomic) IBOutlet UILabel *yLabel;
//@property (strong, nonatomic) IBOutlet UILabel *zLabel;
//@property (strong, nonatomic) IBOutlet UILabel *iBeaconActualDistance;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (strong, nonatomic)NSString* roomName;
@property (strong, nonatomic)NSString* uploadFloorPlanId;
@property (nonatomic)NSInteger count;
@property (strong, nonatomic)NSString* distance;
@property (strong,nonatomic)NSString* xValue;
@property (strong,nonatomic)NSString* yValue;
@property (strong,nonatomic)NSString* zValue;
@property (strong, nonatomic) IBOutlet FXLabel *iBeaconTitle;
@property (strong,nonatomic) REMenu *test;
@property (strong,nonatomic)NSString *major;
@property (strong,nonatomic)NSString *minor;

@end
