//
//  NavigationViewController.h
//  iBeacons
//
//  Created by Apple on 14-6-3.
//  Copyright (c) 2014年 meng.wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "RRSGlowLabel.h"

@interface NavigationViewController : UIViewController<CLLocationManagerDelegate,MKMapViewDelegate>{
     CLLocationManager *locationManager;
    // the map view
	MKMapView* _mapView;
	
    // routes points
    NSMutableArray* _points;
    
	// the data representing the route points.
	MKPolyline* _routeLine;
	
	// the view we create for the line on the map
	MKPolylineView* _routeLineView;
	
	// the rect that bounds the loaded points
	MKMapRect _routeRect;
    
    // location manager
    CLLocationManager* _locationManager;
    
    // current location
    CLLocation* _currentLocation;
}
@property (strong, nonatomic) IBOutlet UILabel *countLabel;
@property (strong, nonatomic) IBOutlet UILabel *DistanceLabel;
@property (strong, nonatomic) IBOutlet UILabel *NameLabel;
@property (strong, nonatomic) IBOutlet UILabel *BeaconsLabel;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UIButton *uploadButton;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (strong, nonatomic) IBOutlet UIButton *scan;
@property (strong, nonatomic) IBOutlet UIButton *accuracy;
@property (strong, nonatomic)NSString* distance;
@property (strong,nonatomic)NSString* xValue;
@property (strong,nonatomic)NSString* yValue;
@property (strong,nonatomic)NSString* zValue;
@property (strong,nonatomic)NSString* longitude;
@property (strong,nonatomic)NSString* latitude;
@property (strong,nonatomic)NSString* roomName;
@property (strong,nonatomic)NSString* floorPlanId;
@property (strong,nonatomic)NSString* deviceId;
@property (strong,nonatomic)NSString* timeStamp;
@property (strong,nonatomic)NSMutableArray* data;
@property (strong,nonatomic)NSString* sumOfBeaons;
@property (strong,nonatomic)NSString* nearestBeaconName;
@property (strong,nonatomic)NSString* nearestDistance;
@property (nonatomic, copy)NSArray*  beaconArray;
@property (nonatomic)NSInteger count;
@property (nonatomic,strong)NSTimer *time;
@property (strong, nonatomic) IBOutlet UIButton *showResult;
@property (nonatomic) BOOL uploadFlag;
@property (nonatomic) BOOL predictFlag;
@property (strong, nonatomic) IBOutlet UILabel *predictiveLabel;
@property (nonatomic,strong)NSTimer *predictiveTime;
@property (nonatomic, retain) NSMutableArray* points;
@property (nonatomic, retain) MKPolyline* routeLine;
@property (nonatomic, retain) MKPolylineView* routeLineView;


@end
