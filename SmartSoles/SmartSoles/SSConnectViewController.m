//
//  SSConnectViewController.m
//  SmartSoles
//
//  Created by Daniel Chen on 3/29/14.
//  Copyright (c) 2014 Anupam Jindal. All rights reserved.
//

#import "SSConnectViewController.h"
#import "SSDataFormulationAndSave.h"
#import "SSSession.h"
#import "SSGameViewController.h"
#import "SSHomeViewController.h"

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
    
    [SSSession sharedSession].ble = [[BLE alloc] init];
    [[SSSession sharedSession].ble controlSetup];
    [SSSession sharedSession].ble.delegate = self;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"splashScreenBackground"]];
    
    [self.view addSubview:imageView ];
    [self.view sendSubviewToBack:imageView ];
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
    [[SSSession sharedSession].ble write:data];
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
            UInt16 value;
            
            value = data[i+2] | data[i+1] << 8;
            analogInLabel.text = [NSString stringWithFormat:@"Analog: %d", value];
            [SSDataFormulationAndSave formulateAndSaveSoleData:[NSNumber numberWithInteger:value]];
        }
    }
}

/* Send command to Arduino to enable analog reading */
-(IBAction)sendAnalogIn:(id)sender
{
    /*for (int i=0; i<50; i++) {
        [self pullData];
        [NSThread sleepForTimeInterval:0.5];
    }*/
    [SSDataFormulationAndSave retrieveAndFormulateActivityData];
    [self pullData];
}

-(void)pullData {
    UInt8 buf[3] = {0xA0, 0x01, 0x00};
    
    buf[1] = 0x01;
    
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [[SSSession sharedSession].ble write:data];
}



#pragma mark BLE controls

- (IBAction)connectButtonPressed:(id)sender {
    if ([SSSession sharedSession].ble.activePeripheral)
        if([SSSession sharedSession].ble.activePeripheral.state == CBPeripheralStateConnected)
        {
            [[[SSSession sharedSession].ble CM] cancelPeripheralConnection:[[SSSession sharedSession].ble activePeripheral]];
            [connectButton setTitle:@"Connect" forState:UIControlStateNormal];
            return;
        }
    
    if ([SSSession sharedSession].ble.peripherals) {
        [SSSession sharedSession].ble.peripherals = nil;
    }
    
    [connectButton setEnabled:false];
    [[SSSession sharedSession].ble findBLEPeripherals:2];
    
    [NSTimer scheduledTimerWithTimeInterval:(float)2.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
    
    [connectIndicator startAnimating];
}

-(void) connectionTimer:(NSTimer *)timer
{
    [connectButton setEnabled:true];
    [connectButton setTitle:@"Disconnect" forState:UIControlStateNormal];

    if ([SSSession sharedSession].ble.peripherals.count > 0)
    {
        [[SSSession sharedSession].ble connectPeripheral:[[SSSession sharedSession].ble.peripherals objectAtIndex:0]];
    }
    else
    {
        [connectButton setTitle:@"Connect" forState:UIControlStateNormal];
        [connectIndicator stopAnimating];
        [self goToNextScreen];
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
    [[SSSession sharedSession].ble write:data];
    
    [SSSession sharedSession].name = self.nameTextField.text;
    
    [self goToNextScreen];
}

-(void)goToNextScreen {
    //Go to next screen
    //SSGameViewController *gameController = [[SSGameViewController alloc] initWithNibName:@"SSGameViewController" bundle:nil];
    
    SSHomeViewController *homeVC = [[SSHomeViewController alloc] initWithNibName:@"SSHomeViewController" bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:homeVC];
    [SSSession sharedSession].navController = navController;
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)bleDidDisconnect {
    NSLog(@"->Disconnected");
    
    [connectButton setTitle:@"Connect" forState:UIControlStateNormal];
    [connectIndicator stopAnimating];
    [ledSwitch setUserInteractionEnabled:FALSE];
    [readButton setEnabled:FALSE];
}
@end
