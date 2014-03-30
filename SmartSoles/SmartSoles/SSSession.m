//
//  SSSession.m
//  SmartSoles
//
//  Created by Anupam Jindal on 3/29/14.
//  Copyright (c) 2014 Anupam Jindal. All rights reserved.
//

#import "SSSession.h"

@implementation SSSession

static SSSession *sSharedSession = nil;

@synthesize context = _context;
@synthesize name = _name;

+ (SSSession*) sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}

+ (SSSession*)sharedSession
{
	@synchronized(self) {
		if (sSharedSession == nil) {
			sSharedSession = [self sharedInstance];
		}
	}
	return sSharedSession;
}

@end
