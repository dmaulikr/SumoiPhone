//
//  GameplayViewController.m
//  JetsetSumo
//
//  Created by oliver on 11/16/12.
//  Copyright (c) 2012 Jetset Inc. All rights reserved.
//

#import "GameplayViewController.h"

@interface GameplayViewController ()

@end

@implementation GameplayViewController

#define kGameFPS 1.0/10.0

@synthesize motionManager = _motionManager;
@synthesize thisPlayer = _thisPlayer;
@synthesize opponentPlayer = _opponentPlayer;
@synthesize thisPlayerInView = _thisPlayerInView;
@synthesize opponentPlayerInView = _opponentPlayerInView;
@synthesize gameStatus = _gameStatus;
@synthesize networkInterface = _networkInterface;
@synthesize gameplayViewControllerDelegate = _gameplayViewControllerDelegate;
@synthesize countDownNumber = _countDownNumber;

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
    //
    //TODO:HIDE SERVER WHEN GAME STARTS
    //
    
    [super viewDidLoad];
    //Instatate necessary classes
    _thisPlayer = [Player alloc];
    _opponentPlayer = [Player alloc];
    _gameStatus = [Gameplay alloc];
    [_gameStatus pauseGame];
    
    //Single Player
    if(_networkInterface == nil)
    {
        _networkInterface = [Multiplayer alloc];
        _networkInterface.isServer = YES;
        _networkInterface.isMultiplayer = NO;
        NSLog(@"SINGLEPLAYER: %@",_networkInterface);
    }
    
    self.view.backgroundColor = [UIColor blackColor];
    
    UIImageView *bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dohyou.jpg"]];
    bgImage.frame = CGRectMake((self.view.bounds.size.height/2)-240,(self.view.bounds.size.width/2)-160,480,320);
    [self.view addSubview:bgImage];
    
    if(_networkInterface.isServer)
    {
        _thisPlayerInView = [_thisPlayer createPlayerAsServer:YES];
        [self.view addSubview:_thisPlayerInView];
        _opponentPlayerInView = [_opponentPlayer createPlayerAsServer:NO];
        [self.view addSubview:_opponentPlayerInView];
    }
    else if(!_networkInterface.isServer)
    {
        _thisPlayerInView = [_thisPlayer createPlayerAsServer:NO];
        [self.view addSubview:_thisPlayerInView];
        _opponentPlayerInView = [_opponentPlayer createPlayerAsServer:YES];
        [self.view addSubview:_opponentPlayerInView];
    }
    [self resetAndStartGame];
    //[self startRoundCountdownAnimationFrom:3];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [backBtn addTarget:self action:@selector(moveBackToMainScreen) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setTitle:@"Back" forState:UIControlStateNormal];
    backBtn.frame = CGRectMake(5,5,100,25);
    [self.view addSubview:backBtn];
    
    [_networkInterface setUpGameplayViewControllerDelegate:self];
    //[_gameStatus startGame];
	[self startMotion];
}

-(void)moveBackToMainScreen
{
    [_networkInterface disconnectFromServer];
    [_gameplayViewControllerDelegate jumpBackToMainScreen];
}

- (void)startGameWithMultiplayer:(Multiplayer *)networkInterface
{
    if(_networkInterface == nil)
    {
        _networkInterface = [Multiplayer alloc];
    }
    _networkInterface = networkInterface;
    _networkInterface.isMultiplayer = YES;
    NSLog(@"MULTIPLAYER: %@",_networkInterface);
}

