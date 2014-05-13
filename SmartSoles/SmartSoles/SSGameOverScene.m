//
//  SSGameOverScene.m
//  SmartSoles
//
//  Created by Daniel Chen on 3/29/14.
//  Copyright (c) 2014 Anupam Jindal. All rights reserved.
//

#import "SSGameOverScene.h"
#import "SSMyScene.h"

@implementation SSGameOverScene

-(id)initWithSize:(CGSize)size won:(BOOL)won {
    self = [super initWithSize:size];
    
    // Background
    SKSpriteNode *sn = [SKSpriteNode spriteNodeWithImageNamed:@"gameOverScreen"];
    sn.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [self addChild:sn];
    
    /*
    if(self) {
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    }
    
    NSString *message;
    if(won) {
        message = @"You won!";
    } else {
        message = @"You lose :[";
    }
    message = @"Calories Burnt: 20";
    
    SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    label.text = message;
    label.fontSize = 20;
    label.fontColor = [SKColor blackColor];
    label.position = CGPointMake(self.size.width/2, self.size.height /2);
    [self addChild:label];
    */
    
    [self runAction:
     [SKAction sequence:@[
                          [SKAction waitForDuration:3.0],
                          [SKAction runBlock:^{
         SKTransition *reveal = [SKTransition flipHorizontalWithDuration:2.0];
         SKScene *myScene = [[SSMyScene alloc] initWithSize:self.size];
         [self.view presentScene:myScene transition:reveal];
     }]
                          ]
      ]
     ];
    
    return self;
}


@end
