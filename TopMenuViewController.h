//
//  TopMenuViewController.h
//  JetsetSumo
//
//  Created by oliver on 11/16/12.
//  Copyright (c) 2012 Jetset Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HostMultiplayerViewController.h"
#import "JoinMultiplayerViewController.h"


@protocol TopMenuViewControllerDelegate;

@interface TopMenuViewController : UIViewController <HostMultiplayerViewControllerDelegate,JoinMultiplayerViewControllerDelegate>

@property (nonatomic, strong) UIButton *hostGameBtn;
@property (nonatomic, strong) UIButton *joinGameBtn;
@property (nonatomic, strong) UIButton *singleGameBtn;
@property (nonatomic, weak) id<TopMenuViewControllerDelegate> TopMenuViewControllerDelegate;

@property (nonatomic, strong) Multiplayer *multiplayerInterface;

-(void)jumpToHostGameView;
-(void)jumpToJoinGameView;
-(void)jumpToSingleGameView;
@end

@protocol TopMenuViewControllerDelegate <NSObject>
- (void)startGameWithMultiplayer:(Multiplayer *)networkInterface;
@end
