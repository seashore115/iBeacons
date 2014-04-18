//
//  MagneticTestViewController.m
//  iBeacons
//
//  Created by Apple on 14-3-18.
//  Copyright (c) 2014年 meng.wang. All rights reserved.
//

#import "MagneticTestViewController.h"
#import "ESTBeaconManager.h"
#import "CustomButton.h"
#import "ATMHud.h"
#import "ATMHudQueueItem.h"
#import "XYAlertViewHeader.h"

#define DOT_MIN_POS 120
#define DOT_MAX_POS screenHeight - 70;

@interface MagneticTestViewController ()<ESTBeaconManagerDelegate>
@property (nonatomic, strong) ESTBeaconManager* beaconManager;
@property (nonatomic, strong) UIImageView*      positionDot;

@property (nonatomic) float dotMinPos;
@property (nonatomic) float dotRange;

@end

@implementation MagneticTestViewController
@synthesize roomNameMagnetic;
@synthesize uploadFloorPlanIdMagnetic;
@synthesize hud;
@synthesize beaconArray;
@synthesize beaconMajorMinorDistance;
@synthesize beaconsCount;
@synthesize sendData;
@synthesize outputString;
- (void)setupBackgroundImage
{
    CGRect          screenRect          = [[UIScreen mainScreen] bounds];
    CGFloat         screenHeight        = screenRect.size.height;
    UIImageView*    backgroundImage;
    
    if (screenHeight > 480)
    {
        backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"backgroundBig"]];
        backgroundImage.frame=CGRectMake(0, 50, screenRect.size.width, screenHeight);

    }
    else
    {
        backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"backgroundSmall"]];
    }
    
    [backgroundImage setUserInteractionEnabled:TRUE];
    CustomButton *button = [[CustomButton alloc] initWithFrame:CGRectMake(124, 400, 75, 30)];
    [button addTarget:self action:@selector(record) forControlEvents:UIControlEventTouchUpInside];
//    CustomButton *sendMailButton=[[CustomButton alloc] initWithFrame:CGRectMake(124, 440, 75, 30)];
//    [sendMailButton addTarget:self action:@selector(sendMail) forControlEvents:UIControlEventTouchUpInside];
    hud = [[ATMHud alloc] initWithDelegate:self];
//    [backgroundImage addSubview:sendMailButton];
    [backgroundImage addSubview:button];
    [backgroundImage addSubview:hud.view];
    [self.view addSubview:backgroundImage];

}

- (void)setupDotImage
{
    self.positionDot = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dotImage"]];
    [self.positionDot setCenter:self.view.center];
    [self.positionDot setAlpha:1.0f];
    
    [self.view addSubview:self.positionDot];
    
    self.dotMinPos = 150;
    self.dotRange = self.view.bounds.size.height  - 220;
}

- (void)setupView
{
    [self setupBackgroundImage];
    [self setupDotImage];
}

