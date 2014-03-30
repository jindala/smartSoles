//
//  SSHistoryViewController.m
//  SmartSoles
//
//  Created by Anupam Jindal on 3/29/14.
//  Copyright (c) 2014 Anupam Jindal. All rights reserved.
//

#import "SSHistoryViewController.h"
#import "SSAppDelegate.h"
#import "SSDataFormulationAndSave.h"

@interface SSHistoryViewController ()
@property (nonatomic, strong) NSArray *historicData;
@property (nonatomic, strong) NSArray *daysArray;

@end

@implementation SSHistoryViewController

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
    
    BEMSimpleLineGraphView *myGraph = [[BEMSimpleLineGraphView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
    myGraph.delegate = self;
    myGraph.enableTouchReport = YES;
    myGraph.enableBezierCurve = YES;
    myGraph.colorTop = [UIColor greenColor];
    myGraph.colorLine = [UIColor whiteColor];
    myGraph.colorBottom = [UIColor greenColor];
    myGraph.widthLine = 5.0;
    
    self.daysArray = [NSArray arrayWithObjects:@"Friday", @"Saturday", @"Sunday", nil];
    self.historicData = [SSDataFormulationAndSave retrieveAndFormulateActivityData];
    
    [self.view addSubview:myGraph];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - handle graph library delegate

-(NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph {
    return [self.historicData count];
}

-(CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index {
    NSDictionary *activityDict = [self.historicData objectAtIndex:index];
    NSNumber *resistance = activityDict[@"resistance"];
    return [resistance floatValue];
}

-(void)lineGraph:(BEMSimpleLineGraphView *)graph didTouchGraphWithClosestIndex:(NSInteger)index {
    
}

-(void)lineGraph:(BEMSimpleLineGraphView *)graph didReleaseTouchFromGraphWithClosestIndex:(CGFloat)index {
    
}
/*
-(NSInteger)numberOfGapsBetweenLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph {
    return [self.daysArray count];
}

-(NSString *)lineGraph:(BEMSimpleLineGraphView *)graph labelOnXAxisForIndex:(NSInteger)index {
    return [self.daysArray objectAtIndex:index];
}*/

@end
