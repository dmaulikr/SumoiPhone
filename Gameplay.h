//
//  Gameplay.h
//  JetsetSumo
//
//  Created by oliver on 11/16/12.
//  Copyright (c) 2012 Jetset Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Gameplay : NSObject 

@property (nonatomic) BOOL gameIsRunning;

-(void)startGame;
-(void)pauseGame;
-(void)resetGame;

@end