- (void)setupManager
{
    // create manager instance
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    
    // create sample region object (you can additionaly pass major / minor values)
    ESTBeaconRegion* region = [[ESTBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID
                                                                  identifier:@"EstimoteSampleRegion"];
    
    // start looking for estimote beacons in region
    // when beacon ranged beaconManager:didRangeBeacons:inRegion: invoked
    [self.beaconManager startRangingBeaconsInRegion:region];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

//    NSLog(@"%@",roomNameMagnetic);
//    NSLog(@"%@",uploadFloorPlanIdMagnetic);
    beaconMajorMinorDistance=[NSMutableArray arrayWithCapacity:10];
//    obj=[BeaconsCollecetionData getInstance];
//    sendData=obj.sendData;
    [self setupManager];
    [self setupView];
     outputString=@"";
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"Send" style:UIBarButtonItemStyleBordered target:self action:@selector(sendMail)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)beaconManager:(ESTBeaconManager *)manager
     didRangeBeacons:(NSArray *)beacons
            inRegion:(ESTBeaconRegion *)region
{
    if([beacons count] > 0)
    {
        // based on observation rssi is not getting bigger then -30
        // so it changes from -30 to -100 so we normalize
        ESTBeacon *beacon=[beacons objectAtIndex:0];
        float distFactor = ((float)beacon.rssi + 30) / -70;
        
        // calculate and set new y position
        float newYPos = self.dotMinPos + distFactor * self.dotRange-50;
        self.positionDot.center = CGPointMake(self.view.bounds.size.width / 2, newYPos);
        beaconArray=beacons;
    }
}

-(void)record{
    [hud setBlockTouches:YES];
    ATMHudQueueItem *item = [[ATMHudQueueItem alloc] init];
    item.caption = @"Record #1";
    item.image = nil;
    item.accessoryPosition = ATMHudAccessoryPositionBottom;
    item.showActivity = NO;
    [hud addQueueItem:item];
    
    item = [[ATMHudQueueItem alloc] init];
    item.caption = @"Record #2";
    item.image = nil;
    item.accessoryPosition = ATMHudAccessoryPositionRight;
    item.showActivity = YES;
    [hud addQueueItem:item];
    
    item = [[ATMHudQueueItem alloc] init];
    item.caption = @"Record #3";
    item.image = nil;
    item.accessoryPosition = ATMHudAccessoryPositionRight;
    item.showActivity = YES;
    [hud addQueueItem:item];
    
    item = [[ATMHudQueueItem alloc] init];
    item.caption = @"Record #4";
    item.image = nil;
    item.accessoryPosition = ATMHudAccessoryPositionRight;
    item.showActivity = YES;
    [hud addQueueItem:item];
    
    item = [[ATMHudQueueItem alloc] init];
    item.caption = @"Record #5";
    item.image = nil;
    item.accessoryPosition = ATMHudAccessoryPositionRight;
    item.showActivity = YES;
    [hud addQueueItem:item];
    
    item = [[ATMHudQueueItem alloc] init];
    item.caption = @"Record #6";
    item.image = nil;
    item.accessoryPosition = ATMHudAccessoryPositionRight;
    item.showActivity = YES;
    [hud addQueueItem:item];
    
    item = [[ATMHudQueueItem alloc] init];
    item.caption = @"Record #7";
    item.image = nil;
    item.accessoryPosition = ATMHudAccessoryPositionRight;
    item.showActivity = YES;
    [hud addQueueItem:item];
    
    item = [[ATMHudQueueItem alloc] init];
    item.caption = @"Record #8";
    item.image = nil;
    item.accessoryPosition = ATMHudAccessoryPositionRight;
    item.showActivity = YES;
    [hud addQueueItem:item];
    
    item = [[ATMHudQueueItem alloc] init];
    item.caption = @"  Done  ";
    item.image = [UIImage imageNamed:@"19-check"];
    item.accessoryPosition = ATMHudAccessoryPositionBottom;
    item.showActivity = NO;
    [hud addQueueItem:item];
    
    [hud startQueue];
    [self performSelector:@selector(showNextDisplayInQueue) withObject:nil afterDelay:2];
}

- (void)showNextDisplayInQueue {
	static int i = 1;
	[hud showNextInQueue];
	if (i < 9) {
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self beaconMessage];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSelector:@selector(showNextDisplayInQueue) withObject:nil afterDelay:2.0];
                i++;
            });
        });
        

	} else {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self writeFile];
            dispatch_async(dispatch_get_main_queue(), ^{
                i = 1;
                [hud clearQueue];
            });
        });
        

	}
}

-(void)beaconMessage{
    
    //Get Message
//    NSLog(@"%i",[beaconArray count]);
   
    for (ESTBeacon *beacon in beaconArray) {
        float rawDistance=[beacon.distance floatValue];
        outputString=[outputString stringByAppendingFormat:@"%i,%i,%.3f,%@\n",[beacon.major unsignedShortValue],[beacon.minor unsignedShortValue],rawDistance,roomNameMagnetic];
         NSLog(@"%@",outputString);
//        NSString *beaconDistance=[NSString stringWithFormat:@" Distance: %.3f",rawDistance];
//        NSString *majorAndMinor=[NSString stringWithFormat:
//                                 @"Major: %i, Minor: %i",
//                                 [beacon.major unsignedShortValue],
//                                  [beacon.minor unsignedShortValue]];
//        NSString *beaconMessage=[majorAndMinor stringByAppendingString:beaconDistance];
//        [beaconMajorMinorDistance addObject:beaconMessage];
    }
//    NSLog(@"%@",[beaconMajorMinorDistance description]);
   
}

