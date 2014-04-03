//
//  MenuViewController.h
//  iBeacons
//
//  Created by Apple on 14-3-5.
//  Copyright (c) 2014年 meng.wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuViewController : UITableViewController{
    NSString *floorPlanId;
    NSString *titleChoose;
}
@property NSString *subUrlString;
@property (nonatomic)NSInteger index;
@property (nonatomic,retain)NSString* floorPlanId;
@property (nonatomic,retain)NSString* titleChoose;
@end
