//
//  DetailViewController.m
//  iBeacons
//
//  Created by Apple on 14-3-5.
//  Copyright (c) 2014年 meng.wang. All rights reserved.
//

#import "DetailViewController.h"
#import "ESTBeaconManager.h"
#import "LDProgressView.h"
#import "ColorButton.h"
#import "PulsingHaloLayer.h"
#import "CUSFlashLabel.h"
#import "BeaconTestViewController.h"
#import "MagneticTestViewController.h"




@interface DetailViewController ()<ESTBeaconManagerDelegate,CLLocationManagerDelegate>
@property (nonatomic,strong) ESTBeaconManager* beaconManager;
@property (nonatomic,strong) ESTBeacon* selectedBeacon;
@property (nonatomic,strong) LDProgressView *xView;
@property (nonatomic,strong) LDProgressView *yView;
@property (nonatomic,strong) LDProgressView *zView;
@property (strong, nonatomic) IBOutlet UIImageView *beaconView;
@property (nonatomic, strong) PulsingHaloLayer *halo;
@property (nonatomic,strong) CUSFlashLabel *iBeaconActualDistance;
@property (nonatomic,strong) CUSFlashLabel *iBeaconName;
@property (nonatomic,strong) CUSFlashLabel *iBeaconDistance;
@end

@implementation DetailViewController{
   
}
//@synthesize xLabel;
//@synthesize yLabel;
//@synthesize zLabel;
@synthesize locationManager;
@synthesize distance;
//room
@synthesize roomName;
//floorplanid
@synthesize uploadFloorPlanId;

@synthesize xView;
@synthesize yView;
@synthesize zView;
@synthesize xValue;
@synthesize yValue;
@synthesize zValue;
@synthesize iBeaconActualDistance;
@synthesize iBeaconName;
@synthesize iBeaconDistance;
@synthesize count;
@synthesize major;
@synthesize minor;

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
    // craete manager instance
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    self.beaconManager.avoidUnknownStateBeacons = YES;
    
    // create sample region object (you can additionaly pass major / minor values)
    ESTBeaconRegion* region = [[ESTBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID
                                                                  identifier:@"EstimoteSampleRegion"];
    
    // start looking for estimote beacons in region
    // when beacon ranged beaconManager:didRangeBeacons:inRegion: invoked
    [self.beaconManager startRangingBeaconsInRegion:region];
    
    self.locationManager = [[CLLocationManager alloc] init] ;
	
	// check if the hardware has a compass
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
//    NSLog(@"%@",roomName);
//    NSLog(@"%@",uploadFloorPlanId);
    //----

//    CGAffineTransform sliderRotation = CGAffineTransformIdentity;
//    sliderRotation = CGAffineTransformRotate(sliderRotation, -(M_PI / 2));
//    self.slider.transform = sliderRotation;
    
    xView=[[LDProgressView alloc] initWithFrame:CGRectMake(30, 390, self.view.frame.size.width-60, 22)];
    xView.color=[UIColor colorWithRed:0.00f green:0.64f blue:0.00f alpha:1.00f];
    xView.flat=@YES;
    xView.progress = 0.40;
    xView.animate = @YES;
    [self.view addSubview:xView];
    yView=[[LDProgressView alloc] initWithFrame:CGRectMake(30, 420, self.view.frame.size.width-60, 22)];
    yView.flat=@YES;
    yView.progress = 0.40;
    yView.animate = @YES;
    [self.view addSubview:yView];
    zView=[[LDProgressView alloc] initWithFrame:CGRectMake(30, 450, self.view.frame.size.width-60, 22)];
    zView.color=[UIColor orangeColor];
    zView.flat=@YES;
    zView.progress = 0.40;
    zView.animate = @YES;
    [self.view addSubview:zView];
    
    //record button
    NSMutableArray *colorArray = [@[[UIColor colorWithRed:0.3 green:0.278 blue:0.957 alpha:1],[UIColor colorWithRed:0.114 green:0.612 blue:0.843 alpha:1]] mutableCopy];
	ColorButton *btn = [[ColorButton alloc]initWithFrame:CGRectMake(83, 500, 150, 50) FromColorArray:colorArray ByGradientType:topToBottom];
    [btn setTitle:@"Record" forState:UIControlStateNormal];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(record) forControlEvents:UIControlEventTouchUpInside];
    
    //beaconView
    self.halo = [PulsingHaloLayer layer];
    self.halo.position = self.beaconView.center;
    [self.view.layer insertSublayer:self.halo below:self.beaconView.layer];
    self.halo.radius=0.77*160;
    UIColor *color = [UIColor colorWithRed:0
                                     green:0.487
                                      blue:1
                                     alpha:1.0];
    self.halo.backgroundColor=color.CGColor;
    
    //ibeacon label
    UIView *view = self.view;
    iBeaconActualDistance = [[CUSFlashLabel alloc]initWithFrame:CGRectMake(95, 270, 300, 50)];
    [iBeaconActualDistance setFont:[UIFont systemFontOfSize:15]];
    [iBeaconActualDistance setContentMode:UIViewContentModeTop];
    [iBeaconActualDistance setSpotlightColor:[UIColor yellowColor]];
    [iBeaconActualDistance startAnimating];
    [view addSubview:iBeaconActualDistance];
    
    iBeaconName = [[CUSFlashLabel alloc]initWithFrame:CGRectMake(70, 130, 300, 50)];
    [iBeaconName setFont:[UIFont systemFontOfSize:15]];
    [iBeaconName setContentMode:UIViewContentModeTop];
    [iBeaconName startAnimating];
    [view addSubview:iBeaconName];
    
    iBeaconDistance = [[CUSFlashLabel alloc]initWithFrame:CGRectMake(112, 290, 300, 50)];
    [iBeaconDistance setFont:[UIFont systemFontOfSize:15]];
    [iBeaconDistance setContentMode:UIViewContentModeTop];
    [iBeaconDistance setSpotlightColor:[UIColor yellowColor]];
    [iBeaconDistance startAnimating];
    [view addSubview:iBeaconDistance];
    
    //iBeaconTitle
    self.iBeaconTitle.gradientStartColor=[UIColor redColor];
    self.iBeaconTitle.gradientEndColor = [UIColor blackColor];
    
    //test
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"Test" style:UIBarButtonItemStyleBordered target:self action:@selector(showTest)];
    
