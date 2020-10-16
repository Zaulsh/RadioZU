//
//  HomeViewController.h
//  capitalFM
//
//  Created by Sahil garg on 13/03/18.
//  Copyright © 2018 DS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

@interface HomeViewController : UIViewController

+ (instancetype)sharedInstance;

@property(strong,nonatomic) AVPlayerLayer *playerLayer;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollHeader;

- (IBAction)sideMenuAction:(id)sender;
- (void)actionSocialAccounts:(NSString*)link;

@property (weak, nonatomic) IBOutlet UIImageView *imgAvatarBig;

@end
