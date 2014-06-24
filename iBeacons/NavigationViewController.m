//
//  NavigationViewController.m
//  iBeacons
//
//  Created by Apple on 14-6-3.
//  Copyright (c) 2014年 meng.wang. All rights reserved.
//

#import "NavigationViewController.h"
#import "UIButton+Bootstrap.h"
#import "ESTBeaconManager.h"
#import "UIDeviceHardware.h"
#import "BeaconsCollecetionData.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "XYAlertViewHeader.h"

@interface NavigationViewController ()<ESTBeaconDelegate,CLLocationManagerDelegate>
@property (nonatomic,strong) ESTBeaconManager* beaconManager;
@property (nonatomic,strong) ESTBeacon* selectedBeacon;

@end

@implementation NavigationViewController
@synthesize locationManager;
@synthesize distance;
@synthesize xValue;
@synthesize yValue;
@synthesize zValue;
@synthesize latitude;
@synthesize longitude;
@synthesize timeStamp;
@synthesize roomName;
@synthesize deviceId;
@synthesize floorPlanId;
@synthesize data;
@synthesize nearestBeaconName;
@synthesize sumOfBeaons;
@synthesize nearestDistance;
@synthesize mapView;
@synthesize BeaconsLabel;
@synthesize DistanceLabel;
@synthesize NameLabel;
@synthesize beaconArray;
@synthesize count;
@synthesize time;


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
    //count
    count=0;
    
   //device Id
    UIDeviceHardware *h=[[UIDeviceHardware alloc]init];
    deviceId=[h platformString];
    
    //floolplan&rome
    floorPlanId=[[BeaconsCollecetionData sharedManager] floorPlan];
    roomName=[[BeaconsCollecetionData sharedManager] currentRoomName];
    
    //button
    [self.scan successStyle];
    [self.accuracy infoStyle];
    [self.uploadButton warningStyle];
    
    [self.scan addTarget:self action:@selector(recordData:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.uploadButton addTarget:self action:@selector(sendData) forControlEvents:UIControlEventTouchUpInside];
    
    //label
    self.BeaconsLabel.text=@"0";
    self.NameLabel.text=@"unKnown";
    self.DistanceLabel.text=@"unKnown";
    self.countLabel.text=@"0";
    
    
    //map
    [self.view addSubview:mapView];
    [mapView setShowsUserLocation:YES];
    self.mapView.delegate=self;
    self.navigationItem.rightBarButtonItem=[[MKUserTrackingBarButtonItem alloc]initWithMapView:self.mapView];
    self.mapView.userTrackingMode=MKUserTrackingModeFollow;
    
    //beacon
    [self setupManager];
    
    //data
    data=[[NSMutableArray alloc] initWithCapacity:10000000];
    
    //gps
    self.locationManager = [[CLLocationManager alloc] init] ;
	if ([CLLocationManager headingAvailable] == NO) {
		// No compass is available. This application cannot function without a compass,
        // so a dialog will be displayed and no magnetic data will be measured.
        self.locationManager = nil;
        UIAlertView *noCompassAlert = [[UIAlertView alloc] initWithTitle:@"No Compass!" message:@"This device does not have the ability to measure magnetic fields." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [noCompassAlert show];
	} else {
        // heading service configuration
        locationManager.headingFilter = kCLHeadingFilterNone;
        
        // setup delegate callbacks
        locationManager.delegate = self;
        
        // start the compass
        [locationManager startUpdatingHeading];
    }
    locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
}


-(void)beaconManager:(ESTBeaconManager *)manager
     didRangeBeacons:(NSArray *)beacons
            inRegion:(ESTBeaconRegion *)region
{
    if([beacons count] > 0)
    {
        // based on observation rssi is not getting bigger then -30
        // so it changes from -30 to -100 so we normalize
        self.BeaconsLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)[beacons count]];
        ESTBeacon *indexString=[beacons objectAtIndex:0];
        self.NameLabel.text= [NSString stringWithFormat:
                               @" %i - %i",
                               [indexString.major unsignedShortValue],
                               [indexString.minor unsignedShortValue]];
        float rawDistance=[indexString.distance floatValue];
        self.DistanceLabel.text= [NSString stringWithFormat:@"%.3f m",rawDistance];
        self.countLabel.text=[NSString stringWithFormat:@"%li",(long)count];
        beaconArray=beacons;
    }
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
    xValue=[NSString stringWithFormat:@"%.1f", newHeading.x];
    yValue=[NSString stringWithFormat:@"%.1f", newHeading.y];
    zValue=[NSString stringWithFormat:@"%.1f", newHeading.z];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    latitude=[NSString stringWithFormat:@"%f", locationManager.location.coordinate.latitude];
    longitude=[NSString stringWithFormat:@"%f",locationManager.location.coordinate.longitude];
}

