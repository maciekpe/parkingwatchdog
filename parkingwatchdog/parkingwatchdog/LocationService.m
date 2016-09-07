//
//  ViewController.m
//  parkingwatchdog
//
//  Created by Maciek on 05.09.2016.
//  Copyright © 2016 mpe. All rights reserved.
//

#import "LocationService.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationService () <CLLocationManagerDelegate>
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSDate *lastTimestamp;

@end

@implementation LocationService

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        LocationService *instance = sharedInstance;
        instance.locationManager = [CLLocationManager new];
        instance.locationManager.delegate = instance;
        instance.locationManager.desiredAccuracy = kCLLocationAccuracyBest; // you can use kCLLocationAccuracyHundredMeters to get better battery life
        instance.locationManager.pausesLocationUpdatesAutomatically = NO; // this is important
    });
    
    return sharedInstance;
}

- (void)startUpdatingLocation
{
    NSLog(@"startUpdatingLocation 1");
    [self.locationManager requestAlwaysAuthorization];
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    if (status == kCLAuthorizationStatusDenied)
    {
        NSLog(@"Location services are disabled in settings.");
    }
    else
    {
        NSLog(@"startUpdatingLocation 2");
        // for iOS 9
        if ([self.locationManager respondsToSelector:@selector(setAllowsBackgroundLocationUpdates:)])
        {
            [self.locationManager setAllowsBackgroundLocationUpdates:YES];
        }
        
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager startUpdatingLocation];
        NSLog(@"startUpdatingLocation 3");
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *mostRecentLocation = locations.lastObject;
    NSLog(@"Current location: %@ %@", @(mostRecentLocation.coordinate.latitude), @(mostRecentLocation.coordinate.longitude));
    
    NSDate *now = [NSDate date];
    NSTimeInterval interval = self.lastTimestamp ? [now timeIntervalSinceDate:self.lastTimestamp] : 0;
    
    if (!self.lastTimestamp || interval >= 5 * 10)
    {
        self.lastTimestamp = now;
        NSLog(@"Sending current location to web service.");
    }
}

@end