//
//  Activity+Utility.m
//  SmartSoles
//
//  Created by Anupam Jindal on 3/29/14.
//  Copyright (c) 2014 Anupam Jindal. All rights reserved.
//

#import "Activity+Utility.h"

@implementation Activity (Utility)

+(Activity *) saveNewActivityWithDictionary:(NSDictionary *)activityDictionary inManagedDataObject:(NSManagedObjectContext *)managedObject {
    
    Activity *activity = nil;
    
    activity = [NSEntityDescription insertNewObjectForEntityForName:@"Activity" inManagedObjectContext:managedObject];
    activity.resistance = activityDictionary[@"resistance"];
    activity.timeInMilis = activityDictionary[@"timeInMilis"];
    activity.gameName = activityDictionary[@"gameName"];
    activity.footPos = activityDictionary[@"footPos"];
    
    return activity;
}

@end
