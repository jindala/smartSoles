//
//  SSDataFormulationAndSave.h
//  SmartSoles
//
//  Created by Anupam Jindal on 3/29/14.
//  Copyright (c) 2014 Anupam Jindal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSDataFormulationAndSave : NSObject

+(NSDictionary *)formulateAndSaveSoleData:(NSNumber *)incomingValue;

+(NSArray *)retrieveAndFormulateActivityData;

@end
