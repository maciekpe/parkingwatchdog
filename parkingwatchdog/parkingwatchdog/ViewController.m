//
//  ViewController.m
//  parkingwatchdog
//
//  Created by Maciek on 05.09.2016.
//  Copyright © 2016 mpe. All rights reserved.
//

#import "ViewController.h"
#import "GTLService.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "LocationService.h"
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController ()<CLLocationManagerDelegate>

@property (nonatomic, strong) GTLService *service;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIButton *workBtn;
@property (weak, nonatomic) IBOutlet UIButton *homeBtn;
@property (weak, nonatomic) IBOutlet UIButton *analysisBtn;

@end

static NSString *const kKeychainItemName = @"parkingwatchdog";
static NSString *const kClientID = @"829224129199-o2i8n6lijmj02sqftomb2g0h5gtan4en.apps.googleusercontent.com";

@implementation ViewController

@synthesize service = _service;

- (IBAction)exitAction:(id)sender {
    UIApplication *app = [UIApplication sharedApplication];
    [app performSelector:@selector(suspend)];
    [NSThread sleepForTimeInterval:2.0];
    exit(0);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.service = [[GTLService alloc] init];
    self.service.authorizer =
    [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                          clientID:kClientID
                                                      clientSecret:nil];
    //NSLog(@"Start");
    //[self listMajors];
    _locationMgr = [self createLocationManager];
    self.locationMgr.delegate = self;
    //[self.locationMgr startUpdatingLocation];
    
    if(_workBtn != nil){
        _workBtn.layer.cornerRadius = 5;
    }
    
    if(_homeBtn != nil){
        _homeBtn.layer.cornerRadius = 5;
    }
    
    if(_analysisBtn != nil){
        _analysisBtn.layer.cornerRadius = 5;
    }
    
    NSLog(@"END");
    // Do any additional setup after loading the view, typically from a nib.
}

- (CLLocationManager* ) createLocationManager {
    if ([CLLocationManager locationServicesEnabled]){
     NSLog(@"OK");
    } else {
     NSLog(@"dupa");   
    }
    CLLocationManager* locationManager = [[CLLocationManager alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    locationManager.distanceFilter = 100;
    if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [locationManager requestAlwaysAuthorization];
    }
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationManager requestWhenInUseAuthorization];
    }
    return locationManager;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"didUpdateLocations ");
}

- (void)viewDidAppear:(BOOL)animated {
}