//    NSLog(@"%ld",(long)count);
}

-(void)showTest
{
    if (_test.isOpen)
        return [_test close];
    REMenuItem *testBeacon=[[REMenuItem alloc] initWithTitle:@"Beacon Test" image:nil highlightedImage:nil action:^(REMenuItem *item){
        [self performSegueWithIdentifier:@"beacon" sender:self];
    }];
    REMenuItem *testMagnetic=[[REMenuItem alloc] initWithTitle:@"Mutiply Record Test" image:nil highlightedImage:nil action:^(REMenuItem *item){
        [self performSegueWithIdentifier:@"magnetic" sender:self];
    }];
    testBeacon.tag=0;
    testMagnetic.tag=1;
    _test = [[REMenu alloc] initWithItems:@[testBeacon,testMagnetic]];
    _test.cornerRadius = 4;
    _test.shadowColor = [UIColor blackColor];
    _test.shadowOffset = CGSizeMake(0, 1);
    _test.shadowOpacity = 1;
    _test.imageOffset = CGSizeMake(5, -1);
    
    [_test showFromNavigationController:self.navigationController];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"beacon"]) {
        BeaconTestViewController *beaconTest=segue.destinationViewController;
        beaconTest.roomNameBeacon=roomName;
        beaconTest.uploadFloorPlanIdBeacon=uploadFloorPlanId;
        
    }else if ([segue.identifier isEqualToString:@"magnetic"]){
        MagneticTestViewController *magneticTest=segue.destinationViewController;
        magneticTest.roomNameMagnetic=roomName;
        magneticTest.uploadFloorPlanIdMagnetic=uploadFloorPlanId;
        magneticTest.beaconsCount=count;
    }
}




-(void)beaconManager:(ESTBeaconManager *)manager
     didRangeBeacons:(NSArray *)beacons
            inRegion:(ESTBeaconRegion *)region
{
    if([beacons count] > 0)
    {
        
        // beacon array is sorted based on distance
        // closest beacon is the first one
        ESTBeacon *indexString=[beacons objectAtIndex:0];
        NSString* labelText = [NSString stringWithFormat:
                               @"Major: %i, Minor: %i",
                               [indexString.major unsignedShortValue],
                               [indexString.minor unsignedShortValue]];
        major=[NSString stringWithFormat: @"%i", [indexString.major unsignedShortValue]];
        minor=[NSString stringWithFormat: @"%i", [indexString.minor unsignedShortValue]];
        iBeaconName.text = labelText;
        float rawDistance=[indexString.distance floatValue];
        
        
        distance= [NSString stringWithFormat:@"%.3f",rawDistance];
        iBeaconActualDistance.text=[NSString stringWithFormat:@"Distance: %@ m",distance ];
        // calculate and set new y position
        NSString *distanceLabelText;
        switch (indexString.proximity)
        {
            case CLProximityUnknown:
                distanceLabelText =  @"Unknown";
                break;
            case CLProximityImmediate:
                distanceLabelText = @"Immediate";
                break;
            case CLProximityNear:
                distanceLabelText = @"Near";
                break;
            case CLProximityFar:
                distanceLabelText =  @"Far";
                break;
                
            default:
                break;
        }
        
        iBeaconDistance.text = [NSString stringWithFormat:@"Region: %@",distanceLabelText ];
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
//  [xLabel setText:[NSString stringWithFormat:@"%.1f", newHeading.x]];
//	[yLabel setText:[NSString stringWithFormat:@"%.1f", newHeading.y]];
//	[zLabel setText:[NSString stringWithFormat:@"%.1f", newHeading.z]];
//    [slider setValue:[xLabel.text floatValue] animated:YES];
    xView.progress=(newHeading.x+500)/1000;
    yView.progress=(newHeading.y+500)/1000;
    zView.progress=(newHeading.z+500)/1000;
    xValue=[NSString stringWithFormat:@"%.1f", newHeading.x];
    yValue=[NSString stringWithFormat:@"%.1f", newHeading.y];
    zValue=[NSString stringWithFormat:@"%.1f", newHeading.z];

}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if ([error code] == kCLErrorDenied) {
        // This error indicates that the user has denied the application's request to use location services.
        [manager stopUpdatingHeading];
    } else if ([error code] == kCLErrorHeadingFailure) {
        // This error indicates that the heading could not be determined, most likely because of strong magnetic interference.
    }
}