- (void)resetAndStartGame
{
    if(_networkInterface.isServer)
    {
        _thisPlayerInView.frame = [_thisPlayer getStartPositionForPlayerAsServer:YES];
        [self setInitValuesForPlayer:_thisPlayer withFrame:_thisPlayerInView.frame andRotationAngle:0.0];
        [self animatePlayerToLocation:_thisPlayer inView:_thisPlayerInView];
        
        _opponentPlayerInView.frame = [_opponentPlayer getStartPositionForPlayerAsServer:NO];
        [self setInitValuesForPlayer:_opponentPlayer withFrame:_opponentPlayerInView.frame andRotationAngle:180.0];
        [self animatePlayerToLocation:_opponentPlayer inView:_opponentPlayerInView];
    }
    else if(!_networkInterface.isServer)
    {
        _thisPlayerInView.frame = [_thisPlayer getStartPositionForPlayerAsServer:NO];
        [self setInitValuesForPlayer:_thisPlayer withFrame:_thisPlayerInView.frame andRotationAngle:180.0];
        [self animatePlayerToLocation:_thisPlayer inView:_thisPlayerInView];
        
        _opponentPlayerInView.frame = [_opponentPlayer getStartPositionForPlayerAsServer:YES];
        [self setInitValuesForPlayer:_opponentPlayer withFrame:_opponentPlayerInView.frame andRotationAngle:0.0];
        [self animatePlayerToLocation:_opponentPlayer inView:_opponentPlayerInView];
    }
    
    //Start Countdown
    _countDownNumber = 4;
    [self startRoundCountdownAnimation];
}

-(void)startRoundCountdownAnimation
{
    if(!_gameStatus.gameIsRunning)
    {
        if(_countDownNumber==4)
        {
            CGPoint playerLabelPoint;
            playerLabelPoint.x = (_networkInterface.isServer) ? (kHalfDeviceScreenWidth-70-20) : (kHalfDeviceScreenWidth+70-20);
            playerLabelPoint.y = kHalfDeviceScreenHeight-80;
            UILabel *playerLabel = [[UILabel alloc] initWithFrame:CGRectMake(playerLabelPoint.x,playerLabelPoint.y,40.0,40.0)];
            playerLabel.backgroundColor = [UIColor whiteColor];
            playerLabel.textColor = [UIColor blackColor];
            playerLabel.font = [UIFont systemFontOfSize:25.0];
            playerLabel.layer.cornerRadius = 10.0;
            playerLabel.tag = 12;
            playerLabel.text = @" ▼";
            playerLabel.layer.opacity = 0.2;
            [self.view addSubview:playerLabel];
            
            CABasicAnimation *playerLabelAnim = [CABasicAnimation animationWithKeyPath:@"position.y"];
            playerLabelAnim.duration = 1.0;
            playerLabelAnim.repeatCount = 0;
            playerLabelAnim.autoreverses = YES;
            playerLabelAnim.removedOnCompletion = YES;
            playerLabelAnim.timingFunction = UIViewAnimationCurveEaseInOut;
            playerLabelAnim.fillMode = kCAFillModeForwards;
            playerLabelAnim.fromValue = [NSNumber numberWithFloat:kHalfDeviceScreenHeight-80];
            playerLabelAnim.toValue = [NSNumber numberWithFloat:kHalfDeviceScreenHeight-60];
            [playerLabel.layer addAnimation:playerLabelAnim forKey:@"position.y"];
        }
        
        UILabel *countDownLabel = [[UILabel alloc] initWithFrame:CGRectMake(kHalfDeviceScreenWidth-200,kHalfDeviceScreenHeight-50,400,80)];
        countDownLabel.tag = 10;
        countDownLabel.textAlignment = NSTextAlignmentCenter;
        if(_countDownNumber==1)
        {
            countDownLabel.text = [NSString stringWithFormat:@"Fight!"];
        }
        else
        {
            countDownLabel.text = [NSString stringWithFormat:@"%u",_countDownNumber-1];
        }
        countDownLabel.font = [UIFont systemFontOfSize:60];
        countDownLabel.textColor = [UIColor whiteColor];
        countDownLabel.backgroundColor = [UIColor clearColor];
        [self.view addSubview:countDownLabel];
        
        CAKeyframeAnimation *fontSizeAnim = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        fontSizeAnim.duration = 1.0;
        fontSizeAnim.repeatCount = 0;
        fontSizeAnim.autoreverses = NO;
        fontSizeAnim.removedOnCompletion = YES;
        fontSizeAnim.timingFunction = UIViewAnimationCurveEaseInOut;
        fontSizeAnim.fillMode = kCAFillModeForwards;
        CATransform3D transform = CATransform3DMakeScale(4, 4, 1);
        [fontSizeAnim setValues:[NSArray arrayWithObjects:
                                   [NSValue valueWithCATransform3D:CATransform3DIdentity],
                                   [NSValue valueWithCATransform3D:transform],
                                 nil]];
        
        CABasicAnimation *textOpacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
        textOpacityAnim.duration = 1.0;
        textOpacityAnim.repeatCount = 0;
        textOpacityAnim.autoreverses = NO;
        textOpacityAnim.removedOnCompletion = YES;
        textOpacityAnim.timingFunction = UIViewAnimationCurveEaseInOut;
        textOpacityAnim.fillMode = kCAFillModeForwards;
        textOpacityAnim.fromValue = [NSNumber numberWithFloat:1.0];
        textOpacityAnim.toValue = [NSNumber numberWithFloat:0.0];
        
        fontSizeAnim.delegate = self;
        
        [countDownLabel.layer addAnimation:fontSizeAnim forKey:@"transform"];
        [countDownLabel.layer addAnimation:textOpacityAnim forKey:@"opacity"];
    }
}

