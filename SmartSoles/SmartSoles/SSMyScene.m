//
//  SSMyScene.m
//  SmartSoles
//
//  Created by Anupam Jindal on 3/29/14.
//  Copyright (c) 2014 Anupam Jindal. All rights reserved.
//

#import "SSMyScene.h"
#import <math.h>

@interface SSMyScene ()
@property (nonatomic) SKSpriteNode * player;
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@end


@implementation SSMyScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        // 2
        NSLog(@"Size: %@", NSStringFromCGSize(size));
        
        // 3
        SKSpriteNode *sn = [SKSpriteNode spriteNodeWithImageNamed:@"welcomeScreen1"];
        sn.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        sn.name = @"BACKGROUND";
        sn.zPosition = -1;
        [self addChild:sn];
        
        // 4
        self.player = [SKSpriteNode spriteNodeWithImageNamed:@"player"];
        self.player.position = CGPointMake(self.player.size.width/2, self.frame.size.height/2);
        self.player.zPosition = 1;
        [self addChild:self.player];
        
        // 5
        SKShapeNode *yourline = [SKShapeNode node];
        
        CGMutablePathRef pathToDraw = CGPathCreateMutable();
        CGPathMoveToPoint(pathToDraw, NULL, 0, self.frame.size.height/2 -20);
        CGPathAddLineToPoint(pathToDraw, NULL, 568.0, self.frame.size.height/2 -20);
        yourline.path = pathToDraw;
        [yourline setStrokeColor:[UIColor grayColor]];
        yourline.zPosition = 0;
        [self addChild:yourline];
        
    }
    return self;
}

- (void)addMonster {
    
    // Create sprite
    SKSpriteNode * monster = [SKSpriteNode spriteNodeWithImageNamed:@"monster"];
    
    // Determine where to spawn the monster along the Y axis
    /*int minY = monster.size.height / 2;
     int maxY = self.frame.size.height - monster.size.height / 2;
     int rangeY = maxY - minY;*/
    int actualY = self.frame.size.height/2;
    
    // Create the monster slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    monster.position = CGPointMake(self.frame.size.width + monster.size.width/2, actualY);
    [self addChild:monster];
    
    // Determine speed of the monster
    int minDuration = 2.0;
    int maxDuration = 4.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    // Create the actions
    SKAction * actionMove = [SKAction moveTo:CGPointMake(-monster.size.width/2, actualY) duration:actualDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    [monster runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
    
}

- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    
    self.lastSpawnTimeInterval += timeSinceLast;
    if (self.lastSpawnTimeInterval > 2) {
        self.lastSpawnTimeInterval = 0;
        [self addMonster];
    }
}

- (void)update:(NSTimeInterval)currentTime {
    // Handle time delta.
    // If we drop below 60fps, we still want everything to move the same distance.
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) { // more than a second since last update
        timeSinceLast = 1.0 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
    }
    
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // Called when a touch begins
    
    for (UITouch *touch in touches) {
        //CGPoint location = [touch locationInNode:self];
        
        /*SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
         
         sprite.position = location;
         
         SKAction *action = [SKAction rotateByAngle:M_PI duration:1];
         
         [sprite runAction:[SKAction repeatActionForever:action]];
         
         [self addChild:sprite];*/
        
        
        SKAction *followTrack = [SKAction followPath:[self createJumpPath] asOffset:NO orientToPath:NO duration:1.0];
        //SKAction *forever = [SKAction ];
        
        [self.player runAction:followTrack];
    }
}

-(CGMutablePathRef) createJumpPath {
    int arcCenterX = self.player.frame.origin.x;
    CGPoint initialPoint = CGPointMake(arcCenterX+self.player.frame.size.width/2, self.player.frame.origin.y+self.player.frame.size.height/2);
    CGPoint firstPoint = CGPointMake(arcCenterX+self.player.frame.size.width/2, self.player.frame.origin.y + 50);
    CGPoint secondPoint = CGPointMake(arcCenterX+self.player.frame.size.width/2, self.frame.size.height/2);
    
    NSMutableArray *jumpPoints = [NSMutableArray arrayWithObjects:[NSValue valueWithCGPoint:initialPoint], [NSValue valueWithCGPoint:firstPoint], [NSValue valueWithCGPoint:secondPoint], nil];
    CGMutablePathRef path = CGPathCreateMutable();
    if (jumpPoints && jumpPoints.count > 0) {
        CGPoint p = [(NSValue *)[jumpPoints objectAtIndex:0] CGPointValue];
        CGPathMoveToPoint(path, nil, p.x, p.y);
        for (int i = 1; i < jumpPoints.count; i++) {
            p = [(NSValue *)[jumpPoints objectAtIndex:i] CGPointValue];
            CGPathAddLineToPoint(path, nil, p.x, p.y);
        }
    }
    
    return path;
}

@end
