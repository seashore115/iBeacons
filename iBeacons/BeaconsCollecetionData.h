//
//  BeaconsCollecetionData.h
//  iBeacons
//
//  Created by Apple on 14-4-5.
//  Copyright (c) 2014年 meng.wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BeaconsCollecetionData : NSObject{

NSString *floorPlan;
NSString *currentRoomName;
}

@property (nonatomic,copy) NSString* floorPlan;
@property (nonatomic,copy) NSString* currentRoomName;

+(instancetype) sharedManager;
@end
