//
//  SSAppDelegate.m
//  SmartSoles
//
//  Created by Anupam Jindal on 3/28/14.
//  Copyright (c) 2014 Anupam Jindal. All rights reserved.
//

#import "SSAppDelegate.h"
#import "SSHistoryViewController.h"
#import "SSConnectViewController.h"
#import "SSSession.h"
#import "SSAppDelegate+MOC.h"
#import "SSFriendsViewController.h"

@implementation SSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [SSSession sharedSession].context = [self createMainQueueManagedObjectContext];
    
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor grayColor];
    
    [FBLoginView class];
    
    [self userLoggedOut];

    
    /*SSHistoryViewController *historyVC = [[SSHistoryViewController alloc] initWithNibName:@"SSHistoryViewController" bundle:nil];
    
    SSConnectViewController *ssConnect = [[SSConnectViewController alloc] initWithNibName:@"SSConnectViewController" bundle:nil];
    
    self.window.rootViewController = ssConnect;

    [self.window makeKeyAndVisible];*/
    return YES;
}

-(void)userLoggedOut {
    SSConnectViewController *ssConnect = [[SSConnectViewController alloc] initWithNibName:@"SSConnectViewController" bundle:nil];
    
    self.window.rootViewController = ssConnect;
    [self.window makeKeyAndVisible];
}


-(void)showMessage:(NSString *)alertText withTitle:(NSString *)alertTitle {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle message:alertText delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}

// During the Facebook login flow, your app passes control to the Facebook iOS app or Facebook in a mobile browser.
// After authentication, your app will be called back with the session information.
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    
    [FBSession.activeSession setStateChangeHandler:
     ^(FBSession *session, FBSessionState state, NSError *error) {
         
         // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
         //[self sessionStateChanged:session state:state error:error];
     }];
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
