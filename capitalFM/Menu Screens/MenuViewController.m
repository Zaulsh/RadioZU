//
//  MenuViewController.m
//  capitalFM
//
//  Created by Sahil garg on 09/03/18.
//  Copyright © 2018 DS. All rights reserved.
//

#import "MenuViewController.h"
#import "MenuTbCell.h"
#import <RESideMenu/RESideMenu.h>
#import "SleepTimerVC.h"
#import "HomeViewController.h"
#import "AppDelegate.h"
#import "NewsVC.h"
#import "WebViewController.h"
#import <UserNotifications/UserNotifications.h>

@interface MenuViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *arrayMenu;
    NSMutableArray *arrayImage;
    
    SleepTimerVC *objSleep;
    NewsVC *objNews;
    HomeViewController *objHome;
    
    IBOutlet UIView *footerView;
}

@end

@implementation MenuViewController
@synthesize menuTable;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        menuTable.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, menuTable.frame.size.width, 150)];
    } else {
        menuTable.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, menuTable.frame.size.width, 75)];
    }
    
    
    menuTable.tableFooterView = footerView;
  
    arrayMenu = [[NSMutableArray alloc]init];
    arrayImage = [[NSMutableArray alloc]init];
    
    objSleep = [[SleepTimerVC alloc]init];
    objNews = [[NewsVC alloc]init];
    
//    objHome = [[HomeViewController alloc]init];
    
    [arrayMenu addObject:@"Ascultă Romantic FM"];
    [arrayMenu addObject:@"Știri"];
//    [arrayMenu addObject:@"Tools & Settings"];
    [arrayMenu addObject:@"Oprire Programată"];
    [arrayMenu addObject:@"Notificări"];
//    [arrayMenu addObject:@"Logout"];
    
    [arrayImage addObject:@"video_icon"];
    [arrayImage addObject:@""];
    [arrayImage addObject:@""];
    [arrayImage addObject:@""];
//    [arrayImage addObject:@""];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
         return 90.0;
    } else {
         return 45.0;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return arrayMenu.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"menuCellId";
    MenuTbCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // NOTE: Add some code like this to create a new cell if there are none to reuse
    if(cell == nil)
    {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"MenuTbCell" owner:self options:nil] firstObject];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.lblSide.text = arrayMenu[indexPath.row];
    cell.lblSide.textColor = [UIColor whiteColor];
    
    [cell.imgSide setImage:[UIImage imageNamed:[arrayImage objectAtIndex:indexPath.row]]];
    
    if (indexPath.row==3) {
        
        if([[UIApplication sharedApplication] isRegisteredForRemoteNotifications]) {
            [cell.notifySwitch setOn:YES];
        } else {
            [cell.notifySwitch setOn:NO];
        }
        
        cell.notifySwitch.hidden = NO;
        [cell.notifySwitch addTarget:self action:@selector(actionSwitchChanged:) forControlEvents:UIControlEventTouchUpInside];
        
    } else {
        cell.notifySwitch.hidden = YES;
    }
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        cell.notifySwitch.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.5, 1.5);
    }
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        [self.sideMenuViewController setContentViewController:[HomeViewController sharedInstance] animated:YES];
        [self.sideMenuViewController hideMenuViewController];
    }

    if (indexPath.row == 1) {
        UINavigationController *navSleepController = [[UINavigationController alloc]initWithRootViewController:objNews];
        navSleepController.navigationBar.barStyle = UIBarStyleBlack;
        navSleepController.navigationBar.hidden = YES;
        navSleepController.interactivePopGestureRecognizer.enabled = NO;
        
        [self.sideMenuViewController setContentViewController:navSleepController animated:YES];
        [self.sideMenuViewController hideMenuViewController];
    }
    
    if (indexPath.row == 2) {
        UINavigationController *navSleepController = [[UINavigationController alloc]initWithRootViewController:objSleep];
        navSleepController.navigationBar.barStyle = UIBarStyleBlack;
        navSleepController.navigationBar.hidden = YES;
        navSleepController.interactivePopGestureRecognizer.enabled = NO;
        
        [self.sideMenuViewController setContentViewController:navSleepController animated:YES];
        [self.sideMenuViewController hideMenuViewController];
    }
    
}

- (IBAction)actionFbOpen:(id)sender {

    [self.sideMenuViewController setContentViewController:[HomeViewController sharedInstance] animated:YES];
    [self.sideMenuViewController hideMenuViewController];
    [[HomeViewController sharedInstance] actionSocialAccounts:@"https://www.facebook.com/RomanticFM/"];
    
}

- (IBAction)actionYouTubeOpen:(id)sender {
    
    [self.sideMenuViewController setContentViewController:[HomeViewController sharedInstance] animated:YES];
    [self.sideMenuViewController hideMenuViewController];
    [[HomeViewController sharedInstance] actionSocialAccounts:@"https://www.youtube.com/user/videozufm"];
    
}

- (IBAction)actionInstaOpen:(id)sender {
    
    [self.sideMenuViewController setContentViewController:[HomeViewController sharedInstance] animated:YES];
    [self.sideMenuViewController hideMenuViewController];
    [[HomeViewController sharedInstance] actionSocialAccounts:@"http://www.instagram.com/romanticfm/"];
    
}
    
-(void)actionSwitchChanged:(UISwitch*)sender {
    
    NSUserDefaults *standard = [NSUserDefaults standardUserDefaults];
    if (sender.isOn) {
        [standard removeObjectForKey:@"remote"];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        [standard setValue:@"unregister" forKey:@"remote"];
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    }
    
}
    
@end

