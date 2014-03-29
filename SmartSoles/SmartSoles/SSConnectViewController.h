//
//  SSConnectViewController.h
//  SmartSoles
//
//  Created by Daniel Chen on 3/29/14.
//  Copyright (c) 2014 Anupam Jindal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLE.h"

@interface SSConnectViewController : UIViewController<BLEDelegate> {
    IBOutlet UIButton *connectButton;
    IBOutlet UIActivityIndicatorView *connectIndicator;
    IBOutlet UISwitch *ledSwitch;
    IBOutlet UILabel *analogInLabel;
    IBOutlet UIButton *readButton;
}

@property (strong, nonatomic) BLE *ble;

@end
