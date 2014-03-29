//
//  SSHistoryViewController.m
//  SmartSoles
//
//  Created by Anupam Jindal on 3/29/14.
//  Copyright (c) 2014 Anupam Jindal. All rights reserved.
//

#import "SSHistoryViewController.h"
#import "SSAppDelegate.h"

@interface SSHistoryViewController ()

@end

@implementation SSHistoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    BEMSimpleLineGraphView *myGraph = [[BEMSimpleLineGraphView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
    myGraph.delegate = self;
    myGraph.enableTouchReport = YES;
    myGraph.enableBezierCurve = YES;
    myGraph.colorTop = [UIColor greenColor];
    myGraph.colorLine = [UIColor whiteColor];
    myGraph.colorBottom = [UIColor greenColor];
    myGraph.widthLine = 3.0;
    [self.view addSubview:myGraph];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginWithFacebook:(id)sender {
    // If the session state is any of the two "open" states when the button is clicked
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        
        NSLog(@"Startup: user is already logged in. We are not handling logout here");
        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        //[FBSession.activeSession closeAndClearTokenInformation];
        
        // If the session state is not any of the two "open" states when the button is clicked
    } else {
        // Open a session showing the user the login UI
        // You must ALWAYS ask for basic_info permissions when opening a session
        [FBSession openActiveSessionWithReadPermissions:@[@"basic_info", @"email"]
                                           allowLoginUI:YES
                                      completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             
             // Retrieve the app delegate
             SSAppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
             // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
             [appDelegate sessionStateChanged:session state:state error:error];
         }];
    }
}


#pragma mark - handle graph library delegate

-(NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph {
    return 10;
}

-(CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index {
    return 5.0;
}

-(void)lineGraph:(BEMSimpleLineGraphView *)graph didTouchGraphWithClosestIndex:(NSInteger)index {
    
}

-(void)lineGraph:(BEMSimpleLineGraphView *)graph didReleaseTouchFromGraphWithClosestIndex:(CGFloat)index {
    
}

-(NSInteger)numberOfGapsBetweenLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph {
    return 5;
}

-(NSString *)lineGraph:(BEMSimpleLineGraphView *)graph labelOnXAxisForIndex:(NSInteger)index {
    return @"day";
}

@end
