//
//  MagneticTestViewController.h
//  iBeacons
//
//  Created by Apple on 14-3-18.
//  Copyright (c) 2014年 meng.wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATMHudDelegate.h"
#import "BeaconsCollecetionData.h"
#import <AVFoundation/AVAudioPlayer.h>
@class ATMHud;

@interface MagneticTestViewController : UIViewController<ATMHudDelegate>{
    ATMHud *hud;
    BeaconsCollecetionData *obj;
}
@property (weak, nonatomic)NSString* roomNameMagnetic;
@property (weak, nonatomic)NSString* uploadFloorPlanIdMagnetic;
@property (nonatomic, retain)ATMHud* hud;
@property (nonatomic, copy)NSArray*  beaconArray;
@property (nonatomic, copy)NSMutableArray* beaconMajorMinorDistance;
@property (nonatomic)NSInteger beaconsCount;
@property (nonatomic, strong)NSMutableArray* sendData;
@property (nonatomic, strong)AVAudioPlayer* theAudio;
@end
