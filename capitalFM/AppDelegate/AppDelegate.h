//
//  AppDelegate.h
//  capitalFM
//
//  Created by Sahil garg on 08/03/18.
//  Copyright © 2018 DS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <RealReachability/RealReachability.h>
#import "MenuViewController.h"
#import <Firebase/Firebase.h>
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UNUserNotificationCenterDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navigation;
@property (strong, nonatomic) AVPlayer *playerGlobal;
@property (strong, nonatomic) AVPlayerItem *playerItemGlobal;
@property (strong, nonatomic) NSString *strArtistGlobal;
@property (strong, nonatomic) NSString *strSongGlobal;
@property (strong, nonatomic) MenuViewController *leftMenuViewController;
@property (nonatomic) ReachabilityStatus statusGlobal;
@property (nonatomic) BOOL isVideoPlayer;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) BOOL restrictRotation;

+(AppDelegate*)shared;

@end

