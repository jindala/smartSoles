//
//  SSMyScene.m
//  SmartSoles
//
//  Created by Anupam Jindal on 3/29/14.
//  Copyright (c) 2014 Anupam Jindal. All rights reserved.
//

#import "SSMyScene.h"
#import "SSGameOverScene.h"
#import "SSScoreLabel.h"
#import <math.h>
#import <AVFoundation/AVFoundation.h>

@interface SSMyScene () <SKPhysicsContactDelegate>
@property (nonatomic) SKSpriteNode * player;
@property (nonatomic) SKSpriteNode * box;
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) NSTimeInterval lastSpawnGrassTimeInterval;
@property (nonatomic) SKSpriteNode *calorieCounter;
@property (nonatomic) float totalCaloriesBurnt;
@property (nonatomic) NSMutableArray *lastActionArray;
@property (nonatomic) int hurdles;
@property (nonatomic) SSScoreLabel *scoreLabel;
@end


@implementation SSMyScene
{
    
    SKSpriteNode *_ninja;
    NSArray *_ninjaWalkingFrames;
    NSArray *_ninjaJumpUpFrames;
    NSArray *_ninjaJumpDownFrames;
    
}

static const uint32_t playerCategory         =  0x1 << 0;
static const uint32_t monsterCategory        =  0x1 << 2;
static const uint32_t boxCategory            =  0x1 << 1;
@synthesize latestSoleData = _latestSoleData;

-(void)setLatestSoleData:(NSMutableDictionary *)latestSoleData {
    _latestSoleData = latestSoleData;
    [self updatePlayerPosition];
}

-(void)setupHUD {
    // position the scoreLabel in the frame
    _scoreLabel = [[SSScoreLabel alloc] initScoreLabel];
    _scoreLabel.position = CGPointMake(self.frame.size.width/2 - _scoreLabel.frame.size.width/2,
                                      self.frame.size.height - _scoreLabel.frame.size.height - 55);
    _scoreLabel.name = @"scoreLabel";
    
    [self addChild:_scoreLabel];
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
        
        // need to move this to another method that listens for input from the soles... TODO
        [self setUpWalkingNinjaSprite];
        
        /*
        // Player
        self.player = [SKSpriteNode spriteNodeWithImageNamed:@"ninja"];
        self.player.position = CGPointMake(self.player.size.width/2, self.frame.size.height/3);
        self.player.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.player.size];
        self.player.physicsBody.dynamic = YES;
        self.player.physicsBody.categoryBitMask = playerCategory;
        self.player.physicsBody.contactTestBitMask = monsterCategory;
        self.player.physicsBody.collisionBitMask = 0;
        self.player.physicsBody.usesPreciseCollisionDetection = YES;
        self.player.zPosition = .5;
        [self addChild:self.player];
        */
         
        // Sprite for invisible box to detect when monster is approaching.
        self.box = [SKSpriteNode spriteNodeWithImageNamed:@"invisible"];
        self.box.position = CGPointMake(self.box.size.width/2 + 150, self.frame.size.height/3);
        self.box.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.box.size];
        self.box.physicsBody.dynamic = YES;
        self.box.physicsBody.categoryBitMask = boxCategory;
        self.box.physicsBody.contactTestBitMask = monsterCategory;
        self.box.physicsBody.collisionBitMask = 0;
        self.box.physicsBody.usesPreciseCollisionDetection = YES;
        self.box.zPosition = 1;
        [self addChild:self.box];
        
        // Line
        SKShapeNode *yourline = [SKShapeNode node];
        CGMutablePathRef pathToDraw = CGPathCreateMutable();
        CGPathMoveToPoint(pathToDraw, NULL, 0, self.frame.size.height/3 -38);
        CGPathAddLineToPoint(pathToDraw, NULL, 568.0, self.frame.size.height/3 -38);
        yourline.path = pathToDraw;
        [yourline setStrokeColor:[UIColor grayColor]];
        yourline.zPosition = 0;
        [self addChild:yourline];
        
        self.physicsWorld.gravity = CGVectorMake(0,0);
        self.physicsWorld.contactDelegate = self;
        
        // Computer-generated voice to say "Run."
        
        AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc] init];
        AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:@"Run"];
        [utterance setRate:0.25f];
        utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-GB"];
        utterance.preUtteranceDelay = 0.1;
        [synthesizer speakUtterance:utterance];
        

    }
    return self;
}

