//
//  SSMyScene.m
//  SmartSoles
//
//  Created by Anupam Jindal on 3/29/14.
//  Copyright (c) 2014 Anupam Jindal. All rights reserved.
//

#import "SSMyScene.h"
#import "SSGameOverScene.h"
#import <math.h>

@interface SSMyScene () <SKPhysicsContactDelegate>
@property (nonatomic) SKSpriteNode * player;
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) SKSpriteNode *calorieCounter;
@property (nonatomic) float totalCaloriesBurnt;
@property (nonatomic) NSMutableArray *lastActionArray;
@property (nonatomic) int hurdles;
@end


@implementation SSMyScene

static const uint32_t playerCategory         =  0x1 << 0;
static const uint32_t monsterCategory        =  0x1 << 1;
@synthesize latestSoleData = _latestSoleData;

-(void)setLatestSoleData:(NSMutableDictionary *)latestSoleData {
    _latestSoleData = latestSoleData;
    [self updatePlayerPosition];
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        self.totalCaloriesBurnt = 0;
        self.lastActionArray = [[NSMutableArray alloc] init];
        NSLog(@"Size: %@", NSStringFromCGSize(size));
        
        // Background
        SKSpriteNode *sn = [SKSpriteNode spriteNodeWithImageNamed:@"BGgame"];
        sn.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        sn.name = @"BACKGROUND";
        sn.zPosition = -1;
        [self addChild:sn];
        
        // Player
        self.player = [SKSpriteNode spriteNodeWithImageNamed:@"ninja"];
        self.player.position = CGPointMake(self.player.size.width/2, self.frame.size.height/2);
        self.player.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.player.size];
        self.player.physicsBody.dynamic = YES;
        self.player.physicsBody.categoryBitMask = playerCategory;
        self.player.physicsBody.contactTestBitMask = monsterCategory;
        self.player.physicsBody.collisionBitMask = 0;
        self.player.physicsBody.usesPreciseCollisionDetection = YES;
        self.player.zPosition = 1;
        [self addChild:self.player];
        
        // Line
        SKShapeNode *yourline = [SKShapeNode node];
        CGMutablePathRef pathToDraw = CGPathCreateMutable();
        CGPathMoveToPoint(pathToDraw, NULL, 0, self.frame.size.height/2 -40);
        CGPathAddLineToPoint(pathToDraw, NULL, 568.0, self.frame.size.height/2 -40);
        yourline.path = pathToDraw;
        [yourline setStrokeColor:[UIColor grayColor]];
        yourline.zPosition = 0;
        [self addChild:yourline];
        
        self.physicsWorld.gravity = CGVectorMake(0,0);
        self.physicsWorld.contactDelegate = self;
    }
    return self;
}

