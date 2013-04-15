//
//  HostMultiplayerViewController.m
//  JetsetSumo
//
//  Created by oliver on 11/16/12.
//  Copyright (c) 2012 Jetset Inc. All rights reserved.
//

#import "HostMultiplayerViewController.h"

@interface HostMultiplayerViewController ()

@end

@implementation HostMultiplayerViewController

@synthesize multiplayerManager = _multiplayerManager;
@synthesize connectedUsersArray = _connectedUsersArray;
@synthesize tableView = _tableView;
@synthesize hostMultiplayerViewControllerDelegate = _hostMultiplayerViewControllerDelegate;
@synthesize startBtn = _startBtn;

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
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(kHalfDeviceScreenWidth*0.25,50.0,kHalfDeviceScreenWidth*1.5,kHalfDeviceScreenHeight) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
	UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [backBtn addTarget:self action:@selector(moveBackToMainScreen) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setTitle:@"Back" forState:UIControlStateNormal];
    backBtn.frame = CGRectMake(kHalfDeviceScreenWidth-100,(kHalfDeviceScreenHeight*2)-100,200,50);
    [self.view addSubview:backBtn];
    
    _startBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_startBtn addTarget:self action:@selector(startGame) forControlEvents:UIControlEventTouchUpInside];
    [_startBtn setTitle:@"Start Game" forState:UIControlStateNormal];
    _startBtn.hidden = YES;
    _startBtn.frame = CGRectMake(kHalfDeviceScreenWidth-100,(kHalfDeviceScreenHeight*2)-170,200,50);
    [self.view addSubview:_startBtn];
    
    _multiplayerManager = [Multiplayer alloc];
    [_multiplayerManager startHostingServerWithClass:self];
    
}

-(void)moveBackToMainScreen
{
    NSLog(@"%@ %@",_multiplayerManager,_multiplayerManager.session);
    [_multiplayerManager disconnectFromServer];
    NSLog(@"%@ %@",_multiplayerManager,_multiplayerManager.session);
    
    [_hostMultiplayerViewControllerDelegate jumpBackToMainScreen];
}

-(void)startGame
{
    [_multiplayerManager sendStringToAllPeers:@"ss,0,0"];
    [_hostMultiplayerViewControllerDelegate jumpToMultiplayerGameView:_multiplayerManager];
}

-(void)refreshTableContent
{
    if(!_connectedUsersArray)
    {
        _connectedUsersArray = [[NSMutableArray alloc] init];
    }
    _connectedUsersArray = [_multiplayerManager getAllClientArray];
    
    [_tableView reloadData];
    
    if([_multiplayerManager getAvailableClientCount])
    {
        _startBtn.hidden = NO;
    }
    else
    {
        _startBtn.hidden = YES;
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_multiplayerManager getAvailableClientCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [_multiplayerManager.session displayNameForPeer:[_multiplayerManager getClientFromIndexPath:[indexPath row]]];
    return cell;
}

/*
#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%d",[indexPath row]);
}
*/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
