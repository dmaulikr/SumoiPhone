//
//  Multiplayer.h
//  JetsetSumo
//
//  Created by oliver on 11/16/12.
//  Copyright (c) 2012 Jetset Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JoinMultiplayerDelegate;
@protocol HostMultiplayerDelegate;
@protocol GameplayDelegate;
@class JoinMultiplayerViewController;
@class HostMultiplayerViewController;
@class GameplayViewController;

@interface Multiplayer : NSObject <GKSessionDelegate>
@property (nonatomic, strong) GKSession *session;
@property (nonatomic) BOOL isServer;
@property (nonatomic) BOOL isMultiplayer;
@property (nonatomic, strong) NSMutableArray *availableServers;
@property (nonatomic, strong) NSMutableArray *connectedClients;
@property (nonatomic, weak) id<JoinMultiplayerDelegate> joinMultiplayerDelegate;
@property (nonatomic, weak) id<HostMultiplayerDelegate> hostMultiplayerDelegate;
@property (nonatomic, weak) id<GameplayDelegate> gameplayDelegate;

-(void)startSearchingForServersWithClass:(JoinMultiplayerViewController *)controller;
-(void)connectToServerWithPeerID:(NSString *)peerID;
-(void)startHostingServerWithClass:(HostMultiplayerViewController *)controller;
-(NSString *)getServerFromIndexPath:(int)index;
-(int)getAvailableServerCount;
-(NSMutableArray *)getAllServerArray;
-(NSString *)getClientFromIndexPath:(int)index;
-(int)getAvailableClientCount;
-(NSMutableArray *)getAllClientArray;
-(void)disconnectFromServer;
-(void)showNetworkErrorAlertView;
-(void)setUpGameplayViewControllerDelegate:(GameplayViewController *)controller;
-(void)sendStringToAllPeers:(NSString *)string;
@end

@protocol JoinMultiplayerDelegate <NSObject>
-(void)refreshTableContent;
-(void)startGameFromServer;
@end

@protocol HostMultiplayerDelegate <NSObject>
-(void)refreshTableContent;
@end

@protocol GameplayDelegate <NSObject>
-(void)updateOpponentPositionWithFrameX:(CGFloat)x andY:(CGFloat)y;
-(void)updateOpponentPositionWhenCollisionWithX:(CGFloat)x andY:(CGFloat)y;
-(void)updateSelfPositionWhenCollisionWithX:(CGFloat)x andY:(CGFloat)y;
-(void)serverScoredAPoint;
-(void)clientScoredAPoint;
@end