-(void)setUpWalkingNinjaSprite
{
    // Ninja walk animation
    NSMutableArray *walkFrames = [NSMutableArray array];
    SKTextureAtlas *ninjaAnimatedAtlas = [SKTextureAtlas atlasNamed:@"NinjaImages"];
    
    int numImages = ninjaAnimatedAtlas.textureNames.count;
    for (int i = 1; i <= numImages; i++) {
        NSString *textureName = [NSString stringWithFormat:@"ninja%d", i];
        SKTexture *temp = [ninjaAnimatedAtlas textureNamed:textureName];
        [walkFrames addObject:temp];
    }
    _ninjaWalkingFrames = walkFrames;
    
    
    SKTexture *temp = _ninjaWalkingFrames[0];
    _ninja = [SKSpriteNode spriteNodeWithTexture:temp];
    _ninja.position = CGPointMake(self.player.size.width + 30, self.frame.size.height/3);
    [self addChild:_ninja];
    [self walkingNinja];
}

-(void)setUpJumpingNinjaSprite
{
    // Ninja jump animation
    NSMutableArray *jumpUpFrames = [NSMutableArray array];
    NSMutableArray *jumpDownFrames = [NSMutableArray array];
    SKTextureAtlas *ninjaJumpAnimatedAtlas = [SKTextureAtlas atlasNamed:@"NinjaJumpImages"];
    
    /*
    int numImages = ninjaJumpAnimatedAtlas.textureNames.count;
    for (int i = 1; i <= numImages; i++) {
        NSString *textureName = [NSString stringWithFormat:@"ninjaJump%d", i];
        SKTexture *temp = [ninjaJumpAnimatedAtlas textureNamed:textureName];
        [jumpFrames addObject:temp];
    }
     */

    [jumpUpFrames addObject:[ninjaJumpAnimatedAtlas textureNamed:
                             [NSString stringWithFormat:@"ninjaJump1"]]];
    [jumpUpFrames addObject:[ninjaJumpAnimatedAtlas textureNamed:
                             [NSString stringWithFormat:@"ninjaJump2"]]];
    [jumpDownFrames addObject:[ninjaJumpAnimatedAtlas textureNamed:
                            [NSString stringWithFormat:@"ninjaJump3"]]];
    [jumpDownFrames addObject:[ninjaJumpAnimatedAtlas textureNamed:
                             [NSString stringWithFormat:@"ninjaJump1"]]];
    
    _ninjaJumpUpFrames = jumpUpFrames;
    _ninjaJumpDownFrames = jumpDownFrames;
    
    
    SKTexture *temp = _ninjaJumpUpFrames[0];
    // do we need to use different node for jumping ninja? TODO
    _ninja = [SKSpriteNode spriteNodeWithTexture:temp];
    _ninja.position = CGPointMake(self.player.size.width + 30, self.frame.size.height/3);
    [self addChild:_ninja];
    [self jumpingNinja];
    
}

-(void)walkingNinja
{
    // make ninja walk
    [_ninja runAction:[SKAction repeatActionForever:
                      [SKAction animateWithTextures:_ninjaWalkingFrames
                                       timePerFrame:0.1f
                                             resize:NO
                                            restore:YES]] withKey:@"walkingInPlaceNinja"];
    return;
}

-(void)jumpingNinja
{
    
    SKAction *prepJump = [SKAction moveByX:0 y:30.0 duration:0.3];
    SKAction *animateJumpUp = [SKAction animateWithTextures:_ninjaJumpUpFrames
                                        timePerFrame:1.4/3
                                              resize:NO
                                              restore:YES];
    SKAction *animateJumpDown = [SKAction animateWithTextures:_ninjaJumpDownFrames
                                               timePerFrame:1.4/3
                                                     resize:NO
                                                    restore:YES];
    
    SKAction *moveUp = [SKAction moveByX:0 y:70.0 duration:0.7];
    SKAction *moveDown = [SKAction moveByX:0 y:-70.0 duration:0.7];
    SKAction *landing = [SKAction moveByX:0 y:-30.0 duration:0.3];
    SKAction *removeNode = [SKAction removeFromParent];
    
    SKAction *groupJumpUp = [SKAction group:@[prepJump, animateJumpUp, moveUp]];
    SKAction *groupJumpDown = [SKAction group:@[moveDown, animateJumpDown, landing]];
    SKAction *sequence = [SKAction sequence:@[groupJumpUp, groupJumpDown, removeNode]];
    // make ninja jump
    [_ninja runAction: sequence withKey:@"jumpingNinja"];
    
    return;
}