-(void)startEndRoundAnimation
{
    UIView *endRoundCont = [[UIView alloc] initWithFrame:CGRectMake(-250.0, kHalfDeviceScreenHeight-100.0, 250.0, 100.0)];
    endRoundCont.tag = 11;
    endRoundCont.backgroundColor = [UIColor whiteColor];
    endRoundCont.layer.borderColor = [UIColor blackColor].CGColor;
    endRoundCont.layer.borderWidth = 3.0;
    endRoundCont.layer.cornerRadius = 10.0;
    
    UILabel *scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0, 10.0, 60.0, 20.0)];
    scoreLabel.text = @"Score";
    scoreLabel.textColor = [UIColor blackColor];
    scoreLabel.font = [UIFont systemFontOfSize:20.0];
    scoreLabel.backgroundColor = [UIColor clearColor];
    [endRoundCont addSubview:scoreLabel];
    
    UILabel *player1Label = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 50.0, 60.0, 40.0)];
    player1Label.text = (_networkInterface.isServer) ? [NSString stringWithFormat:@"%u",_thisPlayer.playerScore] : [NSString stringWithFormat:@"%u",_opponentPlayer.playerScore];
    player1Label.textColor = [UIColor blackColor];
    player1Label.font = [UIFont systemFontOfSize:40.0];
    player1Label.backgroundColor = [UIColor clearColor];
    [endRoundCont addSubview:player1Label];
    
    UILabel *player2Label = [[UILabel alloc] initWithFrame:CGRectMake(180.0, 50.0, 60.0, 40.0)];
    player2Label.text = (_networkInterface.isServer) ? [NSString stringWithFormat:@"%u",_opponentPlayer.playerScore] : [NSString stringWithFormat:@"%u",_thisPlayer.playerScore];
    player2Label.textColor = [UIColor blackColor];
    player2Label.font = [UIFont systemFontOfSize:40.0];
    player2Label.backgroundColor = [UIColor clearColor];
    [endRoundCont addSubview:player2Label];
    
    [self.view addSubview:endRoundCont];
    
    CAKeyframeAnimation *endRoundAnim = [CAKeyframeAnimation animationWithKeyPath:@"position.x"];
    endRoundAnim.autoreverses = NO;
    endRoundAnim.removedOnCompletion = NO;
    endRoundAnim.delegate = self;
    endRoundAnim.duration = 3.0;
    endRoundAnim.values = [NSArray arrayWithObjects:
                           [NSNumber numberWithFloat:-250.0],
                           [NSNumber numberWithFloat:kHalfDeviceScreenWidth],
                           [NSNumber numberWithFloat:kHalfDeviceScreenWidth],
                           [NSNumber numberWithFloat:(kHalfDeviceScreenWidth*2)+250],
                           nil];
    endRoundAnim.keyTimes = [NSArray arrayWithObjects:
                             [NSNumber numberWithFloat:0.0],
                             [NSNumber numberWithFloat:0.2],
                             [NSNumber numberWithFloat:0.8],
                             [NSNumber numberWithFloat:1.0],
                             nil];
    endRoundAnim.timingFunctions = [NSArray arrayWithObjects:
                                    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
                                    nil,
                                    nil,
                                    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn],
                                    nil];
    endRoundAnim.fillMode = kCAFillModeForwards;
    [endRoundCont.layer addAnimation:endRoundAnim forKey:@"position"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    //
    //TODO: ADD CHECK TO MAKE SURE IT'S THE RIGHT ANIMATION
    //
    
    for (UIView *subView in self.view.subviews)
    {
        //CountDown Animation
        if (subView.tag == 10)
        {
            [subView removeFromSuperview];
            _countDownNumber--;
            if(_countDownNumber)
            {
                [self startRoundCountdownAnimation];
            }
            else if(!_countDownNumber)
            {
                [_gameStatus startGame];
                _countDownNumber = 4;
            }
        }
        //Score Animation
        if (subView.tag == 11)
        {
            [subView removeFromSuperview];
            [self resetAndStartGame];
            [_thisPlayer calculateCurrentRadius];
            [_opponentPlayer calculateCurrentRadius];
        }
        //Player Label
        if(subView.tag == 12 && _countDownNumber <= 3)
        {
            [subView removeFromSuperview];
        }
    }
}

