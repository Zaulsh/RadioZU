//
//  SettingsVC.m
//  capitalFM
//
//  Created by Sahil garg on 16/03/18.
//  Copyright © 2018 DS. All rights reserved.
//

#import "SettingsVC.h"
#import "PlayerVC.h"
#import "AppDelegate.h"
#import <RESideMenu/RESideMenu.h>
#import "SleepTimerVC.h"

@interface SettingsVC ()
{
    IBOutlet UISwitch *notifySwitch;
}

@property (nonatomic,strong) PlayerVC *playerView;

@end

@implementation SettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _playerView = [[PlayerVC alloc]init];
    _playerView.view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height -70, [UIScreen mainScreen].bounds.size.width, 400);
    [_playerView.btnScrollUp addTarget:self action:@selector(actionShowAll:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_playerView.view];
    notifySwitch.transform = CGAffineTransformMakeScale(0.75, 0.75);
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.playerView.btnScrollUp addGestureRecognizer:pan];
}

-(void)viewDidAppear:(BOOL)animated {
    _playerView.lblArtist.text = [AppDelegate shared].strArtistGlobal;
    _playerView.lblSong.text =  [AppDelegate shared].strSongGlobal;
    
    [_playerView setPlayerButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)actionShowAll:(id)sender {
    
    if (_playerView.view.frame.origin.y == [UIScreen mainScreen].bounds.size.height -70) {
        _playerView.view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height -400, [UIScreen mainScreen].bounds.size.width, 400);
        [_playerView.tbPlayerSongs reloadData];
    } else {
        _playerView.view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height -70, [UIScreen mainScreen].bounds.size.width, 400);
    }
    
}

#pragma mark - Pan Gesture
-(void) handlePan:(UIPanGestureRecognizer*)panGes{
    
    if (panGes.state == UIGestureRecognizerStateEnded) {
        if (_playerView.view.frame.origin.y < [UIScreen mainScreen].bounds.size.height-70) {
            
            __weak typeof(self) weakSelf = self;
            
            [UIView animateWithDuration:0.0 animations:^{
                weakSelf.playerView.view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-400, weakSelf.playerView.view.frame.size.width, 400);
            }];
        }
    } else {
        CGPoint point = [panGes locationInView:self.view];
        
        CGRect newframe = CGRectMake(0, point.y, _playerView.view.frame.size.width, _playerView.view.frame.size.height);
        
        if (newframe.origin.y<[UIScreen mainScreen].bounds.size.height-400) {
            newframe = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-400, _playerView.view.frame.size.width, 400);
        }
        
        if (newframe.origin.y>[UIScreen mainScreen].bounds.size.height-70) {
            newframe = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-70, _playerView.view.frame.size.width, 400);
        }
        
        CGPoint vel = [panGes velocityInView:self.playerView.btnScrollUp];
        if (vel.y > 0) {
            _playerView.view.frame = newframe;
        } else {
            _playerView.view.frame = newframe;
        }
    }
}

- (IBAction)sideMenuAction:(id)sender {
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (IBAction)actionSleepTimer:(id)sender {
    SleepTimerVC *objSleepTimer = [[SleepTimerVC alloc]init];
    [self.navigationController pushViewController:objSleepTimer animated:YES];
}

@end