-(void)addGrass {
    // Create sprite
    SKSpriteNode * grass = [SKSpriteNode spriteNodeWithImageNamed:@"grass"];
    int actualY = grass.size.height/2;
    
    // Create the monster slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    grass.position = CGPointMake(self.frame.size.width + grass.size.width/2, actualY);
    grass.zPosition = 1;
    [self addChild:grass];
    
    // Determine speed of the monster
    //int minDuration = 6.0;
    //int maxDuration = 8.0;
    //int rangeDuration = maxDuration - minDuration;
    //int actualDuration = (arc4random() % rangeDuration) + minDuration;
    int actualDuration = 7.0;
    
    // Create the actions
    SKAction * actionMove = [SKAction moveTo:CGPointMake(-grass.size.width/2, actualY) duration:actualDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    
    [grass runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
}

- (void)addMonster {
    
    // Create sprite
    SKSpriteNode * monster = [SKSpriteNode spriteNodeWithImageNamed:@"hurdles"];
    int actualY = self.frame.size.height/3;
    
    // Create the monster slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    monster.position = CGPointMake(self.frame.size.width + monster.size.width/2, actualY);

    // Collision detection
    monster.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:monster.size];
    monster.physicsBody.dynamic = YES;
    monster.physicsBody.categoryBitMask = monsterCategory;
    monster.physicsBody.contactTestBitMask = playerCategory | boxCategory;
    monster.physicsBody.collisionBitMask = 0;

    
    
    
    [self addChild:monster];
    
    // Determine speed of the monster
    int minDuration = 6.0;
    int maxDuration = 8.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    // Create the actions
    SKAction * actionMove = [SKAction moveTo:CGPointMake(-monster.size.width/2, actualY) duration:actualDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    
    /*SKAction *winAction = [SKAction runBlock:^{
        if([self hurdles] > 30) {
            SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
            SKScene *gameOverScene = [[SSGameOverScene alloc] initWithSize:self.size
                                                                     won:TRUE];
            [self.view presentScene:gameOverScene transition:reveal];
        }
    }];*/
    

    
    [monster runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
    
}

- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    
    self.lastSpawnTimeInterval += timeSinceLast;
    if (self.lastSpawnTimeInterval > 7) {
        self.lastSpawnTimeInterval = 0;
        [self addMonster];
    }
    
    self.lastSpawnGrassTimeInterval +=timeSinceLast;
    if(self.lastSpawnGrassTimeInterval>4) {
        self.lastSpawnGrassTimeInterval = 0;
        [self addGrass];
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
    
    // Computer-generated voice to say "Ouch."
    AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc] init];
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:@"Ouch"];
    [utterance setRate:0.25f];
    [utterance setPitchMultiplier:0.75f];
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"];
    //utterance.preUtteranceDelay = 0.1;
    [synthesizer speakUtterance:utterance];
    
    [player runAction:loseAction];*/
}

