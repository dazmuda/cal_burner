//
//  ViewController.m
//  CalBurner
//
//  Created by Diana Zmuda on 8/16/12.
//  Copyright (c) 2012 Diana Zmuda. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>

// LOOK UP GPX files

@interface ViewController () <CLLocationManagerDelegate>

@property (strong) CLLocationManager* locationManager;
@property double bodyWeight;
@property double totalCalBurned;
@property BOOL runStarted;
//@property double totalTimePassed;
@property NSTimer *stopWatchTimer;
@property NSDate *startDate;

@end

@implementation ViewController
@synthesize bodyWeightField = _bodyWeightField;
@synthesize calSecLabel = _calSecLabel;
@synthesize totalCalLabel = _totalCalLabel;
@synthesize timerLabel = _timerLabel;
@synthesize mapView = _mapView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    //1
    self.locationManager = [[CLLocationManager alloc]init];
    [self.locationManager setDelegate:self];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.locationManager startUpdatingLocation];
    self.bodyWeight = 73;
    self.runStarted = NO;
    self.mapView.showsUserLocation = YES;
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
}

//3 reset current region when you are moving
-(void)zoomToRegion
{
    MKCoordinateRegion mapRegion;
    mapRegion.center.latitude = self.mapView.userLocation.coordinate.latitude;
    mapRegion.center.longitude = self.mapView.userLocation.coordinate.longitude;
    mapRegion.span.latitudeDelta = .05;
    mapRegion.span.longitudeDelta = .05;
    [self.mapView setRegion:mapRegion animated:YES];
    //check out distance filter on location manager
}

- (void)viewDidUnload
{
    [self setBodyWeightField:nil];
    [self setCalSecLabel:nil];
    [self setTotalCalLabel:nil];
    [self setMapView:nil];
    [self setTimerLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    //[self zoomToRegion];
    
    //NSLog(@"%f,%f", newLocation.coordinate.longitude, oldLocation.coordinate.longitude);
    
    //2
    //later, lets break this out into its own method!
    if (!self.runStarted){
        return;
    }
    double timePassedInSec = [newLocation.timestamp timeIntervalSinceDate: oldLocation.timestamp];
    double distanceRun = [newLocation distanceFromLocation:oldLocation];
    double speedMPS;
    if (distanceRun <=0) {
        speedMPS = 0;
    } else {
        speedMPS = distanceRun/timePassedInSec;
    }
    //NSLog(@"%f", speedMPS);
    double percentGrade;
    if (speedMPS == 0) {
        percentGrade = 0;
    } else {
        percentGrade = ((newLocation.altitude - oldLocation.altitude)/distanceRun)*100;
    }
    double vo2 = 3.5 + (speedMPS*60*.2) + (speedMPS*60*percentGrade*.9);
    double mets = fabs(vo2/3.5);
    double calPerSec = (mets*self.bodyWeight)/360;
    //double calPerHr = (mets*self.bodyWeight);
    double calBurned = calPerSec*timePassedInSec;
    self.totalCalBurned += calBurned;
    self.calSecLabel.text = [NSString stringWithFormat:@"%f", calPerSec];
    self.totalCalLabel.text = [NSString stringWithFormat:@"%f", self.totalCalBurned];
    
    //self.totalTimePassed += timePassedInSec;
    //self.timerLabel.text = [NSString stringWithFormat:@"%2f", self.totalTimePassed];
}

- (IBAction)startButton {
    self.totalCalBurned = 0;
    self.runStarted = YES;
    self.startDate = [NSDate date];
    self.stopWatchTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/10.0
                                                      target:self
                                                    selector:@selector(updateTimer)
                                                    userInfo:nil
                                                     repeats:YES];

}

- (void)updateTimer
{
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:self.startDate];
    NSDate *timerDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss.SSS"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    NSString *timeString=[dateFormatter stringFromDate:timerDate];
    self.timerLabel.text = timeString;
}

- (IBAction)endButton {
    [self.locationManager stopUpdatingLocation];
}


@end
