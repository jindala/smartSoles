//
//  SSCalorieLabel.m
//  SmartSoles
//
//  Created by Daniel Chen on 3/30/14.
//  Copyright (c) 2014 Anupam Jindal. All rights reserved.
//

#import "SSScoreLabel.h"

@interface SSScoreLabel ()

    @property (nonatomic) double score;

@end

@implementation SSScoreLabel

- (id)initScoreLabel
{
    self = [super initWithFontNamed:@"Symbol"];
    if(self)
    {
        self.name = @"calorieLabel";
        self.fontSize = 25;
        self.fontColor = [SKColor blackColor];
        self.text = @"0";
        _score = 0;
    }
    return self;
}

- (void)updateScoreLabel
{
    self.text = [NSString stringWithFormat:@"%.2f", self.score];
}

- (void)addScore:(double)value
{
    _score += value;
    [self updateScoreLabel];
}


@end