- (void)projectile:(SKSpriteNode *)box didBoxCollideWithMonster:(SKSpriteNode *)monster {
    NSLog(@"Box colliding with Monster");
    
    // Computer-generated voice to say "Jump."
    AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc] init];
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:@"Jump"];
    [utterance setRate:0.25f];
    [utterance setPitchMultiplier:1.25f];
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-GB"];
    //utterance.preUtteranceDelay = 0.1;
    [synthesizer speakUtterance:utterance];
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
        (secondBody.categoryBitMask & boxCategory) != 0) {
        //ignore
    }
    
    if ((firstBody.categoryBitMask & playerCategory) != 0 &&
        (secondBody.categoryBitMask & monsterCategory) != 0) {
        [self projectile:(SKSpriteNode *) firstBody.node didCollideWithMonster:(SKSpriteNode *) secondBody.node];
    }
    
    if ((firstBody.categoryBitMask & boxCategory) != 0 &&
        (secondBody.categoryBitMask & monsterCategory) != 0) {
        [self projectile:(SKSpriteNode *) firstBody.node didBoxCollideWithMonster:(SKSpriteNode *) secondBody.node];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    //SKAction *followTrack = [SKAction followPath:[self createJumpPath] asOffset:NO orientToPath:NO duration:1.0];
    
    [self setUpJumpingNinjaSprite];
    //[self setUpWalkingNinjaSprite];
    
    /*
    CGMutablePathRef fallPath = [self createFallPath];
    
    SKAction *followTrack = [SKAction followPath:fallPath asOffset:NO orientToPath:YES duration:0.5];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2.0);
    CGContextSetFillColorWithColor(context, [[UIColor redColor] CGColor]);
    CGContextSetStrokeColorWithColor(context, [[UIColor blueColor] CGColor]);
    
    // Draw the points
    CGContextAddPath(context, fallPath);
    CGContextStrokePath(context);
     */
    
    //[self.player runAction:followTrack withKey:@"jumping"];
    // JUMP SOUND
    [self runAction:[SKAction playSoundFileNamed:@"woosh2.caf" waitForCompletion:NO]];
    
    [_scoreLabel addScore:0.15];
}

-(CGMutablePathRef) createJumpPath {
    
    int arcCenterX = self.player.frame.origin.x;
    CGPoint initialPoint = CGPointMake(arcCenterX+self.player.frame.size.width/2, self.player.frame.origin.y+self.player.frame.size.height/2);
    CGPoint firstPoint = CGPointMake(arcCenterX+self.player.frame.size.width/2, self.player.frame.origin.y + 150);
    CGPoint secondPoint = CGPointMake(arcCenterX+self.player.frame.size.width/2, self.frame.size.height/3);
    
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
    CGFloat playerCenterX = self.player.frame.origin.x + self.player.frame.size.width / 2;
    CGFloat playerCenterY = self.player.frame.origin.y + self.player.frame.size.height / 2;
    
    CGPoint initialPoint = CGPointMake(playerCenterX, playerCenterY + 20);
    CGPoint firstPoint = CGPointMake(playerCenterX + 20, playerCenterY);
    
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


-(void)didMoveToView:(SKView *)view {
    [self setupHUD];
}

-(void)updatePlayerPosition {
    NSNumber *resistance = _latestSoleData[@"resistance"];
    //NSNumber *timeInMilis = _latestSoleData[@"timeInMilis"];
    
    if(1023-[resistance intValue]<10) {
        NSLog(@"I am pressed %d ", [resistance intValue]);
        [self.lastActionArray addObject:[NSNumber numberWithInt:1]];
    }
    else {
         NSLog(@"I am in air %d ", [resistance intValue]);
        [self.lastActionArray addObject:[NSNumber numberWithInt:0]];
        
    }
    if(self.lastActionArray && [self.lastActionArray count]>2) {
        int previousAction = [[self.lastActionArray objectAtIndex:[self.lastActionArray count]-1] intValue];
        int secondLastAction = [[self.lastActionArray objectAtIndex:[self.lastActionArray count]-2] intValue];
        
        if(previousAction == 1 && secondLastAction == 1) {
            NSLog(@"I am Jumping");
            SKAction *followTrack = [SKAction followPath:[self createJumpPath] asOffset:NO orientToPath:NO duration:4.0];
            [self.player runAction:followTrack];
            self.totalCaloriesBurnt =+.15;
            [_scoreLabel addScore:0.15];
        }
        else if(previousAction == 0 && secondLastAction == 0) {
            NSLog(@"I am standing");
            self.player.position = CGPointMake(self.player.size.width/2, self.frame.size.height/3);
        }
        else {
            NSLog(@"I am running/walking");
            self.totalCaloriesBurnt =+.05;
            [_scoreLabel addScore:0.05];
        }
        
    }
}

@end
