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
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIButton *workBtn;
@property (weak, nonatomic) IBOutlet UIButton *homeBtn;
@property (weak, nonatomic) IBOutlet UIButton *analysisBtn;
@property (weak, nonatomic) IBOutlet UIButton *place0Number;
@property (weak, nonatomic) IBOutlet UIButton *place1Number;
@property (weak, nonatomic) IBOutlet UIButton *place2Number;
@property (weak, nonatomic) IBOutlet UIButton *place3Number;
@property (weak, nonatomic) IBOutlet UIButton *place4Number;
@property (weak, nonatomic) IBOutlet UIButton *place0How;
@property (weak, nonatomic) IBOutlet UIButton *place1How;
@property (weak, nonatomic) IBOutlet UIButton *place2How;
@property (weak, nonatomic) IBOutlet UIButton *place3How;
@property (weak, nonatomic) IBOutlet UIButton *place4How;
@property (weak, nonatomic) IBOutlet UIButton *notifBtn;

@property (weak, nonatomic) IBOutlet UIButton *dayOfMonth0;
@property (weak, nonatomic) IBOutlet UIButton *dayOfMonth1;
@property (weak, nonatomic) IBOutlet UIButton *dayOfMonth2;
@property (weak, nonatomic) IBOutlet UIButton *dayOfMonth3;
@property (weak, nonatomic) IBOutlet UIButton *dayOfMonth4;
@property (weak, nonatomic) IBOutlet UIButton *freedays0;
@property (weak, nonatomic) IBOutlet UIButton *freedays1;
@property (weak, nonatomic) IBOutlet UIButton *freedays2;
@property (weak, nonatomic) IBOutlet UIButton *freedays3;
@property (weak, nonatomic) IBOutlet UIButton *freedays4;
@property (weak, nonatomic) IBOutlet UIButton *satus0;
@property (weak, nonatomic) IBOutlet UIButton *satus1;
@property (weak, nonatomic) IBOutlet UIButton *satus2;
@property (weak, nonatomic) IBOutlet UIButton *satus3;
@property (weak, nonatomic) IBOutlet UIButton *satus4;

@property (weak, nonatomic) IBOutlet UIButton *todayBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextDaysBtn;
@property (weak, nonatomic) IBOutlet UIButton *notif11;

@end

static NSString *const kKeychainItemName = @"parkingwatchdog";
static NSString *const kClientID = @"829224129199-o2i8n6lijmj02sqftomb2g0h5gtan4en.apps.googleusercontent.com";
static NSString *const kWorkURL = @"comgooglemaps://?saddr=Faraona+11,+Pruszkow&daddr=Aleje+Jerozolimskie+92,+Warszawa&views=traffic&directionsmode=driving";
static NSString *const kHomeURL = @"comgooglemaps://?daddr=Faraona+11,+Pruszkow&saddr=Aleje+Jerozolimskie+92,+Warszawa&views=traffic&directionsmode=driving";
static NSArray *kAllMsgArray = nil;
static NSString *kMsgWhenNavi = nil;

@implementation ViewController

@synthesize service = _service;

- (IBAction)exitAction:(id)sender {
    UIApplication *app = [UIApplication sharedApplication];
    [app performSelector:@selector(suspend)];
    [NSThread sleepForTimeInterval:1.0];
    exit(0);
}

- (IBAction)remaindAction:(id)sender {
    [self sendPendingMsg];
    [self processNotifications];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self hideViewElements];
    [self initGoogleServices];
    [self initViewElements];
    NSLog(@"END");
}

- (void)initViewElements {;
    self.navigationItem.title = @"WatchDog";
    [self processDefaultButton:_workBtn];
    [self processDefaultButton:_notifBtn];
    [self processDefaultButton:_homeBtn];
    [self processDefaultButton:_analysisBtn];
    [self processDefaultButton:_todayBtn];
    [self processDefaultButton:_nextDaysBtn];
    [self processDefaultButton:_notif11];
}

