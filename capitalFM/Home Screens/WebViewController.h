//
//  WebViewController.h
//  capitalFM
//
//  Created by Sahil garg on 30/06/18.
//  Copyright © 2018 DS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSString *strLink;

@end
