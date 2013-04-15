//
//  HostMultiplayerViewController.h
//  JetsetSumo
//
//  Created by oliver on 11/16/12.
//  Copyright (c) 2012 Jetset Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Multiplayer.h"

@protocol HostMultiplayerViewControllerDelegate;

@interface HostMultiplayerViewController : UIViewController <HostMultiplayerDelegate, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) Multiplayer *multiplayerManager;
@property (nonatomic, strong) NSMutableArray *connectedUsersArray;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, weak) id<HostMultiplayerViewControllerDelegate> hostMultiplayerViewControllerDelegate;
@property (nonatomic, strong) UIButton *startBtn;

-(void)moveBackToMainScreen;
-(void)startGame;
@end

@protocol HostMultiplayerViewControllerDelegate <NSObject>
-(void)jumpBackToMainScreen;
-(void)jumpToMultiplayerGameView:(Multiplayer *)networkInterface;
@end