- (void)hideViewElements {;
    [self processButtonToHidden:_place0Number];
    [self processButtonToHidden:_place1Number];
    [self processButtonToHidden:_place2Number];
    [self processButtonToHidden:_place3Number];
    [self processButtonToHidden:_place4Number];
    [self processButtonToHidden:_place0How];
    [self processButtonToHidden:_place1How];
    [self processButtonToHidden:_place2How];
    [self processButtonToHidden:_place3How];
    [self processButtonToHidden:_place4How];
    
    [self processButtonToHidden:_dayOfMonth0];
    [self processButtonToHidden:_dayOfMonth1];
    [self processButtonToHidden:_dayOfMonth2];
    [self processButtonToHidden:_dayOfMonth3];
    [self processButtonToHidden:_dayOfMonth4];
    [self processButtonToHidden:_freedays0];
    [self processButtonToHidden:_freedays1];
    [self processButtonToHidden:_freedays2];
    [self processButtonToHidden:_freedays3];
    [self processButtonToHidden:_freedays4];
    [self processButtonToHidden:_satus0];
    [self processButtonToHidden:_satus1];
    [self processButtonToHidden:_satus2];
    [self processButtonToHidden:_satus3];
    [self processButtonToHidden:_satus4];
    
    [self processButtonToHidden:_todayBtn];
    [self processButtonToHidden:_nextDaysBtn];
    
    //[self processButtonToHidden:_notifBtn];
    //[self processButtonToHidden:_notif11];
    //[self processButtonToHidden:_notif12];
    //[self processButtonToHidden:_notif21];
    //[self processButtonToHidden:_notif22];
}

- (void) processDefaultButton: (UIButton*) button {
    //[button setTitle:text forState:UIControlStateNormal];
    if(button != nil){
        button.layer.cornerRadius = 7;
    }
    //UIImage *btnImage = [UIImage imageNamed:@"bulldog.jpg"];
    //UIImage *newImage = [btnImage stretchableImageWithLeftCapWidth:20.0 topCapHeight:20.0];
    //[button setImage:btnImage forState:UIControlStateNormal];
    //[button setImageEdgeInsets:UIEdgeInsetsMake(20, 20, 20, 20)];
    //[button sizeToFit];
    //[button setBackgroundImage:btnImage forState:UIControlStateNormal];
}

- (void) processButtonToHidden: (UIButton*) button {
    if(button != nil){
        [button setHidden:YES];
    }
}

- (void) processButtonToVisible: (UIButton*) button {
    int random = arc4random_uniform(4);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, random * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [button setHidden:NO];
        [button setNeedsLayout];
        [button layoutIfNeeded];
    });
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
    [self sendNavigationMsg];
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

- (void) processDailyReport:(NSArray*) places {
    NSMutableString *output = [[NSMutableString alloc] init];
    [output appendFormat:@"[360->%@]\n[136->%@]\n[137->%@]\n[356->%@]\n[28->%@]",  places[0], places[1], places[2],  places[3], places[4]];
    [self processButton:_place0How withValue:places[0] withGreen:[places[0] containsString:@"MaciekP"] withRed:NO withGrey:[places[0] containsString:@"WOLNE"]];
    [self processButton:_place1How withValue:places[1] withGreen:[places[1] containsString:@"MaciekP"] withRed:NO withGrey:[places[1] containsString:@"WOLNE"]];
    [self processButton:_place2How withValue:places[2] withGreen:[places[2] containsString:@"MaciekP"] withRed:NO withGrey:[places[2] containsString:@"WOLNE"]];
    [self processButton:_place3How withValue:places[3] withGreen:[places[3] containsString:@"MaciekP"] withRed:NO withGrey:[places[3] containsString:@"WOLNE"]];
    [self processButton:_place4How withValue:places[4] withGreen:[places[4] containsString:@"MaciekP"] withRed:NO withGrey:[places[4] containsString:@"WOLNE"]];
    [self processButton:_place0Number withValue:@"360" withGreen:[places[0] containsString:@"MaciekP"] withRed:NO withGrey:[places[0] containsString:@"WOLNE"]];
    [self processButton:_place1Number withValue:@"136" withGreen:[places[1] containsString:@"MaciekP"] withRed:NO withGrey:[places[1] containsString:@"WOLNE"]];
    [self processButton:_place2Number withValue:@"137" withGreen:[places[2] containsString:@"MaciekP"] withRed:NO withGrey:[places[2] containsString:@"WOLNE"]];
    [self processButton:_place3Number withValue:@"356" withGreen:[places[3] containsString:@"MaciekP"] withRed:NO withGrey:[places[3] containsString:@"WOLNE"]];
    [self processButton:_place4Number withValue:@"28" withGreen:[places[4] containsString:@"MaciekP"] withRed:NO withGrey:[places[4] containsString:@"WOLNE"]];
}

