//
//  AppDelegate.m
//  capitalFM
//
//  Created by Sahil garg on 08/03/18.
//  Copyright © 2018 DS. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import <RESideMenu/RESideMenu.h>
#import "HomeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "PlayerVC.h"
#import "VideoVC.h"
#import <NYAlertViewController/NYAlertViewController.h>
#import "WebViewController.h"
#import "CustomAlertVC.h"

@interface AppDelegate () <FIRMessagingDelegate>
{
    UIImageView *imageNet;
    NSString *urlString;
}

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) CustomAlertVC *objAlert;

@end

@implementation AppDelegate

+(AppDelegate*)shared {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [FIRApp configure];
    self.ref = [[FIRDatabase database] reference];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
        if(!error)
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                NSUserDefaults *standard = [NSUserDefaults standardUserDefaults];
                if (![standard valueForKey:@"remote"]) {
                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                }
                
                [FIRMessaging messaging].delegate = self;
            });
            
        }
    }];
    
    [[AVAudioSession sharedInstance]setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance]setCategory:AVAudioSessionModeMoviePlayback error:nil];
    [[AVAudioSession sharedInstance]setActive:YES error:nil];
    
    self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    
    self.navigation = [[UINavigationController alloc] initWithRootViewController:[HomeViewController sharedInstance]];
    self.navigation.navigationBar.barStyle = UIBarStyleBlack;
    self.navigation.navigationBar.hidden = YES;
    
    self.navigation.interactivePopGestureRecognizer.enabled = NO;
    
    _leftMenuViewController = [[MenuViewController alloc] init];
    
    // Create side menu controller
    RESideMenu *sideMenuViewController = [[RESideMenu alloc] initWithContentViewController:self.navigation leftMenuViewController:_leftMenuViewController rightMenuViewController:nil];
    
    // Make it a root controller
    self.window.rootViewController = sideMenuViewController;
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
//    [UIApplication sharedApplication].idleTimerDisabled = YES;

    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [application beginReceivingRemoteControlEvents];

    [GLobalRealReachability startNotifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(networkChanged:) name:kRealReachabilityChangedNotification object:nil];
    
    [GLobalRealReachability reachabilityWithBlock:^(ReachabilityStatus status) {
        switch (status)
        {
            case RealStatusNotReachable:
            {
                //  case NotReachable handler
                imageNet = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
                imageNet.image = [UIImage imageNamed:@"LaunchScreen"];
                
                if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    imageNet.contentMode = UIViewContentModeScaleAspectFill;
                } else {
                    imageNet.contentMode = UIViewContentModeScaleAspectFit;
                }
                
                [self.window addSubview:imageNet];
                
                break;
            }
                
            case RealStatusViaWiFi:
            {
                //  case WiFi handler
                break;
            }
                
            case RealStatusViaWWAN:
            {
                //  case WWAN handler
                break;
            }
                
            default:
                break;
        }
    }];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//    [HomeViewController sharedInstance].playerLayer.player = nil;
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    if (self.isVideoPlayer) {
        [_playerGlobal play];
    }
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    [[PlayerVC sharedInstance]setPlayerButton];
    if (self.isVideoPlayer) {
        [_playerGlobal pause];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"notificationVideo" object:nil];
    }
    
//    [HomeViewController sharedInstance].playerLayer.player = _playerGlobal;
}

- (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken {
    NSLog(@"FCM registration token: %@", fcmToken);
    // Notify about received token.
    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:fcmToken forKey:@"token"];
    [[NSNotificationCenter defaultCenter] postNotificationName:
     @"FCMToken" object:nil userInfo:dataDict];
    // TODO: If necessary send token to application server.
    // Note: This callback is fired at each app startup and whenever a new token is generated.
}

// With "FirebaseAppDelegateProxyEnabled": NO
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSUserDefaults *standard =  [NSUserDefaults standardUserDefaults];
    if (![standard objectForKey:@"savedToken"]) {
        NSString * deviceTokenString = [[[[deviceToken description]
                                          stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                         stringByReplacingOccurrencesOfString: @">" withString: @""]
                                        stringByReplacingOccurrencesOfString: @" " withString: @""];
        NSDictionary *dict = @{@"device_name":[[UIDevice currentDevice] localizedModel],@"device_type":@"ios",@"token":deviceTokenString};
        [standard setValue:@"YES" forKey:@"savedToken"];
        [[self.ref childByAutoId] setValue:@{@"token": dict}];
    }
    
    [FIRMessaging messaging].APNSToken = deviceToken;
}
    
