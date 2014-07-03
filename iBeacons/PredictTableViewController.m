//
//  PredictTableViewController.m
//  iBeacons
//
//  Created by Apple on 14-6-26.
//  Copyright (c) 2014年 meng.wang. All rights reserved.
//

#import "PredictTableViewController.h"
#import "ESTBeaconManager.h"
#import "BeaconsCollecetionData.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@interface PredictTableViewController ()<ESTBeaconDelegate,CLLocationManagerDelegate>
@property (nonatomic,strong) ESTBeaconManager* beaconManager;
@property (nonatomic,strong) ESTBeacon* selectedBeacon;
@end

@implementation PredictTableViewController
@synthesize locationManager;
@synthesize distance;
@synthesize xValue;
@synthesize yValue;
@synthesize zValue;
@synthesize latitude;
@synthesize longitude;
@synthesize roomName;
@synthesize floorPlanId;
@synthesize beaconArray;
@synthesize time;
@synthesize json;
@synthesize request;
//@synthesize sum;
//@synthesize correctSumOne;
//@synthesize correctSumTwo;
//@synthesize correctSumThree;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    //sum
//    sum=0;
//    correctSumThree=0;
//    correctSumTwo=0;
//    correctSumOne=0;
    
    //floolplan&rome
    floorPlanId=[[BeaconsCollecetionData sharedManager] floorPlan];
    roomName=[[BeaconsCollecetionData sharedManager] currentRoomName];
    
    //beacon
    [self setupManager];
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
    [self getPreidictResult];
    time=[NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(getPreidictResult) userInfo:nil repeats:YES];
    json = [[NSDictionary alloc]init];
    

}

-(void)beaconManager:(ESTBeaconManager *)manager
     didRangeBeacons:(NSArray *)beacons
            inRegion:(ESTBeaconRegion *)region
{
    if([beacons count] > 0)
    {
        // based on observation rssi is not getting bigger then -30
        // so it changes from -30 to -100 so we normalize.
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

-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
    xValue=[NSString stringWithFormat:@"%.1f", newHeading.x];
    yValue=[NSString stringWithFormat:@"%.1f", newHeading.y];
    zValue=[NSString stringWithFormat:@"%.1f", newHeading.z];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    latitude=[NSString stringWithFormat:@"%f", locationManager.location.coordinate.latitude];
    longitude=[NSString stringWithFormat:@"%f",locationManager.location.coordinate.longitude];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [json count];
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text=[json objectForKey:[NSString stringWithFormat:@"%d",indexPath.row+1]];
    cell.detailTextLabel.text=[NSString stringWithFormat:@"%d",indexPath.row+1];
//    cell.textLabel.text=[[json objectForKey:[NSString stringWithFormat:@"%ld",indexPath.row+1]] stringByAppendingString:[NSString stringWithFormat:@" with method of %ld",indexPath.row+1]];
//    if ([[json objectForKey:[NSString stringWithFormat:@"%ld",indexPath.row+1]] isEqualToString:roomName]&&(indexPath.row==0)) {
//        ++correctSumOne;
//        NSLog(@"1-%d",correctSumOne);
//
//    }else if ([[json objectForKey:[NSString stringWithFormat:@"%ld",indexPath.row+1]] isEqualToString:roomName]&&(indexPath.row==1)){
//        ++correctSumTwo;
//        NSLog(@"2-%d",correctSumTwo);
//    }else if ([[json objectForKey:[NSString stringWithFormat:@"%ld",indexPath.row+1]] isEqualToString:roomName]&&(indexPath.row==2)){
//        ++correctSumThree;
//        NSLog(@"3-%d",correctSumThree);
//    }
//    if (indexPath.row==0) {
//        cell.detailTextLabel.text=[NSString stringWithFormat:@"Accuracay: %.2f%%",(float)correctSumOne/sum*100];
//    }else if(indexPath.row==1){
//        cell.detailTextLabel.text=[NSString stringWithFormat:@"Accuracay: %.2f%%",(float)correctSumTwo/sum*100];
//    }else if (indexPath.row==2){
//         cell.detailTextLabel.text=[NSString stringWithFormat:@"Accuracay: %.2f%%",(float)correctSumThree/sum*100];
//    }
    return cell;
    
}


-(void)getPreidictResult{
//    ++sum;
//    NSLog(@"sum - %d",sum);
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
        
        NSString *jsonString=[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        request = [ASIFormDataRequest requestWithURL:dataUrl];
        [request setDelegate:self];
        [request setPostValue:jsonString forKey:@"input"];
        [request startAsynchronous];
    }
    
    
}

-(void)viewDidDisappear:(BOOL)animated{
//    correctSumThree=0;
//    correctSumTwo=0;
//    correctSumOne=0;
//    sum=0;
    [time invalidate];
    [request clearDelegatesAndCancel];
}

-(void)viewDidAppear:(BOOL)animated{
//    correctSumThree=0;
//    correctSumTwo=0;
//    correctSumOne=0;
    [self getPreidictResult];
    [self.tableView reloadData];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    // Use when fetching text data
    NSData *responseData=[request responseData];
    NSError* error;
    json = [NSJSONSerialization JSONObjectWithData:responseData
                                                         options:kNilOptions error:&error];

    [self.tableView reloadData];

    
    
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
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

@end
