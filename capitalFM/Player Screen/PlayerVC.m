//
//  PlayerVC.m
//  capitalFM
//
//  Created by Sahil garg on 16/03/18.
//  Copyright © 2018 DS. All rights reserved.
//

#import "PlayerVC.h"
#import "AppDelegate.h"
#import "PlayerSongsCell.h"

@interface PlayerVC () <UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *arrayLocal;
    IBOutlet UILabel *lblNotFound;
}

@end

@implementation PlayerVC

+ (instancetype)sharedInstance
{
    static PlayerVC *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PlayerVC alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    lblNotFound.hidden = NO;
    _tbPlayerSongs.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    
    self.view.layer.borderWidth = 0.0f;
    self.view.layer.borderColor = [UIColor blackColor].CGColor;
    
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.view.layer.shadowRadius = 10.0f;
    self.view.layer.shadowOpacity = 0.6f;
    self.view.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setPlayerButton {
    
    UIImage *image ;
    
    if ([[AppDelegate shared].playerGlobal timeControlStatus] == AVPlayerTimeControlStatusPlaying) {
        image = [UIImage imageNamed:@"button_stop"];
    } else {
        image = [UIImage imageNamed:@"play_start"];
    }
    
    [_btnPlayPause setImage:image forState:UIControlStateNormal];
}

//
//-(void)setPlayerButtonForInitialOnly {
//
//    UIImage *image ;
//
//    if ([[AppDelegate shared].playerGlobal timeControlStatus] == AVPlayerTimeControlStatusPlaying || [AppDelegate shared].playerGlobal.status == AVPlayerStatusReadyToPlay)
//    {
//        image = [[UIImage imageNamed:@"stop_radio"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    } else {
//        image = [[UIImage imageNamed:@"play_radio"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    }
//
//    [_btnPlayPause setImage:image forState:UIControlStateNormal];
//    _btnPlayPause.tintColor = [UIColor whiteColor];
//
//}

- (IBAction)playPauseButtonAction:(id)sender {
    
    UIImage *image ;
    
    if ([[AppDelegate shared].playerGlobal timeControlStatus] == AVPlayerTimeControlStatusPlaying) {
        [[AppDelegate shared].playerGlobal pause];
        image = [UIImage imageNamed:@"play_start"];
    } else {
        [[AppDelegate shared].playerGlobal play];
        image = [UIImage imageNamed:@"button_stop"];
    }
    [_btnPlayPause setImage:image forState:UIControlStateNormal];
}

#pragma mark - UITableview DataSources and Delegates
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        return 50;
    } else {
        return 30;
    }
    
}

//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//
//    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
//        return 120;
//    } else {
//        return 60;
//    }
//
//}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        UIView *viewHeader = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
        viewHeader.backgroundColor = [UIColor whiteColor];
        
        UILabel *lblTile = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, viewHeader.frame.size.width-15, 50)];
        lblTile.text = @"Mai devreme";
        lblTile.font = [UIFont fontWithName:@"OpenSans-SemiBold" size:30.0f];
        lblTile.textColor = [UIColor blackColor];
        //        lblTile.backgroundColor = [UIColor lightGrayColor];
        [viewHeader addSubview:lblTile];
        
        return viewHeader;
        
    } else {
        UIView *viewHeader = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
        viewHeader.backgroundColor = [UIColor whiteColor];
        
        UILabel *lblTile = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, viewHeader.frame.size.width-15, 30)];
        lblTile.text = @"Mai devreme";
        lblTile.font = [UIFont fontWithName:@"OpenSans-SemiBold" size:15.0f];
        lblTile.textColor = [UIColor blackColor];
        [viewHeader addSubview:lblTile];
        
        return viewHeader;
    }
    
}


//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    return @"Mai devreme";
//}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    arrayLocal = [[[NSUserDefaults standardUserDefaults]valueForKey:@"localArray"] mutableCopy];
    if (arrayLocal.count==0) {
        arrayLocal = [[NSMutableArray alloc]init];
        lblNotFound.hidden = NO;
    } else {
        lblNotFound.hidden = YES;
    }
    
    return arrayLocal.count;;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    PlayerSongsCell *playerCell = [tableView dequeueReusableCellWithIdentifier:@"songCellID"];
    
    if (playerCell==nil) {
        playerCell = [[[NSBundle mainBundle]loadNibNamed:@"PlayerSongsCell" owner:self options:nil] firstObject];
    }
    
    if ([[[arrayLocal objectAtIndex:indexPath.row] valueForKey:@"song"] length] == 0) {
        playerCell.lblArtist.text = [NSString stringWithFormat:@"%@",[[arrayLocal objectAtIndex:indexPath.row] valueForKey:@"artist"]];
    } else {
        playerCell.lblArtist.text = [NSString stringWithFormat:@"%@ - %@",[[arrayLocal objectAtIndex:indexPath.row] valueForKey:@"artist"],[[arrayLocal objectAtIndex:indexPath.row] valueForKey:@"song"]];
    }
    
    //    playerCell.lblArtist.text = [[arrayLocal objectAtIndex:indexPath.row] valueForKey:@"artist"];
    //    playerCell.lblSong.text = [[arrayLocal objectAtIndex:indexPath.row] valueForKey:@"song"];
    //    playerCell.lblSeries.text = [NSString stringWithFormat:@"%ld.", indexPath.row+1];
    
    return playerCell;
}

@end

