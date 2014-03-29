//
//  SSConnectViewController.m
//  SmartSoles
//
//  Created by Daniel Chen on 3/29/14.
//  Copyright (c) 2014 Anupam Jindal. All rights reserved.
//

#import "SSConnectViewController.h"

@interface SSConnectViewController ()

@end

@implementation SSConnectViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _ble = [[BLE alloc] init];
    [_ble controlSetup];
    _ble.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark BLE controls

- (IBAction)connectButtonPressed:(id)sender {
    if (_ble.activePeripheral)
        if(_ble.activePeripheral.state == CBPeripheralStateConnected)
        {
            [[_ble CM] cancelPeripheralConnection:[_ble activePeripheral]];
            [_connectButton setTitle:@"Connect" forState:UIControlStateNormal];
            return;
        }
    
    if (_ble.peripherals) {
        _ble.peripherals = nil;
    }
    
    [_connectButton setEnabled:false];
    [_ble findBLEPeripherals:2];
    
    [NSTimer scheduledTimerWithTimeInterval:(float)2.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
    
    [_connectIndicator startAnimating];
}

-(void) connectionTimer:(NSTimer *)timer
{
    [_connectButton setEnabled:true];
    [_connectButton setTitle:@"Disconnect" forState:UIControlStateNormal];
    
    if (_ble.peripherals.count > 0)
    {
        [_ble connectPeripheral:[_ble.peripherals objectAtIndex:0]];
    }
    else
    {
        [_connectButton setTitle:@"Connect" forState:UIControlStateNormal];
        [_connectIndicator stopAnimating];
    }
}
// When disconnected, this will be called
-(void) bleDidConnect {
    NSLog(@"->Connected");
    
    [_connectIndicator stopAnimating];
    
    // send reset
    UInt8 buf[] = {0x04, 0x00, 0x00};
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [_ble write:data];
    
}

- (void)bleDidDisconnect {
    NSLog(@"->Disconnected");
    
    [_connectButton setTitle:@"Connect" forState:UIControlStateNormal];
    [_connectIndicator stopAnimating];
}

@end
