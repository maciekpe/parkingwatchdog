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
@property (weak, nonatomic) IBOutlet UITextView *textViewRight;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIButton *workBtn;
@property (weak, nonatomic) IBOutlet UIButton *homeBtn;
@property (weak, nonatomic) IBOutlet UIButton *analysisBtn;
@property (weak, nonatomic) IBOutlet UITextView *textViewLeft;

@end

static NSString *const kKeychainItemName = @"parkingwatchdog";
static NSString *const kClientID = @"829224129199-o2i8n6lijmj02sqftomb2g0h5gtan4en.apps.googleusercontent.com";
static NSString *const kWorkURL = @"comgooglemaps://?saddr=Faraona+11,+Pruszkow&daddr=Aleje+Jerozolimskie+92,+Warszawa&views=traffic&directionsmode=driving";
static NSString *const kHomeURL = @"comgooglemaps://?daddr=Faraona+11,+Pruszkow&saddr=Aleje+Jerozolimskie+92,+Warszawa&views=traffic&directionsmode=driving";

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
    [self initGoogleServices];
    [self initViewElements];
    NSLog(@"END");
}

- (void)initViewElements {;
    self.navigationItem.title = @"WatchDog";
    if(_workBtn != nil){
        _workBtn.layer.cornerRadius = 5;
    }
    
    if(_homeBtn != nil){
        _homeBtn.layer.cornerRadius = 5;
    }
    
    if(_analysisBtn != nil){
        _analysisBtn.layer.cornerRadius = 5;
    }
    
    if(_textViewRight != nil){
        _textViewRight.layer.cornerRadius=5;
    }
    
    if(_textViewLeft != nil){
        _textViewLeft.layer.cornerRadius=5;
    }
    

}

- (void)initGoogleServices {;
    self.service = [[GTLService alloc] init];
    self.service.authorizer =
    [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                          clientID:kClientID
                                                      clientSecret:nil];
}

- (void)initLocationServices {;
    _locationMgr = [self createLocationManager];
    self.locationMgr.delegate = self;
    [self.locationMgr startUpdatingLocation];
}

