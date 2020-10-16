//
//  SleepTimerVC.m
//  capitalFM
//
//  Created by Sahil garg on 17/03/18.
//  Copyright © 2018 DS. All rights reserved.
//

#import "SleepTimerVC.h"
#import "PlayerVC.h"
#import "AppDelegate.h"
#import "PlayerVC.h"
#import <RESideMenu/RESideMenu.h>
#import "AppDelegate.h"
#import "HomeViewController.h"

@interface SleepTimerVC () <UIPickerViewDataSource, UIPickerViewDelegate>
{
    IBOutlet UIPickerView *pickerTimerHours;
    IBOutlet UIPickerView *pickerTimerMins;
    NSMutableArray *arrayListMins;
    NSMutableArray *arrayListHours;
}

@property (nonatomic,strong) PlayerVC *playerView;

@end

@implementation SleepTimerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:true];
    
    _playerView = [PlayerVC sharedInstance];
    _playerView.view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height -70, [UIScreen mainScreen].bounds.size.width, 400);
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        _playerView.view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 120, [UIScreen mainScreen].bounds.size.width, 600);
    }
    
    [_playerView.btnScrollUp removeTarget:nil  action:NULL forControlEvents:UIControlEventTouchUpInside];
    [_playerView.btnScrollUp addTarget:self action:@selector(actionShowAll:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_playerView.view];
    
    _playerView.lblArtist.text = [AppDelegate shared].strArtistGlobal;
    _playerView.lblSong.text =  [AppDelegate shared].strSongGlobal;
    [_playerView setPlayerButton];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.playerView.btnScrollUp addGestureRecognizer:pan];
    
    arrayListMins = [[NSMutableArray alloc]init];
    arrayListHours = [[NSMutableArray alloc]init];
    
    //    [arrayListHours addObject:@"Hours"];
    for (int i=0; i<24; i++) {
        [arrayListHours addObject:[NSString stringWithFormat:@"%d",i]];
    }
    
    //    [arrayListMins addObject:@"Minutes"];
    for (int i=0; i<60; i++) {
        [arrayListMins addObject:[NSString stringWithFormat:@"%d",i]];
    }
    
    [pickerTimerHours reloadAllComponents];
    [pickerTimerMins reloadAllComponents];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)actionBack:(id)sender {
    
    [self.sideMenuViewController setContentViewController:[HomeViewController sharedInstance] animated:YES];
    [self.sideMenuViewController hideMenuViewController];

}

-(void)actionShowAll:(id)sender {
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        if (_playerView.view.frame.origin.y == [UIScreen mainScreen].bounds.size.height - 120) {
            _playerView.view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 600, [UIScreen mainScreen].bounds.size.width, 600);
            [_playerView.tbPlayerSongs reloadData];
        } else {
            _playerView.view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 120, [UIScreen mainScreen].bounds.size.width, 600);
        }
        
    } else {
        
        if (_playerView.view.frame.origin.y == [UIScreen mainScreen].bounds.size.height -70) {
            _playerView.view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height -400, [UIScreen mainScreen].bounds.size.width, 400);
            [_playerView.tbPlayerSongs reloadData];
        } else {
            _playerView.view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 70, [UIScreen mainScreen].bounds.size.width, 400);
        }
        
    }
    
}

#pragma mark - Pan Gesture
-(void) handlePan:(UIPanGestureRecognizer*)panGes{
    
    if (panGes.state == UIGestureRecognizerStateEnded) {
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            
            __weak typeof(self) weakSelf = self;
            
            CGPoint velocity = [panGes velocityInView:self.playerView.btnScrollUp];
            
            if (velocity.y > 0) {
                [UIView animateWithDuration:0.0 animations:^{
                    weakSelf.playerView.view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-600, weakSelf.playerView.view.frame.size.width, 600);
                }];
            } else {
                [UIView animateWithDuration:0.0 animations:^{
                    weakSelf.playerView.view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-120, weakSelf.playerView.view.frame.size.width, 600);
                }];
            }
            
        } else {
            
            __weak typeof(self) weakSelf = self;
            
            CGPoint velocity = [panGes velocityInView:self.playerView.btnScrollUp];
            
            if (velocity.y > 0) {
                [UIView animateWithDuration:0.0 animations:^{
                    weakSelf.playerView.view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-70, weakSelf.playerView.view.frame.size.width, 400);
                }];
            } else {
                [UIView animateWithDuration:0.0 animations:^{
                    weakSelf.playerView.view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-400, weakSelf.playerView.view.frame.size.width, 400);
                }];
            }
            
            
        }
        
    } else {
        
        CGPoint point = [panGes locationInView:self.view];
        CGRect newframe = CGRectMake(0, point.y, _playerView.view.frame.size.width, _playerView.view.frame.size.height);
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            
            if (newframe.origin.y<[UIScreen mainScreen].bounds.size.height-600) {
                newframe = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-600, _playerView.view.frame.size.width, 600);
            }
            
            if (newframe.origin.y>[UIScreen mainScreen].bounds.size.height-120) {
                newframe = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-120, _playerView.view.frame.size.width, 600);
            }
            
        } else {
            
            if (newframe.origin.y<[UIScreen mainScreen].bounds.size.height-400) {
                newframe = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-400, _playerView.view.frame.size.width, 400);
            }
            
            if (newframe.origin.y>[UIScreen mainScreen].bounds.size.height-70) {
                newframe = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-70, _playerView.view.frame.size.width, 400);
            }
            
        }
        
        CGPoint vel = [panGes velocityInView:self.playerView.btnScrollUp];
        if (vel.y > 0) {
            _playerView.view.frame = newframe;
        } else {
            _playerView.view.frame = newframe;
        }
        
    }
    
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(nonnull UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == pickerTimerHours) {
        return arrayListHours.count;
    } else{
        return arrayListMins.count;
    }

}

-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    if (pickerView == pickerTimerHours) {
        return [arrayListHours objectAtIndex:row];
    } else {
        return [arrayListMins objectAtIndex:row];
    }
    
}

- (IBAction)actionTimer:(id)sender {
    
    NSString *strTimerHours = [arrayListHours objectAtIndex:[pickerTimerHours selectedRowInComponent:0]];
   
    NSString *strTimerMinutes = [arrayListHours objectAtIndex:[pickerTimerMins selectedRowInComponent:0]];
   
    NSInteger interval = [strTimerHours integerValue]*60*60 + [strTimerMinutes integerValue]*60;
    
    [[AppDelegate shared].timer invalidate];
    [AppDelegate shared].timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self
                                                    selector:@selector(updateTimer)  userInfo:nil  repeats:NO];
    
    [[NSRunLoop mainRunLoop] addTimer:[AppDelegate shared].timer forMode:NSRunLoopCommonModes];
}

//function
-(void) updateTimer{
    [[AppDelegate shared].playerGlobal pause];
    [[PlayerVC sharedInstance]setPlayerButton];
}

@end