- (void)setInitValuesForPlayer:(Player *)player withFrame:(CGRect)refFrame andRotationAngle:(CGFloat)rotationAngle
{
    player.newPosX = refFrame.origin.x;
    player.oldPosX = refFrame.origin.x-0.5;
    player.newPosY = refFrame.origin.y;
    player.oldPosY = refFrame.origin.y-0.5;
    player.newRotationAngle = rotationAngle/180.0*M_PI;
    player.oldRotationAngle = (rotationAngle-0.5)/180.0*M_PI;
}

- (void)startMotion
{
    if (_motionManager == nil)
    {
        _motionManager = [[CMMotionManager alloc] init];
    }
    _motionManager.deviceMotionUpdateInterval = kGameFPS;
    _motionManager.showsDeviceMovementDisplay = YES;
    
    CMDeviceMotionHandler motionHandler = ^ (CMDeviceMotion *motion, NSError *error) {
        if(_gameStatus.gameIsRunning)
        {
            CMAttitude *a = _motionManager.deviceMotion.attitude;
            CGRect animateToFrame = [_thisPlayer updatePlayerWithPitchAcceleration:a.pitch withRollAcceleration:a.roll];
            [_thisPlayer calculateAngleOfMovement];
            [_thisPlayer calculateCurrentRadius];
            
            NSLog(@"%f",_thisPlayer.currentRadius);
            
            [self animatePlayerToLocation:_thisPlayer inView:_thisPlayerInView];
            
            _thisPlayer.oldPosX = _thisPlayer.newPosX;
            _thisPlayer.oldPosY = _thisPlayer.newPosY;
            _thisPlayerInView.frame = CGRectMake(_thisPlayer.newPosX,_thisPlayer.newPosY,_thisPlayerInView.frame.size.width,_thisPlayerInView.frame.size.height);
            
            if(_networkInterface.isServer)
            {
                NSString *str = [NSString stringWithFormat:@"s,%f,%f",animateToFrame.origin.x,animateToFrame.origin.y];
                [_networkInterface sendStringToAllPeers:str];
            }
            else if(!_networkInterface.isServer)
            {
                NSString *str = [NSString stringWithFormat:@"c,%f,%f",animateToFrame.origin.x,animateToFrame.origin.y];
                [_networkInterface sendStringToAllPeers:str];
            }
            
            if(_networkInterface.isServer)
            {
                if([_thisPlayer checkForCollisionBetweenClient:_thisPlayerInView andServer:_opponentPlayerInView])
                {
                    //CORRECT SELF
                    CGRect newRefSelfFrame = [_thisPlayer correctPlayerPositionInCaseOfCollision:_thisPlayerInView thisPlayer:_thisPlayer opponentPlayer:_opponentPlayer];
                    _thisPlayer.newPosX = newRefSelfFrame.origin.x;
                    _thisPlayer.newPosY = newRefSelfFrame.origin.y;
                    if(!_thisPlayer.oldPosX || !_thisPlayer.oldPosY)
                    {
                        _thisPlayer.oldPosX = _thisPlayer.newPosX;
                        _thisPlayer.oldPosY = _thisPlayer.newPosY;
                    }
                    //[_thisPlayer calculateAngleOfMovement];
                    [_thisPlayer calculateCurrentRadius];
                    [self animatePlayerToLocation:_thisPlayer inView:_thisPlayerInView];
                    _thisPlayer.oldPosX = _thisPlayer.newPosX;
                    _thisPlayer.oldPosY = _thisPlayer.newPosY;
                    _thisPlayerInView.frame = CGRectMake(_thisPlayer.newPosX,_thisPlayer.newPosY,_thisPlayerInView.frame.size.width,_thisPlayerInView.frame.size.height);
                    
                    //CORRECT CLIENT
                    CGRect newRefOppFrame = [_opponentPlayer correctPlayerPositionInCaseOfCollision:_opponentPlayerInView thisPlayer:_thisPlayer opponentPlayer:_opponentPlayer];
                    _opponentPlayer.newPosX = newRefOppFrame.origin.x;
                    _opponentPlayer.newPosY = newRefOppFrame.origin.y;
                    
                    if(!_opponentPlayer.oldPosX || !_opponentPlayer.oldPosY)
                    {
                        _opponentPlayer.oldPosX = _opponentPlayer.newPosX;
                        _opponentPlayer.oldPosY = _opponentPlayer.newPosY;
                    }
                    //[_opponentPlayer calculateAngleOfMovement];
                    [_opponentPlayer calculateCurrentRadius];
                    [self animatePlayerToLocation:_opponentPlayer inView:_opponentPlayerInView];
                    _opponentPlayer.oldPosX = _opponentPlayer.newPosX;
                    _opponentPlayer.oldPosY = _opponentPlayer.newPosY;
                    _opponentPlayerInView.frame = CGRectMake(_opponentPlayer.newPosX,_opponentPlayer.newPosY,_opponentPlayerInView.frame.size.width,_opponentPlayerInView.frame.size.height);
                    
                    //SEND NEW FRAMES TO CLIENT
                    NSString *strsc = [NSString stringWithFormat:@"sc,%f,%f",_thisPlayer.newPosX,_thisPlayer.newPosY];
                    [_networkInterface sendStringToAllPeers:strsc];
                    NSString *strcc = [NSString stringWithFormat:@"cc,%f,%f",_opponentPlayer.newPosX,_opponentPlayer.newPosY];
                    [_networkInterface sendStringToAllPeers:strcc];
                }
                
                //THIS SHOULD REALLY BE INSIDE THE "updateOpponentPositionWithFrameX" METHOD
                if([_thisPlayer checkIfPlayerIsOutsideRing])
                {
                    [_gameStatus pauseGame];
                    _opponentPlayer.playerScore++;
                    NSString *strsw = [NSString stringWithFormat:@"cw,0.0,0.0"];
                    [_networkInterface sendStringToAllPeers:strsw];
                    [self startEndRoundAnimation];
                }
                else if([_opponentPlayer checkIfPlayerIsOutsideRing])
                {
                    [_gameStatus pauseGame];
                    _thisPlayer.playerScore++;
                    NSString *strsw = [NSString stringWithFormat:@"sw,0.0,0.0"];
                    [_networkInterface sendStringToAllPeers:strsw];
                    [self startEndRoundAnimation];
                }
                
                //If SinglePlayer Move Player
                if(!_networkInterface.isMultiplayer)
                {
                    [self moveSinglePlayer];
                }
            }
        }
    };
    
    [_motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXTrueNorthZVertical toQueue:[NSOperationQueue currentQueue] withHandler:motionHandler];
}

