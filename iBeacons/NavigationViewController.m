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
@synthesize mapView=_mapView;
@synthesize BeaconsLabel;
@synthesize DistanceLabel;
@synthesize NameLabel;
@synthesize beaconArray;
@synthesize count;
@synthesize time;
@synthesize uploadFlag;
@synthesize predictFlag;
@synthesize predictiveTime;
@synthesize points = _points;
@synthesize routeLine = _routeLine;
@synthesize routeLineView = _routeLineView;




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
    
    //flag
    uploadFlag=NO;
    predictFlag=NO;
    
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
    [self.showResult addTarget:self action:@selector(getPreidictResult) forControlEvents:UIControlEventTouchUpInside];
    
    
    //label
    self.BeaconsLabel.text=@"0";
    self.NameLabel.text=@"unKnown";
    self.DistanceLabel.text=@"unKnown";
    self.countLabel.text=@"0";
    self.predictiveLabel.text=@"unKnown";
    
    
    //map
    [self.view addSubview:self.mapView];
    [self.mapView setShowsUserLocation:YES];
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
     predictiveTime = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(getPreidictResult) userInfo:nil repeats:YES];
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
   
    NSMutableArray *beaconMessageArray=[[NSMutableArray alloc]initWithCapacity:10000];
    NSMutableDictionary *dataInMessage=[[NSMutableDictionary alloc] initWithCapacity:30];
    NSMutableDictionary *gps=[[NSMutableDictionary alloc]initWithCapacity:10];
    NSMutableDictionary *magnetic=[[NSMutableDictionary alloc]initWithCapacity:20];
     NSString * beaconDistance=@"";
    //play
    for (int i=0; i<beaconArray.count ;++i) {
        NSMutableDictionary *beaconMessageDictionary=[[NSMutableDictionary alloc]init];
        ESTBeacon *beacon=[beaconArray objectAtIndex:i];
        beaconDistance= [NSString stringWithFormat:@"%.3f",[[beacon.distance stringValue] floatValue]];
        [beaconMessageDictionary setObject:[NSNumber numberWithInt:[beacon.major intValue]] forKey:@"m"];
        [beaconMessageDictionary setObject:[NSNumber numberWithInt:[beacon.minor intValue]] forKey:@"n"];
        [beaconMessageDictionary setObject:[NSNumber numberWithFloat:[beaconDistance floatValue ]]  forKey:@"d"];
        [beaconMessageDictionary setObject:[beacon.proximityUUID UUIDString] forKey:@"uuid"];
        [beaconMessageDictionary setObject:[NSNumber numberWithInteger:beacon.rssi] forKey:@"s"];
//        [beaconMessageDictionary setObject: beacon.batteryLevel forKey:@"p"];
        [beaconMessageArray addObject: beaconMessageDictionary];
        NSLog(@"######%@\n\n",beaconMessageArray);
        NSLog(@"/n%@/n",beacon.batteryLevel);
    }
    [dataInMessage setObject:beaconMessageArray forKey:@"beacons"];
    [gps setObject:[NSNumber numberWithFloat:[longitude floatValue]] forKey:@"lon"];
    [gps setObject:[NSNumber numberWithFloat:[latitude floatValue]] forKey:@"lat"];
    [dataInMessage setObject:gps forKey:@"gps"];
    [magnetic setObject:[NSNumber numberWithFloat:[xValue floatValue]] forKey:@"x"];
    [magnetic setObject:[NSNumber numberWithFloat:[yValue floatValue]]forKey:@"y"];
    [magnetic setObject:[NSNumber numberWithFloat:[zValue floatValue]] forKey:@"z"];
    [dataInMessage setObject:magnetic forKey:@"mag"];
    [dataInMessage setObject:roomName forKey:@"locationId"];
    [data addObject:dataInMessage];
    NSLog(@"------++%@\n\n",dataInMessage);
    NSLog(@"++++++-----%@\n\n",data);
    ++count;

}

-(void)sendData{
    //timestamp
    timeStamp= [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970] * 1000];
    NSMutableDictionary *dictionary=[[NSMutableDictionary alloc]initWithCapacity:10000000];
    [dictionary setObject:[[BeaconsCollecetionData sharedManager] floorPlan] forKey:@"floorplanId"];
    [dictionary setObject:[[BeaconsCollecetionData sharedManager] currentRoomName] forKey:@"locationId"];
    [dictionary setObject:deviceId forKey:@"deviceType"];
    [dictionary setObject:[NSNumber numberWithInt:[timeStamp intValue]] forKey:@"timestamp"];
    [dictionary setObject:data forKey:@"data"];

    NSLog(@"%@",dictionary);
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
        uploadFlag=YES;
        
    }
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"Error %@", [request error]);
    if ([request error]) {
        if (uploadFlag) {
            XYShowAlert(@"Upload file fails");
            return;
            uploadFlag=!uploadFlag;
        }
        if (predictFlag) {
            XYShowAlert(@"Predict fails");
            return;
            predictFlag=!predictFlag;
        }

        
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    // Use when fetching text data
    NSString *responseString = [request responseString];
    NSData *responseData=[request responseData];
    NSLog(@"%@",responseString);
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData
                                                         options:kNilOptions error:&error];
    NSLog(@"%@", [json objectForKey:@"3"]);
    NSLog(@"%li",(long)count);
    if (uploadFlag) {
        XYShowAlert(@"Upload file succeeds");
        uploadFlag=NO;
    }
    if (predictFlag) {
        NSString *predictString=[NSString stringWithFormat:@"You are now in the %@",responseString];
        if (responseString.length>70) {
            self.predictiveLabel.text=@"unKnown";
        }else{
            self.predictiveLabel.text=predictString;
        }
        predictFlag=NO;
    }
    
}