- (GTMOAuth2ViewControllerTouch *)createAuthController {
    GTMOAuth2ViewControllerTouch *authController;
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    NSArray *scopes = [NSArray arrayWithObjects:@"https://www.googleapis.com/auth/spreadsheets.readonly", nil];
    authController = [[GTMOAuth2ViewControllerTouch alloc]
                      initWithScope:[scopes componentsJoinedByString:@" "]
                      clientID:kClientID
                      clientSecret:nil
                      keychainItemName:kKeychainItemName
                      delegate:self
                      finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    return authController;
}

// Handle completion of the authorization process, and update the Google Sheets API
// with the new credentials.
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)authResult
                 error:(NSError *)error {
    if (error != nil) {
        [self showAlert:@"Authentication Error" message:error.localizedDescription];
        self.service.authorizer = nil;
    }
    else {
        self.service.authorizer = authResult;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showPlacesForToday {
    NSString *baseUrl = @"https://sheets.googleapis.com/v4/spreadsheets/";
    NSString *spreadsheetId = @"1jClAjuaKaIHeygHsYOxmAL4pQbZ0u6_hT7i6d1j7Mt0";
    NSString *range = @"September!A:F";
    baseUrl = [baseUrl stringByAppendingString:spreadsheetId];
    baseUrl = [baseUrl stringByAppendingString:@"/values/"];
    baseUrl = [baseUrl stringByAppendingString:range];
    
    [self.service fetchObjectWithURL:[NSURL URLWithString:baseUrl]
                         objectClass:[GTLObject class]
                            delegate:self
                   didFinishSelector:@selector(displayPlacesForTodayWithServiceTicket:finishedWithObject:error:)];
}
- (IBAction)wayToWorkAction:(id)sender {
    if ([[UIApplication sharedApplication] canOpenURL:
         [NSURL URLWithString:@"comgooglemaps://"]]) {
        [[UIApplication sharedApplication] openURL:
         [NSURL URLWithString:@"comgooglemaps://?saddr=Faraona+11,+Pruszkow&daddr=Aleje+Jerozolimskie+92,+Warszawa&views=traffic&directionsmode=driving"]];
    } else {
        NSLog(@"Can't use comgooglemaps://");
    }
}
- (IBAction)wayToHomeAction:(id)sender {
    if ([[UIApplication sharedApplication] canOpenURL:
         [NSURL URLWithString:@"comgooglemaps://"]]) {
        [[UIApplication sharedApplication] openURL:
         [NSURL URLWithString:@"comgooglemaps://?daddr=Faraona+11,+Pruszkow&saddr=Aleje+Jerozolimskie+92,+Warszawa&views=traffic&directionsmode=driving"]];
    } else {
        NSLog(@"Can't use comgooglemaps://");
    }
}
- (IBAction)analysisAction:(id)sender {
    if (!self.service.authorizer.canAuthorize) {
        // Not yet authorized, request authorization by pushing the login UI onto the UI stack.
        [self presentViewController:[self createAuthController] animated:YES completion:nil];
        
    } else {
        [self showPlacesForToday];
    }
}

- (void)displayPlacesForTodayWithServiceTicket:(GTLServiceTicket *)ticket
                    finishedWithObject:(GTLObject *)object
                                 error:(NSError *)error {
    NSLog(@"Result");
    //NSDate *now = [NSDate date];
    //NSDate *tommorow = [now dateByAddingTimeInterval:60*60*24*1];
    //NSDate *dayAfterTommorow = [now dateByAddingTimeInterval:60*60*24*1];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    
    [df setDateFormat:@"dd'.'MM"];
    NSString *myDayString = [df stringFromDate:[NSDate date]];
    
    [df setDateFormat:@"mm"];
    NSLog(@"myDayString %@.", myDayString);
    if (error == nil) {
        NSMutableString *output = [[NSMutableString alloc] init];
        NSArray *rows = [object.JSON objectForKey:@"values"];
        if (rows.count > 0) {
            [output appendString:@""];
            for (NSArray *row in rows) {
                // Print columns A and E, which correspond to indices 0 and 4.
                NSMutableArray *places = [NSMutableArray arrayWithObjects:@"WOLNE",
                                    @"WOLNE", @"WOLNE", @"WOLNE", @"WOLNE", nil];
                if(row.count > 1){
                    NSString *dateString = row[0];
                    if ([dateString containsString:myDayString]){
                        
                        for (int i=1; i<[row count]; i++) {
                            NSString *value = row[i];
                            if([value length]  != 0) {
                               [places insertObject:row[i] atIndex:i-1];
                            }
                        }
                        [output appendFormat:@"[360->%@]\n[136->%@]\n[137->%@]\n[356->%@]\n[28->%@]",  places[0], places[1], places[2],  places[3], places[4]];
                        [output appendString:@"\n\n----------------------\n\n"];
                        UILocalNotification *notification = [[UILocalNotification alloc] init];
                        notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1200];
                        notification.alertBody = output;
                        [[UIApplication sharedApplication] scheduleLocalNotification:notification];

                    }
                    //[output appendFormat:@"%@ , %@, %@\n", row[0],  row[1], row[2]];
                }
            }
        } else {
            [output appendString:@"No data found."];
        }
        //self.output.text = output;
        NSLog(@"OUT %@.", output);
        _textView.layer.cornerRadius=5;
        _textView.text = output;
        _textView.textAlignment=NSTextAlignmentCenter;
        _textView.font = [UIFont boldSystemFontOfSize:16];
        _textView.textColor=[UIColor blackColor];
        
        
    } else {
        NSMutableString *message = [[NSMutableString alloc] init];
        [message appendFormat:@"Error getting sheet data: %@\n", error.localizedDescription];
        [self showAlert:@"Error" message:message];
    }
}

- (void)showAlert:(NSString *)title message:(NSString *)message {
    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:title
                                        message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok =
    [UIAlertAction actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
     {
         [alert dismissViewControllerAnimated:YES completion:nil];
     }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
    
}

@end
