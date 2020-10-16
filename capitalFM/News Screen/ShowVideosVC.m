//
//  ShowVideosVC.m
//  capitalFM
//
//  Created by Sahil garg on 06/07/18.
//  Copyright © 2018 DS. All rights reserved.
//

#import "ShowVideosVC.h"
#import "NewsFeatureTbCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "WebViewController.h"
#import "NSDate+TimeAgo.h"
#import "MBProgressHUD.h"

@interface ShowVideosVC () <UITableViewDelegate, UITableViewDataSource>
{
    int pageCount1;
    IBOutlet UITableView *tbList;
    NSMutableArray *arrayVideo;
}

@end

@implementation ShowVideosVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    pageCount1 = 0;
    arrayVideo = [[NSMutableArray alloc]init];
    tbList.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    [self getVideoList];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)actionbackbtn:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

#pragma mark - UITableView DataSource and Delegates
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return arrayVideo.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        return 300;
    } else {
        return 165;
    }
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == [arrayVideo count] - 1 && arrayVideo.count%10==0) {
        [self getVideoList];
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NewsFeatureTbCell *newsFeatureCell = [tableView dequeueReusableCellWithIdentifier:@"newsFeatureCellID"];
    if (newsFeatureCell == nil) {
        newsFeatureCell = [[[NSBundle mainBundle]loadNibNamed:@"NewsFeatureTbCell" owner:self options:nil] lastObject];
    }
    
    newsFeatureCell.txtTitle.text = [[arrayVideo objectAtIndex:indexPath.row] valueForKey:@"Titlu"];
    
    NSString *strDate = [[arrayVideo objectAtIndex:indexPath.row] valueForKey:@"Data"];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormat dateFromString:strDate];
    newsFeatureCell.lblTime.text = [date timeAgo];

    [newsFeatureCell.newsImage sd_setImageWithURL:[NSURL URLWithString:[[arrayVideo objectAtIndex:indexPath.item] valueForKey:@"Poza"]] placeholderImage:[UIImage imageNamed:@"logo"]];
    newsFeatureCell.btnPlay.hidden = NO;
    newsFeatureCell.selectionStyle = UITableViewCellSelectionStyleNone;
    newsFeatureCell.btnLink.hidden = YES;
    return newsFeatureCell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WebViewController *objWeb = [[WebViewController alloc]init];
    objWeb.strLink = [[arrayVideo objectAtIndex:indexPath.row] valueForKey:@"Url"];
    [self.navigationController pushViewController:objWeb animated:true];
}

#pragma mark - API Methods
- (void)getVideoList {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:true];
    
    NSString *strUrl2 = [NSString stringWithFormat:@"http://romanticfm.ro/api/stiri?tag=zumobile&_page=%d",pageCount1];
    [[[NSURLSession sharedSession]dataTaskWithURL:[NSURL URLWithString:strUrl2] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:true];
        });
        
        if (!error) {
            if (data != nil) {
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                if (json != nil) {
                    if (pageCount1==0) {
                        [arrayVideo removeAllObjects];
                    }
                    pageCount1++;
                    
                    if ([[json objectForKey:@"data"] isKindOfClass:[NSArray class]]) {
                        for (NSDictionary *diction in [json objectForKey:@"data"]) {
                            [arrayVideo addObject:diction];
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [tbList reloadData];
                        });
                    }
                    
                }
            }
        }
        
    }]resume];
    
}

@end
