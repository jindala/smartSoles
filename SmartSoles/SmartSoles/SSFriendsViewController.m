//
//  SSFriendsViewController.m
//  SmartSoles
//
//  Created by Anupam Jindal on 3/30/14.
//  Copyright (c) 2014 Anupam Jindal. All rights reserved.
//

#import "SSFriendsViewController.h"

@interface SSFriendsViewController ()

@end

@implementation SSFriendsViewController

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
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"friendsScreen1"]];
    
    [self.view addSubview:imageView ];
    [self.view sendSubviewToBack:imageView ];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