- (void) processFutureReport:(NSArray*) places {
    NSMutableString *output = [[NSMutableString alloc] init];
    [output appendFormat:@"[360->%@]\n[136->%@]\n[137->%@]\n[356->%@]\n[28->%@]",  places[0], places[1], places[2],  places[3], places[4]];
    [self processButton:_place0How withValue:places[0] withGreen:[places[0] containsString:@"MaciekP"] withRed:NO withGrey:[places[0] containsString:@"WOLNE"]];
    [self processButton:_place1How withValue:places[1] withGreen:[places[1] containsString:@"MaciekP"] withRed:NO withGrey:[places[1] containsString:@"WOLNE"]];
    [self processButton:_place2How withValue:places[2] withGreen:[places[2] containsString:@"MaciekP"] withRed:NO withGrey:[places[2] containsString:@"WOLNE"]];
    [self processButton:_place3How withValue:places[3] withGreen:[places[3] containsString:@"MaciekP"] withRed:NO withGrey:[places[3] containsString:@"WOLNE"]];
    [self processButton:_place4How withValue:places[4] withGreen:[places[4] containsString:@"MaciekP"] withRed:NO withGrey:[places[4] containsString:@"WOLNE"]];
    [self processButton:_place0Number withValue:@"360" withGreen:[places[0] containsString:@"MaciekP"] withRed:NO withGrey:[places[0] containsString:@"WOLNE"]];
    [self processButton:_place1Number withValue:@"136" withGreen:[places[1] containsString:@"MaciekP"] withRed:NO withGrey:[places[1] containsString:@"WOLNE"]];
    [self processButton:_place2Number withValue:@"137" withGreen:[places[2] containsString:@"MaciekP"] withRed:NO withGrey:[places[2] containsString:@"WOLNE"]];
    [self processButton:_place3Number withValue:@"356" withGreen:[places[3] containsString:@"MaciekP"] withRed:NO withGrey:[places[3] containsString:@"WOLNE"]];
    [self processButton:_place4Number withValue:@"28" withGreen:[places[4] containsString:@"MaciekP"] withRed:NO withGrey:[places[4] containsString:@"WOLNE"]];
}

- (void) processButton: (UIButton*) button withValue: (NSString*) text withGreen:(BOOL) isGreen withRed:(BOOL) isRed withGrey:(BOOL) isGrey{
    int random = arc4random_uniform(4);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, random * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [button setHidden:NO];
        [button setTitle:text forState:UIControlStateNormal];
        button.layer.cornerRadius = 7;
        if(isGreen){
            [button setBackgroundColor:[UIColor colorWithRed:38.0/255.0 green:158.0/255.0 blue:9.0/255.0 alpha:1]];
        }
        if(isRed){
            [button setBackgroundColor:[UIColor redColor]];
        }
        if(isGrey){
            [button setBackgroundColor:[UIColor grayColor]];
        }
        [button.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
        [button setNeedsLayout];
        [button layoutIfNeeded];
    });
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
    [output appendFormat:@"[%@][FREE->%d][%@]\n",  dateRowSelector, freeCount, reserved];
    return [output copy];
}

- (NSString*) notifyPendingReservation:(NSArray*) rows byDate:(NSDate*) date {
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
        return msg;
    }
    return @"";
}

- (NSArray*) getFastReportVector:(NSArray*) rows byDate:(NSDate*) date {
    NSString *dateRowSelector = [self getShortRowSelector:date];
    NSArray *places = [self getPlacesFrom:rows byDate:date];
    int freeCount = [self countOcurrencesIn:places byElementValue:@"WOLNE"];
    int myCount = [self countOcurrencesIn:places byElementValue:@"MaciekP"];
    NSLog(@"freeCount [%d]", freeCount);
    NSLog(@"myCount [%d]", myCount);
    NSMutableArray *result = [NSMutableArray arrayWithObjects:dateRowSelector, nil];
    [result addObject: [NSNumber numberWithInt:freeCount]];
    [result addObject: [NSNumber numberWithInt:myCount]];
    return [result copy];
}

