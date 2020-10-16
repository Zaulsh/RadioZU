//
//  NewsVC.m
//  capitalFM
//
//  Created by Sahil garg on 17/03/18.
//  Copyright © 2018 DS. All rights reserved.
//

#import "NewsVC.h"
#import <RESideMenu/RESideMenu.h>
#import <iCarousel/iCarousel.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "PlayerVC.h"
#import "AppDelegate.h"
#import "NewsVideoTbCell.h"
#import "NewsFeatureTbCell.h"
#import "WebViewController.h"
#import "ShowVideosVC.h"
#import "NSDate+TimeAgo.h"
#import "MBProgressHUD.h"

@interface NewsVC () <UIScrollViewDelegate, UITableViewDataSource,UITableViewDelegate, UITabBarDelegate,iCarouselDataSource,iCarouselDelegate>
{
    IBOutlet UIView *headerView;
    IBOutlet UIPageControl *pageControl;
    
    IBOutlet UITableView *tbList;
    
    NSMutableArray *arrayCarousal;
//    NSMutableArray *arrayVideo;
    NSMutableArray *arrayNews;
    
    IBOutlet iCarousel *carousal;
    
    int pageCount2;
    int pageCount1;
}

@property (nonatomic,strong) PlayerVC *playerView;

@end

@implementation NewsVC

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    pageCount1 = 1;
    pageCount2 = 1;
    
    arrayCarousal = [[NSMutableArray alloc]init];
//    arrayVideo = [[NSMutableArray alloc]init];
    arrayNews = [[NSMutableArray alloc]init];
    
    carousal.type = iCarouselTypeLinear;
    carousal.pagingEnabled = YES;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        headerView.frame = CGRectMake(0, 0, tbList.frame.size.width, 640);
    } else {
        headerView.frame = CGRectMake(0, 0, tbList.frame.size.width, 320);
    }
    
    tbList.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    tbList.tableHeaderView = headerView;
    
    pageControl.numberOfPages = 2;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated {
    
    _playerView = [PlayerVC sharedInstance];
    _playerView.view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 70, [UIScreen mainScreen].bounds.size.width, 400);
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        _playerView.view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 120, [UIScreen mainScreen].bounds.size.width, 600);
    }
    
    [_playerView.tbPlayerSongs reloadData];
    [_playerView.btnScrollUp removeTarget:nil  action:NULL forControlEvents:UIControlEventTouchUpInside];
    [_playerView.btnScrollUp addTarget:self action:@selector(actionShowAll:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_playerView.view];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.playerView.btnScrollUp addGestureRecognizer:pan];
    
    _playerView.lblArtist.text = [AppDelegate shared].strArtistGlobal;
    _playerView.lblSong.text =  [AppDelegate shared].strSongGlobal;
    [_playerView setPlayerButton];
    
    [self getSliderDataFromAPI];
//    [self getVideoList];
    [self getNewsFromAPI];
    
}

-(void)actionShowAll:(id)sender {
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        if (_playerView.view.frame.origin.y == [UIScreen mainScreen].bounds.size.height - 120) {
            _playerView.view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 600, [UIScreen mainScreen].bounds.size.width, 600);
            [_playerView.tbPlayerSongs reloadData];
        } else {
            _playerView.view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 120, [UIScreen mainScreen].bounds.size.width, 600);
        }
        
    } else {
        
        if (_playerView.view.frame.origin.y == [UIScreen mainScreen].bounds.size.height -70) {
            _playerView.view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height -400, [UIScreen mainScreen].bounds.size.width, 400);
            [_playerView.tbPlayerSongs reloadData];
        } else {
            _playerView.view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 70, [UIScreen mainScreen].bounds.size.width, 400);
        }
        
    }
    
}

- (IBAction)sideMenuAction:(id)sender {
    [self.sideMenuViewController presentLeftMenuViewController];
}

#pragma mark - iCarousel methods
-(NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return arrayCarousal.count;
}

