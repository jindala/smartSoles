//
//  User+Utility.m
//  SmartSoles
//
//  Created by Anupam Jindal on 3/29/14.
//  Copyright (c) 2014 Anupam Jindal. All rights reserved.
//

#import "User+Utility.h"

@implementation User (Utility)

+(User *) saveNewUserWithDictionary:(NSDictionary *)userDictionary inManagedDataObject:(NSManagedObjectContext *)managedObject {
    
    User *user = nil;
    
    user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:managedObject];
    user.name = userDictionary[@"name"];
    user.deviceId = userDictionary[@"deviceId"];
    user.fb_id = userDictionary[@"fb_id"];
    
    return user;
}

@end