-(void)writeFile{
//    NSLog(@"%ld",(long)beaconsCount);
//        NSMutableDictionary *dictionary=[[NSMutableDictionary alloc]initWithCapacity:3];
//        [dictionary setObject:uploadFloorPlanIdMagnetic forKey:@"id"];
//        [dictionary setObject:roomNameMagnetic forKey:@"room"];
//        [dictionary setObject:beaconMajorMinorDistance forKey:@"message"];
        NSLog(@"%@",outputString);
    //Read File in local
        NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString* filename=[NSString stringWithFormat:@"%@.csv",uploadFloorPlanIdMagnetic];
        NSString* foofile = [documentsPath stringByAppendingPathComponent:filename];
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:foofile];
        NSError *csvError = NULL;
    if (fileExists) {
        NSString *string=[NSString stringWithContentsOfFile:foofile encoding:NSUTF8StringEncoding error:nil];
        outputString=[string stringByAppendingString:outputString];
        [outputString writeToFile:foofile atomically:YES encoding:NSUTF8StringEncoding error:&csvError];
        NSLog(@"******%@",csvError);
    }else{
        outputString=[@"major,minor,distance,room\n" stringByAppendingString:outputString];
        [outputString writeToFile:foofile atomically:YES encoding:NSUTF8StringEncoding error:&csvError];
         NSLog(@"----%@",csvError);
    }
//        NSArray *messageArray=[NSArray arrayWithContentsOfFile:foofile];
//        sendData=[[NSMutableArray alloc]initWithCapacity:10];
//        if (fileExists) {
//            NSDictionary *dict, *dict0;
//            for (dict in messageArray) {
////                NSLog(@"%@",[dict description]);
//                [sendData addObject:dict];
//            }
////            NSLog(@"count is %lu",(unsigned long)[sendData count]);
//            BOOL flag=false;
//            if ([messageArray count]<beaconsCount) {
//                
//                for (int i=0; i<[sendData count] ; i++) {
//                    dict0=[sendData objectAtIndex:i];
////                    NSLog(@"%@",[dict0 objectForKey:@"room"]);
//                    if ([roomNameMagnetic isEqualToString:[dict0 objectForKey:@"room"]]) {
//                        [sendData removeObject:dict0];
//                        flag=true;
////                        NSLog(@"%@",[sendData description]);
//                        [sendData addObject:dictionary];
//                    }
//                }
//                
//                if (!flag) {
////                    NSLog(@"----------");
//                    [sendData addObject:dictionary];
//                    goto end;
//
//                }
//                
//            }else{
//                NSDictionary *dict1;
//                for (int i=0; i< beaconsCount; i++) {
//                    dict1=[messageArray objectAtIndex:i];
//                    if ([roomNameMagnetic isEqualToString:[dict1 objectForKey:@"room"]]){
//                        [sendData removeObject:dict1];
//                        [sendData addObject:dictionary];
//                    }
//                }
//            }
//        }else{
//            [[NSFileManager defaultManager] createFileAtPath:foofile contents:nil attributes:nil];
//            [sendData addObject:dictionary];
//        }end:
    

//        if (fileExists) {
//            NSArray *messageArray=[NSArray arrayWithContentsOfFile:foofile];
//            NSDictionary *dict;
//            NSLog(@"%lu",(unsigned long)[messageArray count]);
//            for (int i=0; i< beaconsCount; i++) {
//                dict=[messageArray objectAtIndex:i];
//                if (beaconsCount==[messageArray count]) {
//                    if ([roomNameMagnetic isEqualToString:[dict objectForKey:@"room"]]){
//                        [sendData removeObject:dict];
//                        [sendData addObject:dictionary];
//                    }
//                }else{
//                    if ([roomNameMagnetic isEqualToString:[dict objectForKey:@"room"]]){
//                        [sendData removeObject:dict];
//                        [sendData addObject:dictionary];
//                    }else{
//                       [sendData addObject:dict];
//                        if (i+1==[messageArray count]) {
//                            NSLog(@"1");
//                            [sendData addObject:dictionary];
//                            NSLog(@"%@",[sendData description]);
//                        }
//
//                    }
//
//                }
//            }
//        }else{
//            [[NSFileManager defaultManager] createFileAtPath:foofile contents:nil attributes:nil];
//            [sendData addObject:dictionary];
//        }
    
    //Write File in local