- (CLLocationManager* ) createLocationManager {
    if ([CLLocationManager locationServicesEnabled]){
     NSLog(@"OK");
    } else {
     NSLog(@"not ok");
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

- (void)querySheet {
    NSString *baseUrl = @"https://sheets.googleapis.com/v4/spreadsheets/";
    NSString *spreadsheetId = @"1jClAjuaKaIHeygHsYOxmAL4pQbZ0u6_hT7i6d1j7Mt0";
    NSString *range = @"September!A:F";
    baseUrl = [baseUrl stringByAppendingString:spreadsheetId];
    baseUrl = [baseUrl stringByAppendingString:@"/values/"];
    baseUrl = [baseUrl stringByAppendingString:range];
    
    [self.service fetchObjectWithURL:[NSURL URLWithString:baseUrl]
                         objectClass:[GTLObject class]
                            delegate:self
                   didFinishSelector:@selector(processQuerySheetResult:finishedWithObject:error:)];
}

- (void)openGoogleMapsWith:(NSString *) url {
    if ([[UIApplication sharedApplication] canOpenURL:
         [NSURL URLWithString:@"comgooglemaps://"]]) {
        [[UIApplication sharedApplication] openURL:
         [NSURL URLWithString:url]];
    } else {
        NSLog(@"Can't use comgooglemaps://");
    }
}

- (IBAction)wayToWorkAction:(id)sender {
    [self openGoogleMapsWith:kWorkURL];
}
- (IBAction)wayToHomeAction:(id)sender {
    [self openGoogleMapsWith:kHomeURL];
}

- (IBAction)analysisAction:(id)sender {
    if (!self.service.authorizer.canAuthorize) {
        // Not yet authorized, request authorization by pushing the login UI onto the UI stack.
        [self presentViewController:[self createAuthController] animated:YES completion:nil];
        
    } else {
        [self querySheet];
    }
}

- (void)sendNotificationWith:(NSString *) msg withDelay:(NSTimeInterval)secs{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:secs];
    notification.alertBody = msg;
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

- (void)setLeftMonit:(NSString *) text {
    _textViewLeft.text = text;
    _textViewLeft.textAlignment=NSTextAlignmentCenter;
    _textViewLeft.font = [UIFont boldSystemFontOfSize:16];
    _textViewLeft.textColor=[UIColor blackColor];
}

- (void)setRightMonit:(NSString *) text {
    _textViewRight.text = text;
    _textViewRight.textAlignment=NSTextAlignmentCenter;
    _textViewRight.font = [UIFont boldSystemFontOfSize:16];
    _textViewRight.textColor=[UIColor blackColor];
}

- (NSString*)getRowSelector:(NSDate *) date {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd'.'MM"];
    NSString *result = [df stringFromDate: date];
    NSLog(@"result %@.", result);
    return result;
}

- (NSString*)getShortRowSelector:(NSDate *) date {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd"];
    NSString *result = [df stringFromDate: date];
    NSLog(@"result %@.", result);
    return result;
}

- (NSArray*)findRowElements:(NSArray *) rows bySelector: (NSString*) selector {
    NSMutableArray *result = [NSMutableArray arrayWithObjects:@"WOLNE",
                              @"WOLNE", @"WOLNE", @"WOLNE", @"WOLNE", nil];
    if (rows.count > 0) {
        for (NSArray *row in rows) {
            if(row.count > 1){
                NSString *dateString = row[0];
                if ([dateString containsString:selector]){
                    for (int i=1; i<[row count]; i++) {
                        NSString *value = row[i];
                        if([value length]  != 0) {
                            [result insertObject:row[i] atIndex:i-1];
                            [result removeLastObject];
                        }
                    }
                }
            }
        }
    }
    return [result copy];
}

- (NSString*) getReportMessage:(NSArray*) places {
    NSMutableString *output = [[NSMutableString alloc] init];
    [output appendFormat:@"[360->%@]\n[136->%@]\n[137->%@]\n[356->%@]\n[28->%@]",  places[0], places[1], places[2],  places[3], places[4]];
    return [output copy];
}

- (NSArray*) getPlacesFrom:(NSArray*)rows  byDate:(NSDate*) date {
    NSString *dateRowSelector = [self getRowSelector:date];
    NSLog(@"dateRowSelector %@", dateRowSelector);
    NSArray *places = [self findRowElements:rows bySelector:dateRowSelector];
    return places;
}

-(int) countOcurrencesIn: (NSArray*) row byElementValue: (NSString*) elementValue{
    int count = 0;
    for (int i=0; i<[row count]; i++) {
        NSString *value = row[i];
        if([value length]  != 0 && [value containsString:elementValue]) {
            count ++;
        }
    }
    return count;
}

- (NSString*) getFastReportMessage:(NSArray*) rows byDate:(NSDate*) date {
    NSMutableString *output = [[NSMutableString alloc] init];
    NSString *dateRowSelector = [self getShortRowSelector:date];
    NSArray *places = [self getPlacesFrom:rows byDate:date];
    int freeCount = [self countOcurrencesIn:places byElementValue:@"WOLNE"];
    int myCount = [self countOcurrencesIn:places byElementValue:@"MaciekP"];
    NSLog(@"freeCount [%d]", freeCount);
    NSLog(@"myCount [%d]", myCount);
    NSString* reserved = myCount != 0 ? @"OK" : @"NO";
    if(myCount == 0 && freeCount < 5) {
        NSMutableString *msg = [[NSMutableString alloc] init];
            [msg appendFormat:@"GO! [%@][FREE->%d][%@] reserve now\n",  dateRowSelector, freeCount, reserved];
        [self sendNotificationWith:msg withDelay:60*60*2];
         NSLog(@"notification [%@]", msg);
    }
    
    [output appendFormat:@"[%@][FREE->%d][%@]\n",  dateRowSelector, freeCount, reserved];
    return [output copy];
}

- (void)processQuerySheetResult:(GTLServiceTicket *)ticket
                    finishedWithObject:(GTLObject *)object
                                 error:(NSError *)error {
    NSLog(@"Result");

    if (error == nil) {
        NSArray *rows = [object.JSON objectForKey:@"values"];
        NSDate *now = [NSDate date];
        NSDate *now_plus_1 = [now dateByAddingTimeInterval:60*60*24*1];
        NSDate *now_plus_2 = [now dateByAddingTimeInterval:60*60*24*2];
        NSDate *now_plus_3 = [now dateByAddingTimeInterval:60*60*24*3];
        NSDate *now_plus_4 = [now dateByAddingTimeInterval:60*60*24*4];
        NSDate *now_plus_5 = [now dateByAddingTimeInterval:60*60*24*5];
        
        NSArray *places = [self getPlacesFrom:rows byDate:now];
        NSString *reportMsg = [self getReportMessage:places];
        [self sendNotificationWith:reportMsg withDelay:1200];
         NSLog(@"notification [%@]", reportMsg);
        [self setLeftMonit: reportMsg];
        
        NSMutableString *monit = [[NSMutableString alloc] init];
        [monit appendString:[self getFastReportMessage:rows byDate:now_plus_1]];
        [monit appendString:[self getFastReportMessage:rows byDate:now_plus_2]];
        [monit appendString:[self getFastReportMessage:rows byDate:now_plus_3]];
        [monit appendString:[self getFastReportMessage:rows byDate:now_plus_4]];
        [monit appendString:[self getFastReportMessage:rows byDate:now_plus_5]];
        [self setRightMonit: monit];
        NSLog(@"OUT %@.", monit);
        

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
