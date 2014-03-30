//
//  SSDataFormulationAndSave.m
//  SmartSoles
//
//  Created by Anupam Jindal on 3/29/14.
//  Copyright (c) 2014 Anupam Jindal. All rights reserved.
//

#import "SSDataFormulationAndSave.h"
#import "Activity+Utility.h"
#import "SSSession.h"

@implementation SSDataFormulationAndSave

+(void)formulateAndSaveSoleData:(NSNumber *)incomingValue {
    
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setObject:[NSNumber numberWithInteger:currentTime] forKey:@"timeInMilis"];
    [dictionary setObject:incomingValue forKey:@"resistance"];
    [dictionary setObject:@"Hurdle" forKey:@"gameName"];
    [dictionary setObject:[NSNumber numberWithInt:1] forKey:@"footPos"];
    
    [Activity saveNewActivityWithDictionary:dictionary inManagedDataObject:[SSSession sharedSession].context];
}

+(NSArray *)retrieveAndFormulateActivityData {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Activity"];
    //request.predicate = [NSPredicate predicateWithFormat:@"chatID = %@", chatID];
    
    NSError *error;
    NSArray *matches = [[SSSession sharedSession].context executeFetchRequest:request error:&error];
    
    NSLog(@"I have retrieved the data %@", matches);
    
    return matches;
}

@end
