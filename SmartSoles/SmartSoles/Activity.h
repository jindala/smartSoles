//
//  Activity.h
//  SmartSoles
//
//  Created by Anupam Jindal on 3/29/14.
//  Copyright (c) 2014 Anupam Jindal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Activity : NSManagedObject

@property (nonatomic, retain) NSNumber * resistance;
@property (nonatomic, retain) NSNumber * timeInMilis;
@property (nonatomic, retain) NSString * gameName;
@property (nonatomic, retain) NSNumber * footPos;

@end
