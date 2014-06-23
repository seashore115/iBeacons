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
        NSLog(@"1111");
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
        self.BeaconsLabel.text = [NSString stringWithFormat:@"%i",[beacons count]];
        ESTBeacon *indexString=[beacons objectAtIndex:0];
        self.NameLabel.text= [NSString stringWithFormat:
                               @" %i - %i",
                               [indexString.major unsignedShortValue],
                               [indexString.minor unsignedShortValue]];
        float rawDistance=[indexString.distance floatValue];
        self.DistanceLabel.text= [NSString stringWithFormat:@"%.3f",rawDistance];
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
        ;
    }else{
        for (int i=0; i<100; ++i) {
            [self performSelector:@selector(dataInRecording) withObject:nil afterDelay:0.5];
        }
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
        
        
        
        
        

        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
//        NSString *json=[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
//        NSString *reqData=[@"file=" stringByAppendingString:json];
//        //NSLog(@"%@",reqData);
//        NSData *postDatas=[reqData dataUsingEncoding:NSUTF8StringEncoding];
//        NSString *postLength=[NSString stringWithFormat:@"%lu",(unsigned long)[postDatas length]];
//        NSMutableURLRequest *requestPost=[NSMutableURLRequest requestWithURL:dataUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
        //NSLog(@"%@",dataUrl);
        
//        NSString *boundary = @"YOUR_BOUNDARY_STRING";
//        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
//        [requestPost addValue:contentType forHTTPHeaderField:@"Content-Type"];
//        [requestPost setHTTPMethod:@"POST"];
//        NSMutableData *somebody = [NSMutableData data];
//        [somebody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//        [somebody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\" filename=\"%@\"\r\n\r\n",foofile ] dataUsingEncoding:NSUTF8StringEncoding]];
//        [somebody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//        [somebody appendData:[NSData dataWithData:fileData]];
//        [somebody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//        
//        // close form
//        [somebody appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//        [requestPost setHTTPBody:somebody];
        
//        [requestPost setValue:postLength forHTTPHeaderField:@"Content-Length"];
//        [requestPost setHTTPMethod:@"POST"];
//        [requestPost setValue:postLength forHTTPHeaderField:@"Content-Length"];
//        [requestPost setHTTPBody:postDatas];
//        NSLog(@"%@",[[NSString alloc] initWithData:postDatas encoding:NSASCIIStringEncoding]);
        
//        NSError *requestError;
//        NSURLResponse *response = nil;
//        [NSURLConnection sendSynchronousRequest:requestPost returningResponse:&response error:&requestError];
//        if (requestError == nil) {
//            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
//                NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
//                if (statusCode != 200) {
//                    NSLog(@"Warning, status code of response was not 200, it was %ld", (long)statusCode);
//                }
//            
//            }
//        } else {
//            NSLog(@"NSURLConnection sendSynchronousRequest error: %@", requestError);
//        }
//}
//        NSMutableURLRequest *myMedRequest = [NSMutableURLRequest requestWithURL:dataUrl];
//        [myMedRequest setHTTPMethod:@"POST"];
//        
//        // Add HTTP header info
//        // Note: POST boundaries are described here: http://www.vivtek.com/rfc1867.html
//        // and here http://www.w3.org/TR/html4/interact/forms.html
//        NSString *POSTBoundary = @"0xKhTmLbOuNdArY";
//        [myMedRequest addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@\r\n", POSTBoundary] forHTTPHeaderField:@"Content-Type"];
//        
//        // Add HTTP Body
//        NSMutableData *POSTBody = [NSMutableData data];
//        [POSTBody appendData:[[NSString stringWithFormat:@"--%@\r\n",POSTBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
//        
//        // Add Key/Values to the Body
//        NSEnumerator *enumerator = [dictionary keyEnumerator];
//        NSString *key;
//        
//        while ((key = [enumerator nextObject])) {
//            [POSTBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
//            [POSTBody appendData:[[NSString stringWithFormat:@"%@", [dictionary objectForKey:key]] dataUsingEncoding:NSUTF8StringEncoding]];
//            [POSTBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", POSTBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
//        }
//        
//        // Add the closing -- to the POST Form
//        [POSTBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", POSTBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
//        
//        // Add the body to the myMedRequest & return
//        [myMedRequest setHTTPBody:POSTBody];
//    NSError *requestError=nil;
//           NSURLResponse *response = nil;
//        NSData *data=[NSURLConnection sendSynchronousRequest:myMedRequest returningResponse:&response error:&requestError];
//    NSLog(@"error---%@",requestError);
//            if (requestError == nil) {
//                if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
//                 NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
//                    if (statusCode != 200) {
//                        NSLog(@"Warning, status code of response was not 200, it was %ld", (long)statusCode);
//                    }
//                }
//    
//                NSError *error;
//                NSDictionary *returnDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
//                if (returnDictionary) {
//                    NSLog(@"returnDictionary=%@", returnDictionary);
//                } else {
//                    NSLog(@"error parsing JSON response: %@", error);
//    
//                    NSString *returnString = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
//                    NSLog(@"returnString: %@", returnString);
//                }
//            } else {
//                NSLog(@"NSURLConnection sendSynchronousRequest error: %@", requestError);
//            }
//    }

 
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"Error %@", [request error]);
    if ([request error]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Fail."
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];

        return;
        
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    // Use when fetching text data
    NSString *responseString = [request responseString];
    NSLog(@"%@",responseString);
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
