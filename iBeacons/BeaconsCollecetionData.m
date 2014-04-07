//
//  BeaconsCollecetionData.m
//  iBeacons
//
//  Created by Apple on 14-4-5.
//  Copyright (c) 2014年 meng.wang. All rights reserved.
//

#import "BeaconsCollecetionData.h"

@implementation BeaconsCollecetionData
+(BeaconsCollecetionData *)getInstance{
    static dispatch_once_t onceToken;
    static BeaconsCollecetionData* instance=nil;
    static NSMutableArray* sendData;
    dispatch_once(&onceToken,^{
        instance=[[self alloc]init];
        sendData=[[NSMutableArray alloc]init];
    });
    return instance;
}
@end