- (UIView *)carousel:(__unused iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    UILabel *label = nil;
    UIImageView *viewImage = nil;
    //create new view if no view is available for recycling
    if (view == nil)
    {
        view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, headerView.frame.size.width, headerView.frame.size.height)];
        view.backgroundColor = [UIColor whiteColor];
        
        viewImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
        viewImage.tag = 1;
        viewImage.contentMode = UIViewContentModeScaleAspectFill;
        [viewImage setClipsToBounds:YES];
        [view addSubview:viewImage];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width,view.frame.size.height)];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
             label.font = [label.font fontWithSize:36.0f];
        } else {
             label.font = [label.font fontWithSize:18.0f];
        }
       
        label.numberOfLines = 0;
        label.tag = 2;
        [view addSubview:label];
        
    }
    else
    {
        //get a reference to the label in the recycled view
        viewImage = (UIImageView*)[view viewWithTag:1];
        label = (UILabel *)[view viewWithTag:2];
    }
    
    NSString *htmlString = [[arrayCarousal objectAtIndex:index] valueForKey:@"Titlu"];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    
    label.text = htmlString;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    
    CGFloat newHeight = [label.text boundingRectWithSize:CGSizeMake(label.frame.size.width, MAXFLOAT)
                                   options:NSStringDrawingUsesLineFragmentOrigin
                                attributes:@{
                                             NSFontAttributeName : label.font
                                             }
                                   context:nil].size.height;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        label.frame = CGRectMake(0, view.frame.size.height - newHeight - 70, view.frame.size.width, newHeight);
    } else {
        label.frame = CGRectMake(0, view.frame.size.height - newHeight - 40, view.frame.size.width, newHeight);
    }
    
    label.layer.shadowColor = [UIColor blackColor].CGColor;
    label.layer.shadowRadius = 2.0f;
    label.layer.shadowOpacity = 0.5f;
    label.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    
    [viewImage sd_setImageWithURL:[NSURL URLWithString:[[arrayCarousal objectAtIndex:index] valueForKey:@"Poza"]]];
    
    return view;
}

-(void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel {
    pageControl.currentPage = carousal.currentItemIndex;
}

-(void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
//    NSLog(@"%@",[[arrayCarousal objectAtIndex:index] valueForKey:@"Link"]);
    [self actionWebView:[[arrayCarousal objectAtIndex:index]valueForKey:@"Link"]];
}

#pragma mark - Pan Gesture
-(void) handlePan:(UIPanGestureRecognizer*)panGes{
    
    if (panGes.state == UIGestureRecognizerStateEnded) {
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            
            __weak typeof(self) weakSelf = self;
            
            CGPoint velocity = [panGes velocityInView:self.playerView.btnScrollUp];
            
            if (velocity.y > 0) {
                [UIView animateWithDuration:0.0 animations:^{
                    weakSelf.playerView.view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-600, weakSelf.playerView.view.frame.size.width, 600);
                }];
            } else {
                [UIView animateWithDuration:0.0 animations:^{
                    weakSelf.playerView.view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-120, weakSelf.playerView.view.frame.size.width, 600);
                }];
            }
            
        } else {
            
            __weak typeof(self) weakSelf = self;
            
            CGPoint velocity = [panGes velocityInView:self.playerView.btnScrollUp];
            
            if (velocity.y > 0) {
                [UIView animateWithDuration:0.0 animations:^{
                    weakSelf.playerView.view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-70, weakSelf.playerView.view.frame.size.width, 400);
                }];
            } else {
                [UIView animateWithDuration:0.0 animations:^{
                    weakSelf.playerView.view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-400, weakSelf.playerView.view.frame.size.width, 400);
                }];
            }
            
            
        }
        
    } else {
        
        CGPoint point = [panGes locationInView:self.view];
        CGRect newframe = CGRectMake(0, point.y, _playerView.view.frame.size.width, _playerView.view.frame.size.height);
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            
            if (newframe.origin.y<[UIScreen mainScreen].bounds.size.height-600) {
                newframe = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-600, _playerView.view.frame.size.width, 600);
            }
            
            if (newframe.origin.y>[UIScreen mainScreen].bounds.size.height-120) {
                newframe = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-120, _playerView.view.frame.size.width, 600);
            }
            
        } else {
            
            if (newframe.origin.y<[UIScreen mainScreen].bounds.size.height-400) {
                newframe = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-400, _playerView.view.frame.size.width, 400);
            }
            
            if (newframe.origin.y>[UIScreen mainScreen].bounds.size.height-70) {
                newframe = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-70, _playerView.view.frame.size.width, 400);
            }
            
        }
        
        CGPoint vel = [panGes velocityInView:self.playerView.btnScrollUp];
        if (vel.y > 0) {
            _playerView.view.frame = newframe;
        } else {
            _playerView.view.frame = newframe;
        }
        
    }
    
}

