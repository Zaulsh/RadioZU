//
//  PlayerVC.h
//  capitalFM
//
//  Created by Sahil garg on 16/03/18.
//  Copyright © 2018 DS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerVC : UIViewController

+(PlayerVC*)sharedInstance;

@property (nonatomic, strong) IBOutlet UILabel *lblArtist;
@property (nonatomic, strong) IBOutlet UILabel *lblSong;
@property (nonatomic, strong) IBOutlet UIButton *btnPlayPause;
@property (nonatomic, strong) IBOutlet UITableView *tbPlayerSongs;
@property (strong, nonatomic) IBOutlet UIButton *btnScrollUp;

- (void)setPlayerButton;
//- (void)setPlayerButtonForInitialOnly;

@end
