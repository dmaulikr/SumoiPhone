//
//  Gameplay.m
//  JetsetSumo
//
//  Created by oliver on 11/16/12.
//  Copyright (c) 2012 Jetset Inc. All rights reserved.
//

#import "Gameplay.h"

@implementation Gameplay

@synthesize gameIsRunning = _gameIsRunning;

-(void)startGame
{
    _gameIsRunning = YES;
}

-(void)pauseGame
{
    _gameIsRunning = NO;
}

-(void)resetGame
{
    
}


@end
