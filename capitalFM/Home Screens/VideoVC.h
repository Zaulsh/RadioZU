//
//  VideoVC.h
//  capitalFM
//
//  Created by Sahil garg on 12/04/18.
//  Copyright © 2018 DS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

@interface VideoVC : UIViewController

+ (instancetype)sharedInstance;
@property (strong, nonatomic) IBOutlet UIButton *playPauseButton;
@property (strong, nonatomic) IBOutlet UIVisualEffectView *controlView;
@property (strong, nonatomic) IBOutlet UIVisualEffectView *navigationView;
@property (strong, nonatomic) IBOutlet UIButton *btnShow;
-(IBAction)backAction:(UIButton*)sender;

@end
