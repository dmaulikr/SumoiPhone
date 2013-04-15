//
//  JoinMultiplayerViewController.m
//  JetsetSumo
//
//  Created by oliver on 11/16/12.
//  Copyright (c) 2012 Jetset Inc. All rights reserved.
//

#import "JoinMultiplayerViewController.h"

@interface JoinMultiplayerViewController ()

@end

@implementation JoinMultiplayerViewController

@synthesize multiplayerManager = _multiplayerManager;
@synthesize availableServerArray = _availableServerArray;
@synthesize tableView = _tableView;
@synthesize joinMultiplayerViewControllerDelegate = _joinMultiplayerViewControllerDelegate;

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
    
    NSLog(@"multiplayermanager: %@",_multiplayerManager);
    _multiplayerManager = [Multiplayer alloc];
    NSLog(@"multiplayermanager: %@",_multiplayerManager);
    [_multiplayerManager startSearchingForServersWithClass:self];
}

-(void)moveBackToMainScreen
{
    [_multiplayerManager disconnectFromServer];
    [_joinMultiplayerViewControllerDelegate jumpBackToMainScreen];
}

-(void)startGameFromServer
{
    [_joinMultiplayerViewControllerDelegate jumpToMultiplayerGameView:_multiplayerManager];
    NSLog(@"GOT ANOTHER START REQUEST! %@",_joinMultiplayerViewControllerDelegate);
}

-(void)refreshTableContent
{
    if(!_availableServerArray)
    {
        _availableServerArray = [[NSMutableArray alloc] init];
    }
    _availableServerArray = [_multiplayerManager getAllServerArray];
    [_tableView reloadData];
    //
    //TODO:IF SERVERS BECOME ZERO WHEN CONNECTING, BACK TO HOME
    //
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_multiplayerManager getAvailableServerCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [_multiplayerManager.session displayNameForPeer:[_multiplayerManager getServerFromIndexPath:[indexPath row]]];
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //
    //TODO: CHECK FOR ERRORS IF CONNECTION FAILED
    //
    
    [_multiplayerManager connectToServerWithPeerID:[_multiplayerManager getServerFromIndexPath:[indexPath row]]];
    UIView *waitView = [[UIView alloc] initWithFrame:CGRectMake(kHalfDeviceScreenWidth-100,kHalfDeviceScreenHeight-100,200,200)];
    waitView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:waitView];
    UILabel *waitLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,30,180,20)];
    waitLabel.text = @"Waiting for Server";
    waitLabel.backgroundColor = [UIColor clearColor];
    waitLabel.textColor = [UIColor whiteColor];
    waitLabel.contentMode = UIViewContentModeCenter;
    [waitView addSubview:waitLabel];
    UIActivityIndicatorView *waitSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    waitSpinner.center = CGPointMake(100,100);
    waitSpinner.contentMode = UIViewContentModeCenter;
    [waitSpinner startAnimating];
    [waitView addSubview:waitSpinner];
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(10,150,180,20)];
    [backBtn addTarget:self action:@selector(moveBackToMainScreen) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setTitle:@"Back" forState:UIControlStateNormal];
    [waitView addSubview:backBtn];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