-(void)getPreidictResult{
    NSMutableArray *beaconMessageArray=[[NSMutableArray alloc]initWithCapacity:10000];
    NSMutableDictionary *dataInMessage=[[NSMutableDictionary alloc] initWithCapacity:30];
    NSMutableDictionary *gps=[[NSMutableDictionary alloc]initWithCapacity:10];
    NSMutableDictionary *magnetic=[[NSMutableDictionary alloc]initWithCapacity:20];
    NSString * beaconDistance=@"";
    //play
    for (int i=0; i<beaconArray.count ;++i) {
        NSMutableDictionary *beaconMessageDictionary=[[NSMutableDictionary alloc]init];
        ESTBeacon *beacon=[beaconArray objectAtIndex:i];
        beaconDistance= [NSString stringWithFormat:@"%.3f",[[beacon.distance stringValue] floatValue]];
        [beaconMessageDictionary setObject:[NSNumber numberWithInt:[beacon.major intValue]] forKey:@"m"];
        [beaconMessageDictionary setObject:[NSNumber numberWithInt:[beacon.minor intValue]] forKey:@"n"];
        [beaconMessageDictionary setObject:[NSNumber numberWithFloat:[beaconDistance floatValue ]]  forKey:@"d"];
        [beaconMessageArray addObject: beaconMessageDictionary];
    }
    [dataInMessage setObject:beaconMessageArray forKey:@"beacons"];
    [gps setObject:[NSNumber numberWithFloat:[longitude floatValue]] forKey:@"lon"];
    [gps setObject:[NSNumber numberWithFloat:[latitude floatValue]] forKey:@"lat"];
    [dataInMessage setObject:gps forKey:@"gps"];
    [magnetic setObject:[NSNumber numberWithFloat:[xValue floatValue]] forKey:@"x"];
    [magnetic setObject:[NSNumber numberWithFloat:[yValue floatValue]]forKey:@"y"];
    [magnetic setObject:[NSNumber numberWithFloat:[zValue floatValue]] forKey:@"z"];
    [dataInMessage setObject:magnetic forKey:@"mag"];
    
    NSString *urlString=[NSString stringWithFormat:@"http://inav.zii.io/inav/predict/%@",floorPlanId] ;
    NSURL *dataUrl=[[NSURL alloc] initWithString:urlString];
    if ([NSJSONSerialization isValidJSONObject:dataInMessage]) {
        NSError *error;
        //NSLog(@"1");
        NSData *jsonData=[NSJSONSerialization dataWithJSONObject:dataInMessage options:NSJSONWritingPrettyPrinted error:&error];
        NSString *json=[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        //NSLog(@"%@",json);
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:dataUrl];
        [request setDelegate:self];
        [request setPostValue:json forKey:@"input"];
        [request startAsynchronous];
        predictFlag=YES;
    }


}

