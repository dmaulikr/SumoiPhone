//
//  Player.m
//  JetsetSumo
//
//  Created by oliver on 11/16/12.
//  Copyright (c) 2012 Jetset Inc. All rights reserved.
//

#import "Player.h"

@implementation Player

@synthesize playerScore = _playerScore;
@synthesize oldPosX = _oldPosX;
@synthesize oldPosY = _oldPosY;
@synthesize newPosX = _newPosX;
@synthesize newPosY = _newPosY;
@synthesize pitchAccel = _pitchAccel;
@synthesize rollAccel = _rollAccel;
@synthesize oldRotationAngle = _oldRotationAngle;
@synthesize newRotationAngle = _newRotationAngle;
@synthesize currentRadius = _currentRadius;
@synthesize totalMomentum = _totalMomentum;

#define kMovePlayerWithPixelAmount 25
#define kServerPlayerX (kHalfDeviceScreenWidth-70)
#define kServerPlayerY kHalfDeviceScreenHeight
#define kClientPlayerX (kHalfDeviceScreenWidth+70)
#define kClientPlayerY kHalfDeviceScreenHeight
#define kPlayerSizeWidth 60
#define kPlayerSizeHeight 75
#define kRingRadius 160

-(UIImageView *)createPlayerAsServer:(BOOL)playerIsServer
{
    UIImageView *player = [[UIImageView alloc] init];
    if(playerIsServer)
    {
        player.image = [UIImage imageNamed:@"sumo1.png"];
        player.frame = CGRectMake(kServerPlayerX,kServerPlayerY,kPlayerSizeWidth,kPlayerSizeHeight);
        _oldPosX = kServerPlayerX;
        _oldPosY = kServerPlayerY;
        _newPosX = kServerPlayerX;
        _newPosY = kServerPlayerY;
    }
    else if(!playerIsServer)
    {
        player.image = [UIImage imageNamed:@"sumo1.png"];
        player.frame = CGRectMake(kClientPlayerX,kClientPlayerY,kPlayerSizeWidth,kPlayerSizeHeight);
        _oldPosX = kClientPlayerX;
        _oldPosY = kClientPlayerY;
        _newPosX = kClientPlayerX;
        _newPosY = kClientPlayerY;
    }
    return player;
}

-(CGRect)getStartPositionForPlayerAsServer:(BOOL)playerIsServer
{
    CGRect newframe;
    if(playerIsServer)
    {
        newframe = CGRectMake(kServerPlayerX,kServerPlayerY,kPlayerSizeWidth,kPlayerSizeHeight);
    }
    else if(!playerIsServer)
    {
        newframe = CGRectMake(kClientPlayerX,kClientPlayerY,kPlayerSizeWidth,kPlayerSizeHeight);
    }
    return newframe;
}


-(CGRect)updatePlayerWithPitchAcceleration:(CGFloat)pitchAccel withRollAcceleration:(CGFloat)rollAccel
{
    //Store new values
    _pitchAccel = pitchAccel;
    _rollAccel = -rollAccel;
    
    //Calculate Acceleration
    _newPosX = _oldPosX + (kMovePlayerWithPixelAmount * _pitchAccel);
    _newPosY = _oldPosY + (kMovePlayerWithPixelAmount * _rollAccel);
    
    //Store new value into old
    //_oldPosX = _newPosX;
    //_oldPosY = _newPosY;
    
    //Update momentum
    _totalMomentum = (_newPosX - _oldPosX) + (_newPosY - _oldPosY);
    
    //Create frame
    CGRect frame = CGRectMake(_newPosX,_newPosY,kPlayerSizeWidth,kPlayerSizeHeight);
    return frame;
}

-(void)calculateAngleOfMovement
{
    _newRotationAngle = atan2f(_newPosY-_oldPosY,_newPosX-_oldPosX);
    
    if(!_oldRotationAngle)
    {
        _oldRotationAngle = _newRotationAngle;
    }
    
    if(_oldRotationAngle>2.5 && _newRotationAngle<-2.5)
    {
        _oldRotationAngle = -3.0;
    }
    if(_newRotationAngle>2.5 && _oldRotationAngle<-2.5)
    {
        _oldRotationAngle = 3.0;
    }
}

-(void)calculateCurrentRadius
{
    _currentRadius = sqrtf( powf( (0.0-(_newPosX-kHalfDeviceScreenWidth)),2 ) + powf( (0.0-(_newPosY-kHalfDeviceScreenHeight)),2 ) );
}

-(BOOL)checkIfPlayerIsOutsideRing
{
    if(_currentRadius > kRingRadius)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

-(BOOL)checkForCollisionBetweenClient:(UIImageView *)clientPlayer andServer:(UIImageView *)serverPlayer
{
    CALayer *clientPlayerLayer = clientPlayer.layer.presentationLayer;
    CALayer *serverPlayerLayer = serverPlayer.layer.presentationLayer;
    
    if(CGRectIntersectsRect(clientPlayerLayer.frame, serverPlayerLayer.frame))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

-(CGRect)correctPlayerPositionInCaseOfCollision:(UIImageView *)thisPlayerInView thisPlayer:(Player *)thisPlayer opponentPlayer:(Player *)opponentPlayer
{
    CGFloat newRefX = _newPosX + (kMovePlayerWithPixelAmount * _pitchAccel);
    CGFloat newRefY = _newPosY + (kMovePlayerWithPixelAmount * _rollAccel);
    
    if(newRefX > _newPosX)
    {
        _newPosX = newRefX - ((newRefX - _newPosX) + (kPlayerSizeWidth*0.2));
        //ADD MOMENTUM VARIABLE
    }
    else if(newRefX < _newPosX)
    {
        _newPosX = newRefX + ((_newPosX - newRefX) + (kPlayerSizeWidth*0.2));
        //ADD MOMENTUM VARIABLE
    }
    if(newRefY > _newPosY)
    {
        _newPosY = newRefY - ((newRefY - _newPosY) + (kPlayerSizeHeight*0.2));
        //ADD MOMENTUM VARIABLE
    }
    else if(newRefY < _newPosY)
    {
        _newPosY = newRefY + ((_newPosY - newRefY) + (kPlayerSizeHeight*0.2));
        //ADD MOMENTUM VARIABLE
    }
    
    _oldPosX = _newPosX;
    _oldPosY = _newPosY;
    CGRect newframe = thisPlayerInView.frame;
    newframe.origin.x = _newPosX;
    newframe.origin.y = _newPosY;
    return newframe;
}

@end
