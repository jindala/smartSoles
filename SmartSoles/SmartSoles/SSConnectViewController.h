//
//  SSConnectViewController.h
//  SmartSoles
//
//  Created by Daniel Chen on 3/29/14.
//  Copyright (c) 2014 Anupam Jindal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLE.h"

@interface SSConnectViewController : UIViewController<BLEDelegate>

@property (strong, nonatomic) IBOutlet UIButton *connectButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *connectIndicator;
@property (strong, nonatomic) BLE *ble;

@end
