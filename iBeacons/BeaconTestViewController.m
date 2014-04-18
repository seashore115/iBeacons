//
//  BeaconTestViewController.m
//  iBeacons
//
//  Created by Apple on 14-3-18.
//  Copyright (c) 2014年 meng.wang. All rights reserved.
//

#import "BeaconTestViewController.h"
#import "ESTBeaconManager.h"
#import "PendulumView.h"
#import "CUSFlashLabel.h"

@interface BeaconTestViewController ()<ESTBeaconManagerDelegate>
@property (nonatomic,strong) ESTBeaconManager *beaconManager;
@property (nonatomic, strong) ESTBeacon* selectedBeacon;
@property (nonatomic,strong) CUSFlashLabel *actualRoom;
@property (nonatomic,strong) CUSFlashLabel *sentence;
@end

@implementation BeaconTestViewController
@synthesize tableView;
@synthesize roomNameBeacon;
@synthesize uploadFloorPlanIdBeacon;
@synthesize beaconArray;
@synthesize matchMajor;
@synthesize actualRoom;
@synthesize sentence;

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
//    NSLog(@"%@",roomNameBeacon);
//    NSLog(@"%@",uploadFloorPlanIdBeacon);
    self.tableView.bounces=YES;
    UIColor *ballColor=[UIColor colorWithRed:0.47 green:0.60 blue:0.89 alpha:1];
    PendulumView *pendulum=[[PendulumView alloc]initWithFrame:self.view.bounds ballColor:ballColor];
    [self.view addSubview:pendulum];
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    self.beaconManager.avoidUnknownStateBeacons = YES;
    ESTBeaconRegion* region = [[ESTBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID
                                                                  identifier:@"EstimoteSampleRegion"];
    [self.beaconManager startRangingBeaconsInRegion:region];
    
    actualRoom=[[CUSFlashLabel alloc]initWithFrame:CGRectMake(150, 185, 300, 50)];
    [actualRoom setFont:[UIFont systemFontOfSize:27]];
    [actualRoom setContentMode:UIViewContentModeTop];
    [actualRoom setSpotlightColor:[UIColor yellowColor]];
    [actualRoom startAnimating];
    [self.view addSubview:actualRoom];
    
    sentence=[[CUSFlashLabel alloc]initWithFrame:CGRectMake(63, 160, 300, 50)];
    [sentence setFont:[UIFont systemFontOfSize:21]];
    [sentence setContentMode:UIViewContentModeTop];
    [sentence setSpotlightColor:[UIColor yellowColor]];
    [sentence startAnimating];
    [self.view addSubview:sentence];
    sentence.text=@"The Nearest Room is:";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

-(void)beaconManager:(ESTBeaconManager *)manager
     didRangeBeacons:(NSArray *)beacons
            inRegion:(ESTBeaconRegion *)region
{
    if([beacons count] > 0)
    {
        
        beaconArray=beacons;
//        NSLog(@"%lu",(unsigned long)beacons.count);
//        ESTBeacon *ss= [beaconArray objectAtIndex:0];
//        NSLog(@"%hu",[ss.major unsignedShortValue]);
        
        // beacon array is sorted based on distance
        // closest beacon is the first one
        ESTBeacon *indexString=[self.beaconArray objectAtIndex:0];
        NSString* selectedMajor= [NSString stringWithFormat:
                               @"Major: %i, Minor: %i",
                               [indexString.major unsignedShortValue],
                               [indexString.minor unsignedShortValue]];
        NSLog(@"%@",selectedMajor);
        NSString *subUrl=@"http://1.mccnav.appspot.com/mcc/beacons/";
        NSString *url=[subUrl stringByAppendingString:uploadFloorPlanIdBeacon];
        NSData *allLocationData=[[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:url]];
        NSError *error;
        NSArray *allLocation = [NSJSONSerialization
                                JSONObjectWithData:allLocationData
                                options:kNilOptions
                                error:&error];
        if( error )
        {
            NSLog(@"%@", [error localizedDescription]);
        }
        else {
            NSDictionary *location;
            for ( location in allLocation )
            {
                NSArray *beaconIds=[location objectForKey:@"beaconIds"];
                NSDictionary *dict;
                for (dict in beaconIds) {
                    NSString *string= [dict objectForKey:@"beaconId"];
                    if ([string rangeOfString:selectedMajor].location!=NSNotFound) {
                        matchMajor=[location objectForKey:@"locationId"];
                        actualRoom.text= matchMajor;
                    }
                }
             
                
            }
        }
        

        
        // calculate and set new y position
//        switch (self.selectedBeacon.proximity)
//        {
//            case CLProximityUnknown:
//                labelText = [labelText stringByAppendingString: @"Unknown"];
//                break;
//            case CLProximityImmediate:
//                labelText = [labelText stringByAppendingString: @"Immediate"];
//                break;
//            case CLProximityNear:
//                labelText = [labelText stringByAppendingString: @"Near"];
//                break;
//            case CLProximityFar:
//                labelText = [labelText stringByAppendingString: @"Far"];
//                break;
//                
//            default:
//                break;
//        }
        
    }
        [self.tableView reloadData];
}



-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    NSLog(@"%lu",(unsigned long)beaconArray.count);
    return self.beaconArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ConCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier] ;
    }
    ESTBeacon *indexString=[self.beaconArray objectAtIndex:indexPath.row];
    NSString *majorAndMinor=[NSString stringWithFormat:
                             @"Major: %i, Minor: %i",
                             [indexString.major unsignedShortValue],
                             [indexString.minor unsignedShortValue]];
//    NSLog(@"%@",majorAndMinor);
    [cell.textLabel setText:[NSString stringWithFormat:@"%@",majorAndMinor]];
    return cell;
}



@end
