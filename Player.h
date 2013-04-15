//
//  Player.h
//  JetsetSumo
//
//  Created by oliver on 11/16/12.
//  Copyright (c) 2012 Jetset Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Player : NSObject

@property (nonatomic) int playerScore;
@property (nonatomic) CGFloat oldPosX;
@property (nonatomic) CGFloat oldPosY;
@property (nonatomic) CGFloat newPosX;
@property (nonatomic) CGFloat newPosY;
@property (nonatomic) CGFloat pitchAccel;
@property (nonatomic) CGFloat rollAccel;
@property (nonatomic) CGFloat oldRotationAngle;
@property (nonatomic) CGFloat newRotationAngle;
@property (nonatomic) CGFloat currentRadius;
@property (nonatomic) CGFloat totalMomentum;

-(UIImageView *)createPlayerAsServer:(BOOL)playerIsServer;
-(CGRect)getStartPositionForPlayerAsServer:(BOOL)playerIsServer;
-(CGRect)updatePlayerWithPitchAcceleration:(CGFloat)pitchAccel withRollAcceleration:(CGFloat)rollAccel;
-(void)calculateAngleOfMovement;
-(void)calculateCurrentRadius;
-(BOOL)checkIfPlayerIsOutsideRing;
-(BOOL)checkForCollisionBetweenClient:(UIImageView *)clientPlayer andServer:(UIImageView *)serverPlayer;
-(CGRect)correctPlayerPositionInCaseOfCollision:(UIImageView *)thisPlayerInView thisPlayer:(Player *)thisPlayer opponentPlayer:(Player *)opponentPlayer;
@end