-(void)recordData :(UIButton*) sender{
    if (sender.selected) {
        //pause
        [time invalidate];
    }else{
        time = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(dataInRecording) userInfo:nil repeats:YES];
//        for (int i=0; i<100; ++i) {
//            [self performSelector:@selector(dataInRecording) withObject:nil afterDelay:1.0];
//        }
    }
    sender.selected=!sender.selected;
}


-(void)dataInRecording{
    NSMutableArray *beaconMessageArray=[[NSMutableArray alloc]initWithCapacity:1000000000];
    NSMutableDictionary *beaconMessageDictionary=[[NSMutableDictionary alloc]initWithCapacity:100];
    NSMutableDictionary *dataInMessage=[[NSMutableDictionary alloc] initWithCapacity:1000000000];
    NSMutableDictionary *gps=[[NSMutableDictionary alloc]initWithCapacity:10];
    NSMutableDictionary *magnetic=[[NSMutableDictionary alloc]initWithCapacity:20];
    
    //play
    for (ESTBeacon *beacon in beaconArray) {
        [beaconMessageDictionary setObject:[NSString stringWithFormat:
                                            @"%i",
                                            [beacon.major unsignedShortValue]] forKey:@"m"];
        [beaconMessageDictionary setObject:[NSString stringWithFormat:
                                            @"%i",
                                            [beacon.minor unsignedShortValue]] forKey:@"n"];
        [beaconMessageDictionary setObject:[NSString stringWithFormat:
                                            @"%.3f",
                                            [beacon.distance floatValue]]  forKey:@"d"];
        [beaconMessageArray addObject:beaconMessageDictionary];
        [dataInMessage setObject:beaconMessageArray forKey:@"beacons"];
        [gps setObject:longitude forKey:@"lon"];
        [gps setObject:latitude forKey:@"lat"];
        [dataInMessage setObject:gps forKey:@"gps"];
        [magnetic setObject:xValue forKey:@"x"];
        [magnetic setObject:yValue forKey:@"y"];
        [magnetic setObject:zValue forKey:@"z"];
        [dataInMessage setObject:magnetic forKey:@"mag"];
        [data addObject:dataInMessage];
        ++count;
    }

}

-(void)sendData{
    //timestamp
    timeStamp= [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
    NSMutableDictionary *dictionary=[[NSMutableDictionary alloc]initWithCapacity:10000000];
    [dictionary setObject:[[BeaconsCollecetionData sharedManager] floorPlan] forKey:@"floorplanId"];
    [dictionary setObject:[[BeaconsCollecetionData sharedManager] currentRoomName] forKey:@"locationId"];
    [dictionary setObject:deviceId forKey:@"deviceType"];
    [dictionary setObject:timeStamp forKey:@"timestamp"];
    [dictionary setObject:data forKey:@"data"];
    
//    NSMutableArray *array=[[NSMutableArray alloc]initWithCapacity:10];
//    [array addObject:dictionary];
    
    NSString *urlString=[[[[NSString stringWithFormat:@"http://inav.zii.io/inav/%@",floorPlanId] stringByAppendingString:@"/"]stringByAppendingString:roomName] stringByAppendingString:@"/data"] ;
    NSURL *dataUrl=[[NSURL alloc] initWithString:urlString];
    
    if ([NSJSONSerialization isValidJSONObject:dictionary]) {
        NSError *error;
        //NSLog(@"1");
        NSData *jsonData=[NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&error];
        NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString* filename=[NSString stringWithFormat:@"%@-%@.json", floorPlanId,roomName];
        NSString* foofile = [documentsPath stringByAppendingPathComponent:filename];
        [jsonData writeToFile:foofile atomically:YES];
   //     NSData *fileData=  [NSData dataWithContentsOfFile:foofile];
        ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:dataUrl];
        [request setDelegate:self];
        [request setFile:foofile forKey:@"file"];
        [request startAsynchronous];
        
    }
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"Error %@", [request error]);
    if ([request error]) {
        XYShowAlert(@"Upload file fails");
        return;
        
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    // Use when fetching text data
    NSString *responseString = [request responseString];
    NSLog(@"%@",responseString);
    NSLog(@"%i",count);
    XYShowAlert(@"Upload file succeeds");
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