-(void)addGrass {
    // Create sprite
    SKSpriteNode * grass = [SKSpriteNode spriteNodeWithImageNamed:@"grass"];
    int actualY = self.frame.size.height/2;
    
    // Create the monster slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    grass.position = CGPointMake(self.frame.size.width + grass.size.width/2, actualY);
    
    // Collision detection
    /*monster.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:monster.size];
    monster.physicsBody.dynamic = YES;
    monster.physicsBody.categoryBitMask = monsterCategory;
    monster.physicsBody.contactTestBitMask = playerCategory;
    monster.physicsBody.collisionBitMask = 0;*/
    
    
    [self addChild:grass];
    
    // Determine speed of the monster
    int minDuration = 6.0;
    int maxDuration = 10.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    // Create the actions
    SKAction * actionMove = [SKAction moveTo:CGPointMake(-grass.size.width/2, actualY) duration:actualDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    
    [grass runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
}

- (void)addMonster {
    
    // Create sprite
    SKSpriteNode * monster = [SKSpriteNode spriteNodeWithImageNamed:@"hurdles"];
    int actualY = self.frame.size.height/2;
    
    // Create the monster slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    monster.position = CGPointMake(self.frame.size.width + monster.size.width/2, actualY);

    // Collision detection
    monster.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:monster.size];
    monster.physicsBody.dynamic = YES;
    monster.physicsBody.categoryBitMask = monsterCategory;
    monster.physicsBody.contactTestBitMask = playerCategory;
    monster.physicsBody.collisionBitMask = 0;

    
    [self addChild:monster];
    
    // Determine speed of the monster
    int minDuration = 2.0;
    int maxDuration = 4.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    // Create the actions
    SKAction * actionMove = [SKAction moveTo:CGPointMake(-monster.size.width/2, actualY) duration:actualDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];/*[SKAction runBlock:^{
        [SKAction removeFromParent];
        _hurdles++;
    }];*/
    SKAction *winAction = [SKAction runBlock:^{
        if([self hurdles] > 30) {
            SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
            SKScene *gameOverScene = [[SSGameOverScene alloc] initWithSize:self.size
                                                                     won:TRUE];
            [self.view presentScene:gameOverScene transition:reveal];
        }
    }];

    
    [monster runAction:[SKAction sequence:@[actionMove, winAction, actionMoveDone]]];
    
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

- (void)projectile:(SKSpriteNode *)player didCollideWithMonster:(SKSpriteNode *)monster {
    NSLog(@"Did not hurdle");
    /*SKAction *loseAction = [SKAction runBlock:^{
            SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
            SKScene *gameOverScene = [[SSGameOverScene alloc] initWithSize:self.size
                                                                       won:NO];
            [self.view presentScene:gameOverScene transition:reveal];
    }];
    
    
    [player runAction:loseAction];*/
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    } else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if ((firstBody.categoryBitMask & playerCategory) != 0 &&
        (secondBody.categoryBitMask & monsterCategory) != 0) {
        [self projectile:(SKSpriteNode *) firstBody.node didCollideWithMonster:(SKSpriteNode *) secondBody.node];
    }
}



-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    SKAction *followTrack = [SKAction followPath:[self createJumpPath] asOffset:NO orientToPath:NO duration:1.0];
    //SKAction *followTrack = [SKAction followPath:[self createJumpPath] asOffset:NO orientToPath:NO duration:0.5];
    [self.player runAction:followTrack];
}

-(CGMutablePathRef) createJumpPath {
    int arcCenterX = self.player.frame.origin.x;
    CGPoint initialPoint = CGPointMake(arcCenterX+self.player.frame.size.width/2, self.player.frame.origin.y+self.player.frame.size.height/2);
    CGPoint firstPoint = CGPointMake(arcCenterX+self.player.frame.size.width/2, self.player.frame.origin.y + 150);
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

-(CGMutablePathRef) createFallPath {
    int arcCenterX = self.player.frame.origin.x;
    CGPoint initialPoint = CGPointMake(arcCenterX+self.player.frame.size.width/2, self.player.frame.origin.y+self.player.frame.size.height/2);
    CGPoint firstPoint = CGPointMake(arcCenterX+self.player.frame.size.width/2, self.player.frame.origin.y );
    //CGPoint secondPoint = CGPointMake(arcCenterX+self.player.frame.size.width/2, self.frame.size.height/2);
    
    NSMutableArray *jumpPoints = [NSMutableArray arrayWithObjects:[NSValue valueWithCGPoint:initialPoint], [NSValue valueWithCGPoint:firstPoint], nil];
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

-(void)updatePlayerPosition {
    NSNumber *resistance = _latestSoleData[@"resistance"];
    //NSNumber *timeInMilis = _latestSoleData[@"timeInMilis"];
    
    if(1023-[resistance intValue]<10) {
        NSLog(@"I am pressed %d ", [resistance intValue]);
        [self.lastActionArray addObject:[NSNumber numberWithInt:0]];
    }
    else {
         NSLog(@"I am in air %d ", [resistance intValue]);
        [self.lastActionArray addObject:[NSNumber numberWithInt:1]];
        
    }
    if(self.lastActionArray && [self.lastActionArray count]>2) {
        int previousAction = [[self.lastActionArray objectAtIndex:[self.lastActionArray count]-1] intValue];
        int secondLastAction = [[self.lastActionArray objectAtIndex:[self.lastActionArray count]-2] intValue];
        
        if(previousAction == 1 && secondLastAction == 1) {
            NSLog(@"I am Jumping");
            SKAction *followTrack = [SKAction followPath:[self createJumpPath] asOffset:NO orientToPath:NO duration:1.0];
            [self.player runAction:followTrack];
            self.totalCaloriesBurnt =+.15;
        }
        else if(previousAction == 0 && secondLastAction == 0) {
            NSLog(@"I am standing");
            self.player.position = CGPointMake(self.player.size.width/2, self.frame.size.height/2);
        }
        else {
            NSLog(@"I am running/walking");
            self.totalCaloriesBurnt =+.05;
        }
        
    }
}

@end
