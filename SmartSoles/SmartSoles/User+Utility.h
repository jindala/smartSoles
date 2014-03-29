//
//  User+Utility.h
//  SmartSoles
//
//  Created by Anupam Jindal on 3/29/14.
//  Copyright (c) 2014 Anupam Jindal. All rights reserved.
//

#import "User.h"

@interface User (Utility)

+(User *)saveNewUserWithDictionary:(NSDictionary *)userDictionary inManagedDataObject:(NSManagedObjectContext *)managedObject;


@end
