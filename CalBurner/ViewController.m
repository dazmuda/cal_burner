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

@end

@implementation ViewController
@synthesize bodyWeightField = _bodyWeightField;
@synthesize calSecLabel = _calSecLabel;
@synthesize totalCalLabel = _totalCalLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //1
    self.locationManager = [[CLLocationManager alloc]init];
    [self.locationManager setDelegate:self];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.locationManager startUpdatingLocation];
    self.bodyWeight = 73;
    self.runStarted = NO;
}

- (void)viewDidUnload
{
    [self setBodyWeightField:nil];
    [self setCalSecLabel:nil];
    [self setTotalCalLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
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
        speedMPS = timePassedInSec/distanceRun;
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

    double calBurned = calPerSec*timePassedInSec;
    self.totalCalBurned += calBurned;
    self.calSecLabel.text = [NSString stringWithFormat:@"%f", calPerSec];
    self.totalCalLabel.text = [NSString stringWithFormat:@"%f", self.totalCalBurned];
}

- (IBAction)startButton {
    self.totalCalBurned = 0;
    self.runStarted = YES;

}

- (IBAction)endButton {
    [self.locationManager stopUpdatingLocation];
}
@end
