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

- (IBAction)bleConnection:(id)sender {
    if (_ble.activePeripheral)
        if(_ble.activePeripheral.state == CBPeripheralStateConnected)
        {
            [[_ble CM] cancelPeripheralConnection:[_ble activePeripheral]];
            [_connectButton setTitle:@"Connect" forState:UIControlStateNormal];
            return;
        }
    
    if (_ble.peripherals)
        _ble.peripherals = nil;
    
    [_connectButton setEnabled:false];
    [_ble findBLEPeripherals:2];
    
    [NSTimer scheduledTimerWithTimeInterval:(float)2.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
    
    [_activityIndicator startAnimating];
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
        [_activityIndicator stopAnimating];
    }
}


-(void) bleDidConnect
{
    NSLog(@"->Connected");
    
    [_activityIndicator stopAnimating];
    
    // send reset
    UInt8 buf[] = {0x04, 0x00, 0x00}; //pin, action, ??
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [_ble write:data];
}

- (void)bleDidDisconnect
{
    NSLog(@"->Disconnected");
    
    [_connectButton setTitle:@"Connect" forState:UIControlStateNormal];
    [_activityIndicator stopAnimating];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
