//
//  VideoVC.m
//  capitalFM
//
//  Created by Sahil garg on 12/04/18.
//  Copyright © 2018 DS. All rights reserved.
//

#import "VideoVC.h"
#import <RESideMenu/RESideMenu.h>
#import "AppDelegate.h"
#import "PlayerVC.h"

@interface VideoVC ()
{
    AVPlayer* playVideo;
    IBOutlet UIButton *btnBack;
}

@end

@implementation VideoVC

+ (instancetype)sharedInstance
{
    static VideoVC *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[VideoVC alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)viewWillAppear:(BOOL)animated {
    
    NSURL *videoURL = [NSURL URLWithString:@"https://play.myovn.com/s1/cache/radiozu/playlist.m3u8"];
    AVPlayerItem* playerItem = [AVPlayerItem playerItemWithURL:videoURL];
    playVideo = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
    playerViewController.player = playVideo;
    playerViewController.view.frame = CGRectMake(0, 5, self.view.frame.size.width, self.view.frame.size.height-5);
    playerViewController.videoGravity = AVLayerVideoGravityResizeAspect;
    playerViewController.showsPlaybackControls = NO;
    [self.view addSubview:playerViewController.view];
    [playVideo play];
    [AppDelegate shared].isVideoPlayer = YES;
    
    [self.view bringSubviewToFront:_controlView];
    [self.view bringSubviewToFront:_navigationView];
    [self.view bringSubviewToFront:_btnShow];
    
    UIImage *image = [UIImage imageNamed:@"button_stop"];
    [_playPauseButton setImage:image forState:UIControlStateNormal];
    
    _controlView.hidden = YES;
    _navigationView.hidden = YES;
    
    UIImage *imageBack = [[UIImage imageNamed:@"back_arrow"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [btnBack setImage:imageBack forState:UIControlStateNormal];
    btnBack.tintColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideo:) name:@"notificationVideo" object:nil];
    
    
}

-(IBAction)backAction:(UIButton*)sender {
    
    if ([AppDelegate shared].isVideoPlayer) {
        [[AppDelegate shared].playerGlobal play];
        [[PlayerVC sharedInstance]setPlayerButton];
    } else {
        [[AppDelegate shared].playerGlobal pause];
        [[PlayerVC sharedInstance]setPlayerButton];
    }
    
    [playVideo pause];
    [AppDelegate shared].isVideoPlayer = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)showControls:(id)sender {
    
    if (_controlView.hidden) {
        _controlView.hidden = NO;
        _navigationView.hidden = NO;
    } else {
        _controlView.hidden = YES;
        _navigationView.hidden = YES;
    }
    
}

-(IBAction)playPauseOption:(UIButton*)sender {
    
    UIImage *image ;
    
    if ([playVideo timeControlStatus] == AVPlayerTimeControlStatusPlaying) {
        [playVideo pause];
        image = [UIImage imageNamed:@"play_start"];
        [AppDelegate shared].isVideoPlayer = NO;
    } else {
        [playVideo play];
        image = [UIImage imageNamed:@"button_stop"];
        [AppDelegate shared].isVideoPlayer = YES;
    }
    [_playPauseButton setImage:image forState:UIControlStateNormal];
}

-(void)playVideo:(id)sender {
    [playVideo play];
}

@end
