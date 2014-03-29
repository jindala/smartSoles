//
//  SSAppDelegate.h
//  SmartSoles
//
//  Created by Anupam Jindal on 3/28/14.
//  Copyright (c) 2014 Anupam Jindal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface SSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

-(void)sessionStateChanged:(FBSession *)session state:(FBSessionState)state error:(NSError *)error;

@end
