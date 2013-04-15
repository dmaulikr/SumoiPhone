//
//  TopMenuViewController.m
//  JetsetSumo
//
//  Created by oliver on 11/16/12.
//  Copyright (c) 2012 Jetset Inc. All rights reserved.
//

#import "TopMenuViewController.h"
#import "GameplayViewController.h"

@interface TopMenuViewController () <GameplayViewControllerDelegate>

@end

@implementation TopMenuViewController

@synthesize hostGameBtn = _hostGameBtn;
@synthesize joinGameBtn = _joinGameBtn;
@synthesize singleGameBtn = _singleGameBtn;
@synthesize TopMenuViewControllerDelegate = _TopMenuViewControllerDelegate;
@synthesize multiplayerInterface = _multiplayerInterface;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    //Host Game Button
    _hostGameBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_hostGameBtn addTarget:self action:@selector(jumpToHostGameView) forControlEvents:UIControlEventTouchUpInside];
    [_hostGameBtn setTitle:@"Host a Game" forState:UIControlStateNormal];
    _hostGameBtn.frame = CGRectMake(kHalfDeviceScreenWidth-100,kHalfDeviceScreenHeight-100,200,50);
    [self.view addSubview:_hostGameBtn];
    
    //Join Game Button
    _joinGameBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_joinGameBtn addTarget:self action:@selector(jumpToJoinGameView) forControlEvents:UIControlEventTouchUpInside];
    [_joinGameBtn setTitle:@"Join a Game" forState:UIControlStateNormal];
    _joinGameBtn.frame = CGRectMake(kHalfDeviceScreenWidth-100,kHalfDeviceScreenHeight-30,200,50);
    [self.view addSubview:_joinGameBtn];
    
    //Single Game Button
    _singleGameBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_singleGameBtn addTarget:self action:@selector(jumpToSingleGameView) forControlEvents:UIControlEventTouchUpInside];
    [_singleGameBtn setTitle:@"Single Player" forState:UIControlStateNormal];
    _singleGameBtn.frame = CGRectMake(kHalfDeviceScreenWidth-100,kHalfDeviceScreenHeight+40,200,50);
    [self.view addSubview:_singleGameBtn];
}

-(void)jumpToHostGameView
{
    [self performSegueWithIdentifier:@"hostMultiplayerSegue" sender:self];
}

-(void)jumpToJoinGameView
{
    [self performSegueWithIdentifier:@"joinMultiplayerSegue" sender:self];
}

-(void)jumpBackToMainScreen
{
    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
}

-(void)jumpToMultiplayerGameView:(Multiplayer *)networkInterface
{
    _multiplayerInterface = [Multiplayer alloc];
    _multiplayerInterface = networkInterface;
    
    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
    [self performSegueWithIdentifier:@"gamePlaySegue" sender:self];
    
}

-(void)jumpToSingleGameView
{
    /*UIAlertView *singlePlayerError = [[UIAlertView alloc] initWithTitle:@"Single Player"
                                                                  message:@"Not Available At This Moment."
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
    [singlePlayerError show];*/
    [self performSegueWithIdentifier:@"gamePlaySegue" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"hostMultiplayerSegue"])
    {
        HostMultiplayerViewController *controller = segue.destinationViewController;
        controller.hostMultiplayerViewControllerDelegate = self;
    }
    else if([segue.identifier isEqualToString:@"joinMultiplayerSegue"])
    {
        JoinMultiplayerViewController *controller = segue.destinationViewController;
        controller.joinMultiplayerViewControllerDelegate = self;
    }
    else if([segue.identifier isEqualToString:@"gamePlaySegue"])
    {
        GameplayViewController *controller = segue.destinationViewController;
        controller.gameplayViewControllerDelegate = self;
        _TopMenuViewControllerDelegate = controller;
        [_TopMenuViewControllerDelegate startGameWithMultiplayer:_multiplayerInterface];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
