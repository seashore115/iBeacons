//
//  BeaconTestViewController.h
//  iBeacons
//
//  Created by Apple on 14-3-18.
//  Copyright (c) 2014年 meng.wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BeaconTestViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    IBOutlet UITableView *tableView;
}
@property (weak, nonatomic)NSString* roomNameBeacon;
@property (weak, nonatomic)NSString* uploadFloorPlanIdBeacon;
@property(nonatomic,retain)IBOutlet UITableView *tableView;
@property(nonatomic,retain)IBOutlet UILabel *room;
@property(nonatomic,copy)NSArray *beaconArray;
@property(nonatomic,strong)NSString *matchMajor;
@end