-(void)record{
//    NSLog(@"%@",xValue);
    //post to http://1.mccnav.appspot.com/mcc/beacons/mcc
    NSString *subUrl=@"http://1.mccnav.appspot.com/mcc/beacons/";
    NSString *url=[subUrl stringByAppendingString:uploadFloorPlanId];
    NSURL *dataUrl=[[NSURL alloc] initWithString:url];
//    NSLog(@"%@",[dataUrl absoluteString]);
//    NSLog(@"%@",url);
    NSMutableDictionary *mDict=[NSMutableDictionary dictionaryWithCapacity:4];
    NSString *id=[[uploadFloorPlanId stringByAppendingString:@"."]stringByAppendingString:roomName];
    [mDict setObject:uploadFloorPlanId forKey:@"floorplanId"];
    [mDict setObject:roomName forKey:@"locationId"];
    [mDict setObject:id forKey:@"id"];
//    NSLog(@"%@",iBeaconName.text);
    NSMutableDictionary *subDict=[NSMutableDictionary dictionaryWithCapacity:2];
    NSString *identityId=[[[[[[[@"identityId:" stringByAppendingString:iBeaconName.text]stringByAppendingString:@" x:"]stringByAppendingString:xValue]stringByAppendingString:@" y:"]stringByAppendingString:yValue]stringByAppendingString:@" z:"]stringByAppendingString:zValue];
//    NSMutableDictionary *subMinDict=[NSMutableDictionary dictionaryWithCapacity:5];
//    [subMinDict setObject:major forKey:@"Major"];
//    [subMinDict setObject:minor forKey:@"Minor"];
//    [subMinDict setObject:xValue forKey:@"x"];
//    [subMinDict setObject:yValue forKey:@"y"];
//    [subMinDict setObject:zValue forKey:@"z"];
//    NSString* identityId=[subMinDict description];
 
    [subDict setObject:identityId forKey:@"beaconId"];
    [subDict setObject:distance forKey:@"distance"];
    NSArray *subArray=[NSArray arrayWithObjects:subDict,nil];
    [mDict setObject:subArray forKey:@"beaconIds"];
    
//GET
    NSMutableArray *sendData=[[NSMutableArray alloc]initWithCapacity:count];
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
            if ([roomName isEqualToString:[location objectForKey:@"locationId"]])
                  location=mDict;
            [sendData addObject:location];
        }
        NSLog(@"%@",[sendData description]);
    }

    
    
    
    
    //json
    if ([NSJSONSerialization isValidJSONObject:sendData]) {
        NSError *error;
        //NSLog(@"1");
        NSData *jsonData=[NSJSONSerialization dataWithJSONObject:sendData options:NSJSONReadingMutableContainers |NSJSONReadingAllowFragments error:&error];
        //NSLog(@"2");
        NSString *json=[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        //NSLog(@"%@",json);
        NSString *reqData=[@"beaconsMapping=" stringByAppendingString:json];
        //NSLog(@"%@",reqData);
        NSData *postDatas=[reqData dataUsingEncoding:NSUTF8StringEncoding];
        NSString *postLength=[NSString stringWithFormat:@"%lu",(unsigned long)[postDatas length]];
        NSMutableURLRequest *requestPost=[NSMutableURLRequest requestWithURL:dataUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
        //NSLog(@"%@",dataUrl);
        [requestPost setHTTPMethod:@"POST"];
        [requestPost setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [requestPost setHTTPBody:postDatas];
        //NSLog(@"%@",[[NSString alloc] initWithData:postDatas encoding:NSASCIIStringEncoding]);
        
        NSError *requestError=nil;
        NSURLResponse *response = nil;
        NSData *data=[NSURLConnection sendSynchronousRequest:requestPost returningResponse:&response error:&requestError];
        if (requestError == nil) {
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
                if (statusCode != 200) {
                    NSLog(@"Warning, status code of response was not 200, it was %ld", (long)statusCode);
                }
            }
            
            NSError *error;
            NSDictionary *returnDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if (returnDictionary) {
                NSLog(@"returnDictionary=%@", returnDictionary);
            } else {
                NSLog(@"error parsing JSON response: %@", error);
                
                NSString *returnString = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
                NSLog(@"returnString: %@", returnString);
            }
        } else {
            NSLog(@"NSURLConnection sendSynchronousRequest error: %@", requestError);
        }
  
        
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