#pragma mark - UITableview DataSources
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
 
    if (section == 1) {
        return 1;
    }
    
    if (section == 0) {
        return arrayNews.count;;
    }
    
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            return 600;
        } else {
            return 340;
        }
    }
    
    if (indexPath.section == 0) {
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            return 300;
        } else {
            return 165;
        }
    }
    
    return 1;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section==1) {
        
        NewsVideoTbCell *newsVideoCell = [tableView dequeueReusableCellWithIdentifier:@"newsVideoCellId"];
        
        if (newsVideoCell == nil) {
            newsVideoCell = [[[NSBundle mainBundle]loadNibNamed:@"NewsVideoTbCell" owner:self options:nil] lastObject];
        }
        
//        newsVideoCell.arrayCollection = arrayVideo;
        newsVideoCell.collectionVideos.dataSource = newsVideoCell;
        newsVideoCell.collectionVideos.delegate = newsVideoCell;
        [newsVideoCell.collectionVideos reloadData];
        [newsVideoCell.btnSeeAll addTarget:self action:@selector(actionShowList:) forControlEvents:UIControlEventTouchUpInside];
        __weak typeof(self) weakSelf = self;
        
//        newsVideoCell.loadMore = ^{
//            [weakSelf getVideoList];
//        };
        
//        newsVideoCell.clickedCell = ^(NSInteger cellIndex) {
////            NSLog(@"%@", [[arrayVideo objectAtIndex:cellIndex] valueForKey:@"Url"]);
//            [weakSelf actionWebView:[[arrayVideo objectAtIndex:cellIndex]valueForKey:@"Url"]];
//        };
        return newsVideoCell;
        
    } else {
        
        NewsFeatureTbCell *newsFeatureCell = [tableView dequeueReusableCellWithIdentifier:@"newsFeatureCellID"];
        if (newsFeatureCell == nil) {
            newsFeatureCell = [[[NSBundle mainBundle]loadNibNamed:@"NewsFeatureTbCell" owner:self options:nil] lastObject];
        }
        newsFeatureCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        newsFeatureCell.txtTitle.text = [[arrayNews objectAtIndex:indexPath.row] valueForKey:@"Titlu"];
        NSString *strDate = [[arrayNews objectAtIndex:indexPath.row] valueForKey:@"Data"];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *date = [dateFormat dateFromString:strDate];
        newsFeatureCell.lblTime.text = [date timeAgo];
        
        [newsFeatureCell.newsImage sd_setImageWithURL:[NSURL URLWithString:[[arrayNews objectAtIndex:indexPath.item] valueForKey:@"Poza"]] placeholderImage:[UIImage imageNamed:@"logo"]];
        newsFeatureCell.btnLink.hidden = NO;
        newsFeatureCell.btnLink.tag = indexPath.row;
        [newsFeatureCell.btnLink addTarget:self action:@selector(actionLink:) forControlEvents:UIControlEventTouchUpInside];
        
        return newsFeatureCell;
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

//    if (section==0) {
//
//        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
//            return 80;
//        } else {
//            return 50;
//        }
//    }

    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
   
    if (section==0) {
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            return 120;
        } else {
            return 80;
        }
    }
    
    return 1;
}

//-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//
//    if (section==0) {
//
//        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//
//            UIView *viewHeader = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tbList.frame.size.width, 80)];
//            viewHeader.backgroundColor = [UIColor lightGrayColor];
//
//            UILabel *lblTile = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, viewHeader.frame.size.width-15, 40)];
//            lblTile.text = @"Mai multe";
//            lblTile.font = [UIFont systemFontOfSize:30.0f];
//            lblTile.textColor = [UIColor colorWithRed:38/255.0f green:52/255.0f blue:81/255.0f alpha:1.0];
//            //        lblTile.backgroundColor = [UIColor lightGrayColor];
//            [viewHeader addSubview:lblTile];
//
//            return viewHeader;
//            
//        } else {
//            UIView *viewHeader = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tbList.frame.size.width, 50)];
//            viewHeader.backgroundColor = [UIColor lightGrayColor];
//
//            UILabel *lblTile = [[UILabel alloc]initWithFrame:CGRectMake(10, 15, viewHeader.frame.size.width-15, 20)];
//            lblTile.text = @"Mai multe";
//            lblTile.font = [UIFont systemFontOfSize:15.0f];
//            lblTile.textColor = [UIColor colorWithRed:38/255.0f green:52/255.0f blue:81/255.0f alpha:1.0];
//            [viewHeader addSubview:lblTile];
//
//            return viewHeader;
//        }
//
//    }
//
//    return [[UIView alloc]initWithFrame:CGRectZero];
//}

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
   
    if (section==0) {
      
        UIButton *btnMore = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, tbList.frame.size.width, 80)];
        btnMore.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:20.0];
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            btnMore.frame = CGRectMake(0, 0, tbList.frame.size.width, 120);
            btnMore.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:40.0];
        }
        
