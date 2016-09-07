//
//  ViewController.h
//  parkingwatchdog
//
//  Created by Maciek on 05.09.2016.
//  Copyright © 2016 mpe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationService.h"

@interface ViewController : UIViewController
    @property (nonatomic, strong, readonly) LocationService* locationService;
    @property (nonatomic, strong, readonly) CLLocationManager* locationMgr;
@end

