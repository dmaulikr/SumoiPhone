//
//  GameplayViewController.h
//  JetsetSumo
//
//  Created by oliver on 11/16/12.
//  Copyright (c) 2012 Jetset Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Player.h"
#import "Gameplay.h"
#import "Multiplayer.h"
#import "TopMenuViewController.h"

@protocol GameplayViewControllerDelegate;

@interface GameplayViewController : UIViewController <GameplayDelegate,TopMenuViewControllerDelegate>
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) Player *thisPlayer;
@property (nonatomic, strong) Player *opponentPlayer;
@property (nonatomic, strong) UIImageView *thisPlayerInView;
@property (nonatomic, strong) UIImageView *opponentPlayerInView;
@property (nonatomic, strong) Gameplay *gameStatus;
@property (nonatomic, strong) Multiplayer *networkInterface;
@property (nonatomic, weak) id<GameplayViewControllerDelegate> gameplayViewControllerDelegate;
@property (nonatomic) int countDownNumber;

- (void)resetAndStartGame;
- (void)setInitValuesForPlayer:(Player *)player withFrame:(CGRect)refFrame andRotationAngle:(CGFloat)rotationAngle;
- (void)animatePlayerToLocation:(Player *)player inView:(UIImageView *)playerInView;
- (void)startRoundCountdownAnimation;
- (void)startEndRoundAnimation;
-(void)moveSinglePlayer;
@end

@protocol GameplayViewControllerDelegate <NSObject>
-(void)jumpBackToMainScreen;
-(void)jumpToMultiplayerGameView:(Multiplayer *)networkInterface;
@end
