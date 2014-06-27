//
//  PredictTableViewController.h
//  iBeacons
//
//  Created by Apple on 14-6-26.
//  Copyright (c) 2014年 meng.wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface PredictTableViewController : UITableViewController<CLLocationManagerDelegate>{
    CLLocationManager *locationManager;
}
@property (strong, nonatomic)NSString* distance;
@property (strong,nonatomic)NSString* xValue;
@property (strong,nonatomic)NSString* yValue;
@property (strong,nonatomic)NSString* zValue;
@property (strong,nonatomic)NSString* longitude;
@property (strong,nonatomic)NSString* latitude;
@property (strong,nonatomic)NSString* roomName;
@property (strong,nonatomic)NSString* floorPlanId;
@property (nonatomic,strong)NSTimer *time;
@property (nonatomic, copy)NSArray*  beaconArray;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic,strong)NSDictionary *json;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
//@property (nonatomic)int sum;
//@property (nonatomic)int correctSumOne;
//@property (nonatomic)int correctSumTwo;
//@property (nonatomic)int correctSumThree;


@end
