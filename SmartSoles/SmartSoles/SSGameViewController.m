//
//  SSGameViewController.m
//  SmartSoles
//
//  Created by Anupam Jindal on 3/29/14.
//  Copyright (c) 2014 Anupam Jindal. All rights reserved.
//

#import "SSGameViewController.h"
#import "SSMyScene.h"
#import "SSDataFormulationAndSave.h"
#import "SSSession.h"

@interface SSGameViewController ()

@end

@implementation SSGameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [SSSession sharedSession].ble.delegate = self;
        // Custom initialization
    }
    return self;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    if (!skView.scene) {
        skView.showsFPS = YES;
        skView.showsNodeCount = YES;
        
        // Create and configure the scene.
        SKScene * scene = [SSMyScene sceneWithSize:skView.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        
        // Present the scene.
        [skView presentScene:scene];
    }
    
    [NSTimer scheduledTimerWithTimeInterval:(float).10 target:self selector:@selector(sendAnalogIn:) userInfo:nil repeats:YES];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}


/* Send command to Arduino to enable analog reading */
-(IBAction)sendAnalogIn:(id)sender
{
    if([self isConnected])
        [self pullData];
}

-(void)pullData {
    UInt8 buf[3] = {0xA9, 0x01, 0x00};
    
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [[SSSession sharedSession].ble write:data];
}

#pragma mark BLE controls

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
            //analogInLabel.text = [NSString stringWithFormat:@"Analog: %d", value];
            NSDictionary *formulatedDict = [SSDataFormulationAndSave formulateAndSaveSoleData:[NSNumber numberWithInteger:value]];
            SKView * skView = (SKView *)self.view;
            if(skView.scene) {
                ((SSMyScene *)skView.scene).latestSoleData = [formulatedDict mutableCopy];
            }
        }
    }
}

-(BOOL)isConnected {
    if ([SSSession sharedSession].ble.activePeripheral) {
        if([SSSession sharedSession].ble.activePeripheral.state == CBPeripheralStateConnected)
        {
            return YES;
        }
    }
    
    return NO;
}

-(void) bleDidConnect {
    NSLog(@"->Connected");
    
    // send reset
    UInt8 buf[] = {0x04, 0x00, 0x00};
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [[SSSession sharedSession].ble write:data];
    
    [NSTimer scheduledTimerWithTimeInterval:(float)0.5 target:self selector:@selector(sendAnalogIn:) userInfo:nil repeats:YES];
}

- (void)bleDidDisconnect {
    NSLog(@"->Disconnected");
    
    [self showMessage:@"Sole disconnected" withTitle:@"Connection Lost"];
}

-(void)showMessage:(NSString *)alertText withTitle:(NSString *)alertTitle {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle message:alertText delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}

@end