//        UIButton *btnMore = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, tbList.frame.size.width, 90)];
        [btnMore setBackgroundColor:[UIColor colorWithRed:235/255.0f green:235/255.0f blue:235/255.0f alpha:1.0]];
        [btnMore setTitle:@"Mai multe" forState:UIControlStateNormal];
        [btnMore setTitleColor:[UIColor colorWithRed:38/255.0f green:52/255.0f blue:81/255.0f alpha:1.0] forState:UIControlStateNormal];
        [btnMore addTarget:self action:@selector(actionMore:) forControlEvents:UIControlEventTouchUpInside];
        
        return btnMore;
    }
    
    return [[UIView alloc]initWithFrame:CGRectZero];
}

#pragma mark - Actions  Buttons
-(void)actionShowList:(UIButton*)sender {
    ShowVideosVC *objShow = [[ShowVideosVC alloc]init];
    [self.navigationController pushViewController:objShow animated:YES];
}

-(void) actionLink:(UIButton*)sender {
    [self actionWebView:[[arrayNews objectAtIndex:sender.tag] valueForKey:@"Url"]];
}

-(void)actionWebView:(NSString*)link {
    WebViewController *objWeb = [[WebViewController alloc]init];
    objWeb.strLink = link;
    [self.navigationController pushViewController:objWeb animated:true];
}

#pragma mark - Pagination
-(void)actionMore:(UIButton*)sender {
    if (arrayNews.count%10 == 0) {
        [MBProgressHUD showHUDAddedTo:self.view animated:true];
        [self getNewsFromAPI];
    }
}

#pragma mark - APIS
- (void)getNewsFromAPI {
    
    NSString *strUrl2 = [NSString stringWithFormat:@"http://romanticfm.ro/api/noutati?_per_page=10&_page=%d",2];
//    NSString *strUrl2 = [NSString stringWithFormat:@"http://romanticfm.ro/api/noutati_per_page=10&_page=%d",pageCount2];
    [[[NSURLSession sharedSession]dataTaskWithURL:[NSURL URLWithString:strUrl2] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:true];
        });
        
        if (error) {
            
        } else {
            if (data != nil) {
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                if (json != nil) {
                    if (pageCount2==0) {
                        [arrayNews removeAllObjects];
                    }
                    pageCount2++;
                    
                    if ([[json objectForKey:@"data"] isKindOfClass:[NSArray class]]) {
                        for (NSDictionary *diction in [json objectForKey:@"data"]) {
                            [arrayNews addObject:diction];
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

- (void)getSliderDataFromAPI {
    [[[NSURLSession sharedSession]dataTaskWithURL:[NSURL URLWithString:@"http://romanticfm.ro/api/slider"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            
        } else {
            if (data != nil) {
                NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                if (json != nil) {
                    
                    [arrayCarousal removeAllObjects];
                    for (NSDictionary *diction in json) {
                        [arrayCarousal addObject:diction];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        pageControl.numberOfPages = arrayCarousal.count;
                        [carousal reloadData];
                    });
                    
                }
            }
        }
        
    }]resume];
}

//- (void)getVideoList {
//
//    NSString *strUrl2 = [NSString stringWithFormat:@"https://radiozu.ro/api/stiri?tag=zumobile&_page=%d",pageCount1];
//    [[[NSURLSession sharedSession]dataTaskWithURL:[NSURL URLWithString:strUrl2] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//
//        if (error) {
//
//        } else {
//            if (data != nil) {
//                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
//                if (json != nil) {
//                    if (pageCount1==0) {
//                        [arrayVideo removeAllObjects];
//                    }
//                    pageCount1++;
//
//                    if ([[json objectForKey:@"data"] isKindOfClass:[NSArray class]]) {
//                        for (NSDictionary *diction in [json objectForKey:@"data"]) {
//                            [arrayVideo addObject:diction];
//                        }
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            [tbList reloadData];
//                        });
//                    }
//
//                }
//            }
//        }
//
//    }]resume];
//}

@end