-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(nonnull NSError *)error {
    NSLog(@"Error : %@",error.localizedDescription);
}
    
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    NSLog(@"User Info : %@",notification.request.content.userInfo);
    completionHandler(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge);
}
    
//Called to let your app know which action was selected by the user for a given notification.
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler{
    NSDictionary *userInfo = [response.notification.request.content.userInfo valueForKey:@"aps"];
 
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    if (userInfo.allKeys.count==1) {
        [self alertShowSendTitle:[userInfo valueForKey:@"alert"]];
    } else {
        [self alertShowSendTitle:[[userInfo valueForKey:@"alert"]valueForKey:@"body"]];
    }
   
    completionHandler();
}

-(void)alertShowSendTitle:(NSString*)title {
   
    NSError *error = nil;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink
                                                               error:&error];
    NSTextCheckingResult *result = [detector firstMatchInString:title
                                                        options:0
                                                          range:NSMakeRange(0, title.length)];
    
    _objAlert = nil;
    _objAlert = [[CustomAlertVC alloc]init];
    _objAlert.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    if (result.resultType == NSTextCheckingTypeLink)
    {
        urlString = result.URL.absoluteString;
        NSString *stringAddress = title;
        NSMutableAttributedString *attributedAddress = [[NSMutableAttributedString alloc] initWithString:stringAddress];
        [attributedAddress addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:38/255.0f green:52/255.0f blue:81/255.0f alpha:1.0] range:[stringAddress rangeOfString:urlString]];
        [attributedAddress addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"OpenSans-Semibold" size:13.0f] range:[stringAddress rangeOfString:urlString]];
        [_objAlert.btnInfo setAttributedTitle:attributedAddress forState:UIControlStateNormal];
        [_objAlert.btnInfo addTarget:self action:@selector(actionButtonWebLink:) forControlEvents:UIControlEventTouchUpInside];
        [self.window addSubview:_objAlert.view];
    } else {
        [_objAlert.btnInfo setTitle:title forState:UIControlStateNormal];
        [_objAlert.btnInfo setUserInteractionEnabled:NO];
        [self.window addSubview:_objAlert.view];
    }
}

-(void)actionButtonWebLink:(id)sender {
    [_objAlert.view removeFromSuperview];
    WebViewController *objWeb = [[WebViewController alloc]init];
    objWeb.strLink = urlString;
    UINavigationController *navSleepController = [[UINavigationController alloc]initWithRootViewController:objWeb];
    navSleepController.navigationBar.barStyle = UIBarStyleBlack;
    navSleepController.navigationBar.hidden = YES;
    navSleepController.interactivePopGestureRecognizer.enabled = NO;
    [self.window.rootViewController presentViewController:navSleepController animated:YES completion:nil];

}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
    
    
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if ([self.window.rootViewController isKindOfClass: [RESideMenu class]]) {

        RESideMenu *sideMeu = (RESideMenu*)self.window.rootViewController;

        if ([sideMeu.contentViewController isKindOfClass: [UINavigationController class]]) {

            UINavigationController *navControl = (UINavigationController*)sideMeu.contentViewController;
            if ([navControl.topViewController isKindOfClass:[VideoVC class]]) {
                return UIInterfaceOrientationMaskAll;
            } else {
                return UIInterfaceOrientationMaskPortrait;
            }
        } else {
            return UIInterfaceOrientationMaskPortrait;
        }
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}


- (void)networkChanged:(NSNotification *)notification
{
    RealReachability *reachability = (RealReachability *)notification.object;
    ReachabilityStatus status = [reachability currentReachabilityStatus];
  
    self.statusGlobal = status;
    
    [imageNet removeFromSuperview];
    imageNet = nil;
    if (status == RealStatusNotReachable || status == RealStatusUnknown)
    {
        imageNet = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        imageNet.image = [UIImage imageNamed:@"LaunchScreen"];
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            imageNet.contentMode = UIViewContentModeScaleAspectFill;
        } else {
            imageNet.contentMode = UIViewContentModeScaleAspectFit;
        }
        [self.window addSubview:imageNet];
        [self.playerGlobal pause];
        [[PlayerVC sharedInstance]setPlayerButton];
    }
}

-(void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    if (event.type == UIEventTypeRemoteControl) {
        
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlPlay:
                [_playerGlobal play];
                break;
                
            case UIEventSubtypeRemoteControlPause:
                [_playerGlobal pause];
                break;
                
            case UIEventSubtypeRemoteControlPreviousTrack:
                
                break;
                
            case UIEventSubtypeRemoteControlNextTrack:
               
                break;
                
            default:
                break;
        }
    }
}


@end
