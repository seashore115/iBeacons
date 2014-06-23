//
//  BeaconsCollecetionData.m
//  iBeacons
//
//  Created by Apple on 14-4-5.
//  Copyright (c) 2014年 meng.wang. All rights reserved.
//

#import "BeaconsCollecetionData.h"

@implementation BeaconsCollecetionData

@synthesize currentRoomName;
@synthesize floorPlan;
+ (instancetype) sharedManager {
    static BeaconsCollecetionData *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [self new];
    });
    return sharedMyManager;
}

- (id)init {
    self = [super init];
    if (self) {
        floorPlan=@"";
        currentRoomName=@"";
    }
    return self;
}
@end