- (void) processFastReport:(NSArray*) rows byDate:(NSDate*) date withButtonDay: (UIButton*) dayButton withButtonFree: (UIButton*) freeButton withButtonStatus: (UIButton*) statusButton {
    NSArray *vector = [self getFastReportVector:rows byDate:date];
    NSString* value = vector[0];
    int freeCount = [vector[1] intValue];
    int myCount = [vector[2] intValue];
    NSString* reserved = myCount != 0 ? @"OK" : @"NO";
    [self processButton:dayButton withValue:value withGreen:(myCount > 0) withRed:((myCount == 0) && (freeCount < 5)) withGrey:((myCount == 0) && (freeCount == 5))];
    [self processButton:freeButton withValue:[NSString stringWithFormat:@"%d", freeCount] withGreen:(myCount > 0) withRed:((myCount == 0) && (freeCount < 5)) withGrey:((myCount == 0) && (freeCount == 5))];
    [self processButton:statusButton withValue:reserved withGreen:(myCount > 0) withRed:((myCount == 0) && (freeCount < 5)) withGrey:((myCount == 0) && (freeCount == 5))];
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
        kMsgWhenNavi = reportMsg;
        NSLog(@"notification [%@]", reportMsg);
        
        [self processDailyReport:places];
        
        NSMutableString *monit = [[NSMutableString alloc] init];
        [monit appendString:[self getFastReportMessage:rows byDate:now_plus_1]];
        [monit appendString:[self getFastReportMessage:rows byDate:now_plus_2]];
        [monit appendString:[self getFastReportMessage:rows byDate:now_plus_3]];
        [monit appendString:[self getFastReportMessage:rows byDate:now_plus_4]];
        [monit appendString:[self getFastReportMessage:rows byDate:now_plus_5]];
        
        NSString* msg = @"";
        NSMutableArray *allMsgArray = [NSMutableArray arrayWithObjects:msg, nil];
        [allMsgArray addObject: [self notifyPendingReservation:rows byDate:now_plus_1]];
        [allMsgArray addObject: [self notifyPendingReservation:rows byDate:now_plus_2]];
        [allMsgArray addObject: [self notifyPendingReservation:rows byDate:now_plus_3]];
        [allMsgArray addObject: [self notifyPendingReservation:rows byDate:now_plus_4]];
        [allMsgArray addObject: [self notifyPendingReservation:rows byDate:now_plus_5]];
        kAllMsgArray = [allMsgArray copy];
        [self processNotifications];
        
        
        [self processFastReport:rows byDate:now_plus_1 withButtonDay:_dayOfMonth0 withButtonFree:_freedays0 withButtonStatus:_satus0];
        [self processFastReport:rows byDate:now_plus_2 withButtonDay:_dayOfMonth1 withButtonFree:_freedays1 withButtonStatus:_satus1];
        [self processFastReport:rows byDate:now_plus_3 withButtonDay:_dayOfMonth2 withButtonFree:_freedays2 withButtonStatus:_satus2];
        [self processFastReport:rows byDate:now_plus_4 withButtonDay:_dayOfMonth3 withButtonFree:_freedays3 withButtonStatus:_satus3];
        [self processFastReport:rows byDate:now_plus_5 withButtonDay:_dayOfMonth4 withButtonFree:_freedays4 withButtonStatus:_satus4];
        
        [self processButtonToVisible:_nextDaysBtn];
        [self processButtonToVisible:_todayBtn];
        
        NSLog(@"OUT %@.", monit);
        

    } else {
        NSMutableString *message = [[NSMutableString alloc] init];
        [message appendFormat:@"Error getting sheet data: %@\n", error.localizedDescription];
        [self showAlert:@"Error" message:message];
    }
}

-(void) processNotifications {
    int pendingMsgCount = [self countPendingMsg];
    [self processButton:_notif11 withValue:[NSString stringWithFormat:@"%d",pendingMsgCount] withGreen:(pendingMsgCount == 0) withRed:(pendingMsgCount > 0) withGrey:NO];
}

-(int) countPendingMsg{
    int count = 0;
    if(kAllMsgArray != nil) {
        for (int i=0; i<[kAllMsgArray count]; i++) {
            NSString *value = kAllMsgArray[i];
            if([value length]  != 0) {
                count ++;
            }
        }
    }
    return count;
}

-(void) sendNavigationMsg{
    if(kMsgWhenNavi != nil) {
        [self sendNotificationWith:kMsgWhenNavi withDelay:1200];
        kMsgWhenNavi = nil;
    }
}

-(void) sendPendingMsg{
    if(kAllMsgArray != nil) {
        for (int i=0; i<[kAllMsgArray count]; i++) {
            NSString *value = kAllMsgArray[i];
            if([value length]  != 0) {
                [self sendNotificationWith:value withDelay:60*60*2];
            }
        }
        kAllMsgArray = nil;
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