-(void)viewDidDisappear:(BOOL)animated{
    [predictiveTime invalidate];
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


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


- (void)configureRoutes
{
    // define minimum, maximum points
	MKMapPoint northEastPoint = MKMapPointMake(0.f, 0.f);
	MKMapPoint southWestPoint = MKMapPointMake(0.f, 0.f);
	
	// create a c array of points.
	MKMapPoint* pointArray = malloc(sizeof(CLLocationCoordinate2D) * _points.count);
    
	// for(int idx = 0; idx < pointStrings.count; idx++)
    for(int idx = 0; idx < _points.count; idx++)
	{
        CLLocation *location = [_points objectAtIndex:idx];
        CLLocationDegrees latitude  = location.coordinate.latitude;
		CLLocationDegrees longitude = location.coordinate.longitude;
        
		// create our coordinate and add it to the correct spot in the array
		CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
		MKMapPoint point = MKMapPointForCoordinate(coordinate);
		
		// if it is the first point, just use them, since we have nothing to compare to yet.
		if (idx == 0) {
			northEastPoint = point;
			southWestPoint = point;
		} else {
			if (point.x > northEastPoint.x)
				northEastPoint.x = point.x;
			if(point.y > northEastPoint.y)
				northEastPoint.y = point.y;
			if (point.x < southWestPoint.x)
				southWestPoint.x = point.x;
			if (point.y < southWestPoint.y)
				southWestPoint.y = point.y;
		}
        
		pointArray[idx] = point;
	}
	
    if (self.routeLine) {
        [self.mapView removeOverlay:self.routeLine];
    }
    
    self.routeLine = [MKPolyline polylineWithPoints:pointArray count:_points.count];
    
    // add the overlay to the map
	if (nil != self.routeLine) {
		[self.mapView addOverlay:self.routeLine];
	}
    
    // clear the memory allocated earlier for the points
	free(pointArray);
    
    /*
     double width = northEastPoint.x - southWestPoint.x;
     double height = northEastPoint.y - southWestPoint.y;
     
     _routeRect = MKMapRectMake(southWestPoint.x, southWestPoint.y, width, height);
     
     // zoom in on the route.
     [self.mapView setVisibleMapRect:_routeRect];
     */
}

/*
 #pragma mark
 #pragma mark Location Manager
 
 - (void)configureLocationManager
 {
 // Create the location manager if this object does not already have one.
 if (nil == _locationManager)
 _locationManager = [[CLLocationManager alloc] init];
 
 _locationManager.delegate = self;
 _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
 _locationManager.distanceFilter = 50;
 [_locationManager startUpdatingLocation];
 // [_locationManager startMonitoringSignificantLocationChanges];
 }
 
 #pragma mark
 #pragma mark CLLocationManager delegate methods
 - (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
 {
 NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));
 
 // If it's a relatively recent event, turn off updates to save power
 NSDate* eventDate = newLocation.timestamp;
 NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
 
 if (abs(howRecent) < 2.0)
 {
 NSLog(@"recent: %g", abs(howRecent));
 NSLog(@"latitude %+.6f, longitude %+.6f\n", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
 }
 
 // else skip the event and process the next one
 }
 
 - (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
 {
 NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));
 NSLog(@"error: %@",error);
 }
 */

#pragma mark
#pragma mark MKMapViewDelegate
- (void)mapView:(MKMapView *)mapView didAddOverlayViews:(NSArray *)overlayViews
{
    NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));
    NSLog(@"overlayViews: %@", overlayViews);
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));
    
	MKOverlayView* overlayView = nil;
	
	if(overlay == self.routeLine)
	{
		//if we have not yet created an overlay view for this overlay, create it now.
        if (self.routeLineView) {
            [self.routeLineView removeFromSuperview];
        }
        
        self.routeLineView = [[MKPolylineView alloc] initWithPolyline:self.routeLine];
        self.routeLineView.fillColor = [UIColor redColor];
        self.routeLineView.strokeColor = [UIColor redColor];
        self.routeLineView.lineWidth = 10;
        
		overlayView = self.routeLineView;
	}
	
	return overlayView;
}

/*
 - (void)mapViewWillStartLoadingMap:(MKMapView *)mapView
 {
 NSLog(@"mapViewWillStartLoadingMap:(MKMapView *)mapView");
 }
 
 - (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
 {
 NSLog(@"mapViewDidFinishLoadingMap:(MKMapView *)mapView");
 }
 
 - (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error
 {
 NSLog(@"mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error");
 }
 
 - (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
 {
 NSLog(@"mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated");
 NSLog(@"%f, %f", mapView.centerCoordinate.latitude, mapView.centerCoordinate.longitude);
 }
 
 - (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
 {
 NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));
 NSLog(@"centerCoordinate: %f, %f", mapView.centerCoordinate.latitude, mapView.centerCoordinate.longitude);
 }
 */

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));
    NSLog(@"annotation views: %@", views);
}

/*
 - (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
 {
 NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));
 }
 
 - (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated
 {
 NSLog(@"mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated");
 }
 
 - (void)mapViewWillStartLocatingUser:(MKMapView *)mapView
 {
 NSLog(@"mapViewWillStartLocatingUser:(MKMapView *)mapView");
 }
 
 - (void)mapViewDidStopLocatingUser:(MKMapView *)mapView
 {
 NSLog(@"mapViewDidStopLocatingUser:(MKMapView *)mapView");
 }
 */

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:userLocation.coordinate.latitude
                                                      longitude:userLocation.coordinate.longitude];
    // check the zero point
    if  (userLocation.coordinate.latitude == 0.0f ||
         userLocation.coordinate.longitude == 0.0f)
        return;
    
    // check the move distance
    if (_points.count > 0) {
        CLLocationDistance distanceAt = [location distanceFromLocation:_currentLocation];
        if (distanceAt < 5)
            return;
    }
    
    if (nil == _points) {
        _points = [[NSMutableArray alloc] init];
    }
    
    [_points addObject:location];
    _currentLocation = location;
    
    NSLog(@"points: %@", _points);
    
    [self configureRoutes];
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude);
    [self.mapView setCenterCoordinate:coordinate animated:YES];
}



@end
