//
//  JoinMultiplayerViewController.h
//  JetsetSumo
//
//  Created by oliver on 11/16/12.
//  Copyright (c) 2012 Jetset Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Multiplayer.h"

@protocol JoinMultiplayerViewControllerDelegate;

@interface JoinMultiplayerViewController : UIViewController <JoinMultiplayerDelegate, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) Multiplayer *multiplayerManager;
@property (nonatomic, strong) NSMutableArray *availableServerArray;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, weak) id<JoinMultiplayerViewControllerDelegate> joinMultiplayerViewControllerDelegate;

-(void)moveBackToMainScreen;
@end

@protocol JoinMultiplayerViewControllerDelegate <NSObject>
-(void)jumpBackToMainScreen;
-(void)jumpToMultiplayerGameView:(Multiplayer *)networkInterface;
@end
