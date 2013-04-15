//
//  Multiplayer.m
//  JetsetSumo
//
//  Created by oliver on 11/16/12.
//  Copyright (c) 2012 Jetset Inc. All rights reserved.
//

#import "Multiplayer.h"
#import "JoinMultiplayerViewController.h"
#import "HostMultiplayerViewController.h"
#import "GameplayViewController.h"

@implementation Multiplayer

@synthesize session = _session;
@synthesize isServer = _isServer;
@synthesize isMultiplayer = _isMultiplayer;
@synthesize availableServers = _availableServers;
@synthesize connectedClients = _connectedClients;
@synthesize joinMultiplayerDelegate = _joinMultiplayerDelegate;
@synthesize hostMultiplayerDelegate = _hostMultiplayerDelegate;
@synthesize gameplayDelegate = _gameplayDelegate;

#define kOpponentsLimit 1

-(void)startSearchingForServersWithClass:(JoinMultiplayerViewController *)controller
{
    _availableServers = [[NSMutableArray alloc] init];
    _session = [[GKSession alloc] initWithSessionID:SESSION_ID displayName:nil sessionMode:GKSessionModeClient];
    _session.delegate = self;
    _session.available = YES;
    [_session setDataReceiveHandler:self withContext:nil];
    _isServer = NO;
    _joinMultiplayerDelegate = (id)controller;
}

-(void)connectToServerWithPeerID:(NSString *)peerID
{
    [_session connectToPeer:peerID withTimeout:_session.disconnectTimeout];
}

-(void)startHostingServerWithClass:(HostMultiplayerViewController *)controller
{
    _connectedClients = [[NSMutableArray alloc] init];
    _session = [[GKSession alloc] initWithSessionID:SESSION_ID displayName:nil sessionMode:GKSessionModeServer];
    _session.delegate = self;
    _session.available = YES;
    [_session setDataReceiveHandler:self withContext:nil];
    _isServer = YES;
    _hostMultiplayerDelegate = (id)controller;
}

-(NSString *)getServerFromIndexPath:(int)index
{
    return [_availableServers objectAtIndex:index];
}

-(int)getAvailableServerCount
{
    return [_availableServers count];
}

-(NSMutableArray *)getAllServerArray
{
    return _availableServers;
}

-(NSString *)getClientFromIndexPath:(int)index
{
    return [_connectedClients objectAtIndex:index];
}

-(int)getAvailableClientCount
{
    return [_connectedClients count];
}

-(NSMutableArray *)getAllClientArray
{
    return _connectedClients;
}

-(void)disconnectFromServer
{
    [_session disconnectFromAllPeers];
	_session.available = NO;
	_session.delegate = nil;
	_session = nil;
    if(_availableServers)
    {
        [_availableServers removeAllObjects];
    }
    if(_connectedClients)
    {
        [_connectedClients removeAllObjects];
    }
}

-(void)showNetworkErrorAlertView
{
    UIAlertView *networkErrorMessage = [[UIAlertView alloc] initWithTitle:@"Network Error"
                                                                  message:@"Please try to reconnect."
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
    [networkErrorMessage show];
}

-(void)setUpGameplayViewControllerDelegate:(GameplayViewController *)controller
{
    if(!_gameplayDelegate)
    {
        _gameplayDelegate = controller;
    }
}

-(void)sendStringToAllPeers:(NSString *)string
{
    if(_session)
    {
        NSData *data = [string dataUsingEncoding:NSASCIIStringEncoding];
        [_session sendDataToAllPeers:data withDataMode:GKSendDataReliable error:nil];
    }
}

#pragma mark - GKSession Data Receive Handler
- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context
{
    NSString* str;
    str = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSArray *locationArray = [str componentsSeparatedByString:@","];
    NSString *identifier = [locationArray objectAtIndex:0];
    float firstValue = [[locationArray objectAtIndex:1] floatValue];
    float secondValue = [[locationArray objectAtIndex:2] floatValue];
    
    //From Client to Server
    if(_isServer && [identifier isEqualToString:@"c"])
    {
        [_gameplayDelegate updateOpponentPositionWithFrameX:firstValue andY:secondValue];
    }
    //From Server to Client
    else if(!_isServer && [identifier isEqualToString:@"s"])
    {
        [_gameplayDelegate updateOpponentPositionWithFrameX:firstValue andY:secondValue];
    }
    //From Server to Client (Update Opponent in case of Collision)
    else if(!_isServer && [identifier isEqualToString:@"sc"])
    {
        [_gameplayDelegate updateOpponentPositionWhenCollisionWithX:firstValue andY:secondValue];
    }
    //From Server to Client (Update Self in case of Collision)
    else if(!_isServer && [identifier isEqualToString:@"cc"])
    {
        [_gameplayDelegate updateSelfPositionWhenCollisionWithX:firstValue andY:secondValue];
    }
    //From Server to Client, Server Scored a Point
    else if(!_isServer && [identifier isEqualToString:@"sw"])
    {
        [_gameplayDelegate serverScoredAPoint];
    }
    //From Server to Client, Client Scored a Point
    else if(!_isServer && [identifier isEqualToString:@"cw"])
    {
        [_gameplayDelegate clientScoredAPoint];
    }
    
    //From Server to Client (Start Game signal)
    else if(!_isServer && [identifier isEqualToString:@"ss"])
    {
        [_joinMultiplayerDelegate startGameFromServer];
    }
}

#pragma mark - GKSessionDelegate
- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
    switch (state)
	{
        // The client has discovered a new server.
		case GKPeerStateAvailable:
            if (![_availableServers containsObject:peerID])
            {
                [_availableServers addObject:peerID];
                if(!_isServer)
                {
                    [_joinMultiplayerDelegate refreshTableContent];
                }
                
            }
			break;
            
        // The client sees that a server goes away.
		case GKPeerStateUnavailable:
            if ([_availableServers containsObject:peerID])
            {
                [_availableServers removeObject:peerID];
                if(!_isServer)
                {
                    [_joinMultiplayerDelegate refreshTableContent];
                }
            }
			break;
            
        // You're now connected to the server.
        case GKPeerStateConnected:
            break;
            
        // You're now no longer connected to the server.
		case GKPeerStateDisconnected:
			[self disconnectFromServer];
			break;
            
		case GKPeerStateConnecting:
			break;
	}
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
    if ([_connectedClients count] < kOpponentsLimit)
	{
        NSError *error;
		if ([session acceptConnectionFromPeer:peerID error:&error])
        {
			if (![_connectedClients containsObject:peerID])
            {
                [_connectedClients addObject:peerID];
                
                [_hostMultiplayerDelegate refreshTableContent];
            }
		}
        else
        {
			if ([_connectedClients containsObject:peerID])
            {
                [_connectedClients removeObject:peerID];
                [_hostMultiplayerDelegate refreshTableContent];
            }
        }
	}
	else
	{
        [session denyConnectionFromPeer:peerID];
	}
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
	[self disconnectFromServer];
    [self showNetworkErrorAlertView];
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error
{
	if ([[error domain] isEqualToString:GKSessionErrorDomain])
	{
		if ([error code] == GKSessionCannotEnableError)
		{
			[self disconnectFromServer];
            [self showNetworkErrorAlertView];
		}
	}
}

@end
