//
//  CustomAlertVC.m
//  capitalFM
//
//  Created by Sahil garg on 27/07/18.
//  Copyright © 2018 DS. All rights reserved.
//

#import "CustomAlertVC.h"

@interface CustomAlertVC ()

@end

@implementation CustomAlertVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _objViewAlert.layer.cornerRadius = 10;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)actionOkay:(id)sender {
    [self.view removeFromSuperview];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
