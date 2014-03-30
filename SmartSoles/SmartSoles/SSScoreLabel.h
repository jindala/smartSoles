//
//  SSCalorieLabel.h
//  SmartSoles
//
//  Created by Daniel Chen on 3/30/14.
//  Copyright (c) 2014 Anupam Jindal. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SSScoreLabel : SKLabelNode

- (id)initScoreLabel;
- (void)addScore:(double)value;

@end
