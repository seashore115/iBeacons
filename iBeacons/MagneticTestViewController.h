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
#import <MessageUI/MessageUI.h>
#import <CoreLocation/CoreLocation.h>
@class ATMHud;

@interface MagneticTestViewController : UIViewController<ATMHudDelegate,MFMailComposeViewControllerDelegate,CLLocationManagerDelegate>{
    ATMHud *hud;
    BeaconsCollecetionData *obj;
    NSString *outputString;
    CLLocationManager *locationManager;
}
@property (weak, nonatomic)NSString* roomNameMagnetic;
@property (weak, nonatomic)NSString* uploadFloorPlanIdMagnetic;
@property (nonatomic, retain)ATMHud* hud;
@property (nonatomic, copy)NSArray*  beaconArray;
@property (nonatomic, copy)NSMutableArray* beaconMajorMinorDistance;
@property (nonatomic)NSInteger beaconsCount;
@property (nonatomic, strong)NSMutableArray* sendData;
@property (nonatomic, strong)AVAudioPlayer* theAudio;
@property (nonatomic, strong)NSString *outputString;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (strong,nonatomic)NSString* xValue;
@property (strong,nonatomic)NSString* yValue;
@property (strong,nonatomic)NSString* zValue;
@property (strong,nonatomic)NSString* latitude;
@property (strong,nonatomic)NSString* longitude;
@property (strong,nonatomic)NSString* outputFrontString;
@end