- (void)animatePlayerToLocation:(Player *)player inView:(UIImageView *)playerInView
{
    if(player.newRotationAngle != player.oldRotationAngle)
    {
        CABasicAnimation *thisPlayerAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        thisPlayerAnimation.duration = kGameFPS;
        thisPlayerAnimation.autoreverses = NO;
        thisPlayerAnimation.removedOnCompletion = NO;
        thisPlayerAnimation.fillMode = kCAFillModeForwards;
        thisPlayerAnimation.fromValue = [NSNumber numberWithFloat:player.oldRotationAngle];
        thisPlayerAnimation.toValue = [NSNumber numberWithFloat:player.newRotationAngle];
        
        CGPoint startPoint = CGPointMake(player.oldPosX,player.oldPosY);
        CGPoint stopPoint = CGPointMake(player.newPosX,player.newPosY);
        
        CABasicAnimation *thisPlayerPosition = [CABasicAnimation animationWithKeyPath:@"position"];
        thisPlayerPosition.duration = kGameFPS;
        thisPlayerPosition.autoreverses = NO;
        thisPlayerPosition.removedOnCompletion = NO;
        thisPlayerPosition.fillMode = kCAFillModeForwards;
        thisPlayerPosition.fromValue = [NSValue valueWithCGPoint:startPoint];
        thisPlayerPosition.toValue = [NSValue valueWithCGPoint:stopPoint];
        
        [playerInView.layer addAnimation:thisPlayerAnimation forKey:@"transform.rotation"];
        [playerInView.layer addAnimation:thisPlayerPosition forKey:@"position"];
        
        player.oldRotationAngle = player.newRotationAngle;
    }
}

