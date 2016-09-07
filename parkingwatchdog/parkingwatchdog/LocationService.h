//
//  ViewController.h
//  parkingwatchdog
//
//  Created by Maciek on 05.09.2016.
//  Copyright © 2016 mpe. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <Foundation/Foundation.h>

@interface LocationService : NSObject
    + (instancetype) sharedInstance;
    - (void) startUpdatingLocation;
@end

