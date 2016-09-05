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

@interface ViewController ()

@property (nonatomic, strong) GTLService *service;

@end

static NSString *const kKeychainItemName = @"parkingwatchdog";
static NSString *const kClientID = @"829224129199-o2i8n6lijmj02sqftomb2g0h5gtan4en.apps.googleusercontent.com";

@implementation ViewController

@synthesize service = _service;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.service = [[GTLService alloc] init];
    self.service.authorizer =
    [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                          clientID:kClientID
                                                      clientSecret:nil];
    //NSLog(@"Start");
    //[self listMajors];
    NSLog(@"END");
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
    if (!self.service.authorizer.canAuthorize) {
        // Not yet authorized, request authorization by pushing the login UI onto the UI stack.
        [self presentViewController:[self createAuthController] animated:YES completion:nil];
        
    } else {
        [self listMajors];
    }
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

- (void)listMajors {
    NSString *baseUrl = @"https://sheets.googleapis.com/v4/spreadsheets/";
    NSString *spreadsheetId = @"1jClAjuaKaIHeygHsYOxmAL4pQbZ0u6_hT7i6d1j7Mt0";
    NSString *range = @"September!A:F";
    baseUrl = [baseUrl stringByAppendingString:spreadsheetId];
    baseUrl = [baseUrl stringByAppendingString:@"/values/"];
    baseUrl = [baseUrl stringByAppendingString:range];
    
    [self.service fetchObjectWithURL:[NSURL URLWithString:baseUrl]
                         objectClass:[GTLObject class]
                            delegate:self
                   didFinishSelector:@selector(displayMajorsWithServiceTicket:finishedWithObject:error:)];
}

- (void)displayMajorsWithServiceTicket:(GTLServiceTicket *)ticket
                    finishedWithObject:(GTLObject *)object
                                 error:(NSError *)error {
    NSLog(@"Result");
    
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
                        [output appendFormat:@"[360->%@] \n [136->%@] \n [137->%@] \n [356->%@] \n [28->%@]",  places[0], places[1], places[2],  places[3], places[4]];
                        [self showAlert:dateString message:output];

                    }
                    //[output appendFormat:@"%@ , %@, %@\n", row[0],  row[1], row[2]];
                }
            }
        } else {
            [output appendString:@"No data found."];
        }
        //self.output.text = output;
        NSLog(@"OUT %@.", output);
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