- (void)stopMotion
{
    if (_motionManager)
    {
        [_motionManager stopDeviceMotionUpdates];
    }
    _motionManager = nil;
}

- (void)updateOpponentPositionWithFrameX:(CGFloat)x andY:(CGFloat)y
{
    if(_gameStatus.gameIsRunning)
    {
        _opponentPlayer.newPosX = x;
        _opponentPlayer.newPosY = y;
        if(!_opponentPlayer.oldPosX || !_opponentPlayer.oldPosY)
        {
            _opponentPlayer.oldPosX = _opponentPlayer.newPosX;
            _opponentPlayer.oldPosY = _opponentPlayer.newPosY;
        }
        [_opponentPlayer calculateAngleOfMovement];
        [_opponentPlayer calculateCurrentRadius];
        [self animatePlayerToLocation:_opponentPlayer inView:_opponentPlayerInView];
        _opponentPlayer.oldPosX = _opponentPlayer.newPosX;
        _opponentPlayer.oldPosY = _opponentPlayer.newPosY;
        _opponentPlayerInView.frame = CGRectMake(_opponentPlayer.newPosX,_opponentPlayer.newPosY,_opponentPlayerInView.frame.size.width,_opponentPlayerInView.frame.size.height);
    }
}

-(void)updateOpponentPositionWhenCollisionWithX:(CGFloat)x andY:(CGFloat)y
{
    if(!_networkInterface.isServer)
    {
        _opponentPlayer.newPosX = x;
        _opponentPlayer.newPosY = y;
        if(!_opponentPlayer.oldPosX || !_opponentPlayer.oldPosY)
        {
            _opponentPlayer.oldPosX = _opponentPlayer.newPosX;
            _opponentPlayer.oldPosY = _opponentPlayer.newPosY;
        }
        //[_opponentPlayer calculateAngleOfMovement];
        [_opponentPlayer calculateCurrentRadius];
        [self animatePlayerToLocation:_opponentPlayer inView:_opponentPlayerInView];
        _opponentPlayer.oldPosX = _opponentPlayer.newPosX;
        _opponentPlayer.oldPosY = _opponentPlayer.newPosY;
        _opponentPlayerInView.frame = CGRectMake(_opponentPlayer.newPosX,_opponentPlayer.newPosY,_opponentPlayerInView.frame.size.width,_opponentPlayerInView.frame.size.height);
    }
}

