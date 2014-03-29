//
//  SSAppDelegate+MOC.h
//  SmartSoles
//
//  Created by Anupam Jindal on 3/29/14.
//  Copyright (c) 2014 Anupam Jindal. All rights reserved.
//

#import "SSAppDelegate.h"

@interface SSAppDelegate (MOC)

- (NSManagedObjectContext *)createMainQueueManagedObjectContext;


@end
