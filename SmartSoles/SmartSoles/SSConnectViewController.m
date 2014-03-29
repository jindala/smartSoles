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

- (IBAction)switchFlipped:(id)sender {
    UInt8 buf[2] = {0x02, 0x00};
    UISwitch *switchButton= (UISwitch *)sender;
    
    if (switchButton.on) {
        buf[1]=0x01;
    } else {
        buf[1]=0x00;
    }
    
    NSData *data = [[NSData alloc] initWithBytes:buf length:2];
    [_ble write:data];
}

// When data is comming, this will be called
-(void) bleDidReceiveData:(unsigned char *)data length:(int)length
{
    NSLog(@"Length: %d", length);
    
    // parse data, all commands are in 3-byte
    for (int i = 0; i < length; i+=3)
    {
        NSLog(@"0x%02X, 0x%02X, 0x%02X", data[i], data[i+1], data[i+2]);
        
        if (data[i] == 0x0A)
        {
            
        }
        else if (data[i] == 0x0B) {
            //analog read
            UInt16 Value;
            
            Value = data[i+2] | data[i+1] << 8;
            analogInLabel.text = [NSString stringWithFormat:@"Analog: %d", Value];
        }
    }
}

/* Send command to Arduino to enable analog reading */
-(IBAction)sendAnalogIn:(id)sender
{
    UInt8 buf[3] = {0xA0, 0x01, 0x00};
    
    buf[1] = 0x01;
    
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [_ble write:data];
}

#pragma mark BLE controls

- (IBAction)connectButtonPressed:(id)sender {
    if (_ble.activePeripheral)
        if(_ble.activePeripheral.state == CBPeripheralStateConnected)
        {
            [[_ble CM] cancelPeripheralConnection:[_ble activePeripheral]];
            [connectButton setTitle:@"Connect" forState:UIControlStateNormal];
            return;
        }
    
    if (_ble.peripherals) {
        _ble.peripherals = nil;
    }
    
    [connectButton setEnabled:false];
    [_ble findBLEPeripherals:2];
    
    [NSTimer scheduledTimerWithTimeInterval:(float)2.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
    
    [connectIndicator startAnimating];
}

-(void) connectionTimer:(NSTimer *)timer
{
    [connectButton setEnabled:true];
    [connectButton setTitle:@"Disconnect" forState:UIControlStateNormal];

    if (_ble.peripherals.count > 0)
    {
        [_ble connectPeripheral:[_ble.peripherals objectAtIndex:0]];
    }
    else
    {
        [connectButton setTitle:@"Connect" forState:UIControlStateNormal];
        [connectIndicator stopAnimating];
    }
}
// When disconnected, this will be called
-(void) bleDidConnect {
    NSLog(@"->Connected");
    
    [connectIndicator stopAnimating];
    [ledSwitch setUserInteractionEnabled:TRUE];
    [readButton setEnabled:TRUE];
    
    // send reset
    UInt8 buf[] = {0x04, 0x00, 0x00};
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [_ble write:data];
}

- (void)bleDidDisconnect {
    NSLog(@"->Disconnected");
    
    [connectButton setTitle:@"Connect" forState:UIControlStateNormal];
    [connectIndicator stopAnimating];
    [ledSwitch setUserInteractionEnabled:FALSE];
    [readButton setEnabled:FALSE];
}
@end