-(void)updateSelfPositionWhenCollisionWithX:(CGFloat)x andY:(CGFloat)y
{
    if(!_networkInterface.isServer)
    {
        _thisPlayer.newPosX = x;
        _thisPlayer.newPosY = y;
        if(!_thisPlayer.oldPosX || !_thisPlayer.oldPosY)
        {
            _thisPlayer.oldPosX = _thisPlayer.newPosX;
            _thisPlayer.oldPosY = _thisPlayer.newPosY;
        }
        //[_thisPlayer calculateAngleOfMovement];
        [_thisPlayer calculateCurrentRadius];
        [self animatePlayerToLocation:_thisPlayer inView:_thisPlayerInView];
        _thisPlayer.oldPosX = _thisPlayer.newPosX;
        _thisPlayer.oldPosY = _thisPlayer.newPosY;
        _thisPlayerInView.frame = CGRectMake(_thisPlayer.newPosX,_thisPlayer.newPosY,_thisPlayerInView.frame.size.width,_thisPlayerInView.frame.size.height);
    }
}

-(void)serverScoredAPoint
{
    if(!_networkInterface.isServer)
    {
        [_gameStatus pauseGame];
        _opponentPlayer.playerScore++;
        [self startEndRoundAnimation];
    }
}

-(void)clientScoredAPoint
{
    if(!_networkInterface.isServer)
    {
        [_gameStatus pauseGame];
        _thisPlayer.playerScore++;
        [self startEndRoundAnimation];
    }
}

-(void)moveSinglePlayer
{
    _opponentPlayer.pitchAccel = 0.5;
    _opponentPlayer.rollAccel = 0.5;
    if((_opponentPlayer.newPosX-(25 * 0.1)) != kHalfDeviceScreenWidth && (_opponentPlayer.newPosX+(25 * 0.1)) != kHalfDeviceScreenWidth)
    {
        if(_opponentPlayer.newPosX+(25 * 0.1)>kHalfDeviceScreenWidth)
        {
            _opponentPlayer.newPosX = _opponentPlayer.newPosX - (25 * 0.1);
        }
        else if(_opponentPlayer.newPosX-(25 * 0.1)<kHalfDeviceScreenWidth)
        {
            _opponentPlayer.newPosX = _opponentPlayer.newPosX + (25 * 0.1);
        }
    }
    if((_opponentPlayer.newPosY-(25 * 0.1)) != kHalfDeviceScreenHeight && (_opponentPlayer.newPosY+(25 * 0.1)) != kHalfDeviceScreenHeight)
    {
        if(_opponentPlayer.newPosY+(25 * 0.1)>kHalfDeviceScreenHeight)
        {
            _opponentPlayer.newPosY = _opponentPlayer.newPosY - (25 * 0.1);
        }
        else if(_opponentPlayer.newPosY-(25 * 0.1)<kHalfDeviceScreenHeight)
        {
            _opponentPlayer.newPosY = _opponentPlayer.newPosY + (25 * 0.1);
        }
    }
    
    if(_opponentPlayer.newPosX != _opponentPlayer.oldPosX || _opponentPlayer.newPosY != _opponentPlayer.oldPosY)
    {
        [_opponentPlayer calculateAngleOfMovement];
        _opponentPlayer.oldRotationAngle = _opponentPlayer.newRotationAngle-(1.0/180.0*M_PI);
        [_opponentPlayer calculateCurrentRadius];
        [self animatePlayerToLocation:_opponentPlayer inView:_opponentPlayerInView];
        
        _opponentPlayer.oldPosX = _opponentPlayer.newPosX;
        _opponentPlayer.oldPosY = _opponentPlayer.newPosY;
        _opponentPlayerInView.frame = CGRectMake(_opponentPlayer.newPosX,_opponentPlayer.newPosY,_opponentPlayerInView.frame.size.width,_opponentPlayerInView.frame.size.height);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
