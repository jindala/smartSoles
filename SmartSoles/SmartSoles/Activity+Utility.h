//
//  Activity+Utility.h
//  SmartSoles
//
//  Created by Anupam Jindal on 3/29/14.
//  Copyright (c) 2014 Anupam Jindal. All rights reserved.
//

#import "Activity.h"

@interface Activity (Utility)

+(Activity *)saveNewActivityWithDictionary:(NSDictionary *)activityDictionary inManagedDataObject:(NSManagedObjectContext *)managedObject;

@end
