//
//  WebViewController.m
//  capitalFM
//
//  Created by Sahil garg on 30/06/18.
//  Copyright © 2018 DS. All rights reserved.
//

#import "WebViewController.h"
#import "MBProgressHUD.h"
#import <SafariServices/SafariServices.h>

@interface WebViewController () <UIWebViewDelegate>

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated {
    
    _strLink = [_strLink stringByReplacingOccurrencesOfString:@"||_self" withString:@""];
//    _strLink = [_strLink stringByReplacingOccurrencesOfString:@"|_self" withString:@""];
    
    _strLink = [_strLink stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSLog(@"%@",_strLink);
    NSURL *url = [NSURL URLWithString:_strLink];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
}

- (IBAction)backButton:(id)sender {
    
    if([self presentingViewController]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }

}

-(void)webViewDidStartLoad:(UIWebView *)webView {
//    [MBProgressHUD showHUDAddedTo:self.view animated:true];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
//    [MBProgressHUD hideHUDForView:self.view animated:true];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
//    [MBProgressHUD hideHUDForView:self.view animated:true];

//    UIAlertController * alert = [UIAlertController
//                                 alertControllerWithTitle:@""
//                                 message:[error localizedDescription]
//                                 preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction* noButton = [UIAlertAction
//                               actionWithTitle:@"OK"
//                               style:UIAlertActionStyleDefault
//                               handler:^(UIAlertAction * action) {
//                                   
//                               }];
//    [alert addAction:noButton];
//    
//    [self presentViewController:alert animated:YES completion:nil];

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