//    [sendData writeToFile:foofile atomically:YES];
//    NSLog(@"%@",[sendData description]);
}

-(void)displayContent{
//    // create a loading view
//    XYLoadingView *loadingView = [XYLoadingView loadingViewWithMessage:@"Loading will complete in 2 seconds..."];
//    
//    // display
//    [loadingView show];
//    
//    // read message from file
//    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    NSString* filename=[NSString stringWithFormat:@"%@.csv",uploadFloorPlanIdMagnetic];
//    NSString* foofile = [documentsPath stringByAppendingPathComponent:filename];
//    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:foofile];
////    NSArray *messageArray=[NSArray arrayWithContentsOfFile:foofile];
//    NSMutableString* beaconsMessage=[[NSMutableString alloc]init];
//    if (fileExists) {
////        for (NSObject* obj in messageArray) {
////            [beaconsMessage appendString:[obj description]];
////        }
//        beaconsMessage=[NSMutableString stringWithString: @"Message has been recorded"];
//    }else{
//        beaconsMessage=[NSMutableString stringWithString: @"No message has been recorded"];
//    }
    
//    // dismiss loading view with popup message after 5 seconds
//    [loadingView performSelector:@selector(dismissWithMessage:) withObject:beaconsMessage afterDelay:2];
    
    
}

-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    if (event.subtype == UIEventSubtypeMotionShake) {
        //shake
        NSString* path=[[NSBundle mainBundle] pathForResource:@"sound" ofType:@"wav"];
        NSURL* fileURL=[[NSURL alloc]initFileURLWithPath:path];
        self.theAudio=[[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:NULL];
        self.theAudio.volume = 0.7;
        
//        self.theAudio.delegate = self;
        
        [self.theAudio prepareToPlay];
        [self removeFile];
        [self.theAudio play];
    }
    
    if ([super respondsToSelector:@selector(motionEnded:withEvent:)]) {
        [super motionEnded:motion withEvent:event];
    }
}

-(BOOL)canBecomeFirstResponder{
    return YES;
}


-(void)removeFile{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* filename=[NSString stringWithFormat:@"%@.csv",uploadFloorPlanIdMagnetic];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:filename];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    if (success) {
        XYShowAlert(@"Record is successfully removed");
//        UIAlertView *removeSuccessFulAlert=[[UIAlertView alloc]initWithTitle:@"Attention:" message:@"Record is successfully removed" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
//        [removeSuccessFulAlert show];
    }
    else
    {
        
        XYShowAlert(@"No recorded message already!");
    }
}

-(void)sendMail{
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* filename=[NSString stringWithFormat:@"%@.csv",uploadFloorPlanIdMagnetic];
    NSString* foofile = [documentsPath stringByAppendingPathComponent:filename];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:foofile];
    //    NSArray *messageArray=[NSArray arrayWithContentsOfFile:foofile];
    if (fileExists) {
        //        for (NSObject* obj in messageArray) {
        //            [beaconsMessage appendString:[obj description]];
        //        }
        NSString *emailTitle=[NSString stringWithFormat:@"%@.csv Document",uploadFloorPlanIdMagnetic];
        NSString *messageBody=@"This document needs to be processed";
        NSArray *toRecipents = [NSArray arrayWithObject:@"wangmeng.icarus@gmail.com"];
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setSubject:emailTitle];
        [mc addAttachmentData:[NSData dataWithContentsOfFile:foofile] mimeType:@"text/csv" fileName:filename];
        [mc setMessageBody:messageBody isHTML:NO];
        [mc setToRecipients:toRecipents];
        [self presentViewController:mc animated:YES completion:NULL];
    }else{
        XYShowAlert(@"Please record first");
    }

   
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
