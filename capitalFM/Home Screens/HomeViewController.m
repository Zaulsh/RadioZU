//
//  HomeViewController.m
//  capitalFM
//
//  Created by Sahil garg on 13/03/18.
//  Copyright © 2018 DS. All rights reserved.
//

#import "HomeViewController.h"
#import <RESideMenu/RESideMenu.h>
#import <MediaPlayer/MediaPlayer.h>
#import "HomeTbCell.h"
#import "PlayerVC.h"
#import "AppDelegate.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <PocketSVG/PocketSVG.h>
#import "VideoVC.h"
#import "HomeNewsCell.h"
#import "WebViewController.h"

@interface HomeViewController () <UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
{
    NSMutableArray *arrayList;
    
    NSMutableArray *arrrayNextSongs;
    IBOutlet UITableView *tbList;
    
    IBOutlet UIView *viewHeader;
    IBOutlet UIImageView *audioAlbum;
    IBOutlet UIImageView *audioFadeAlbum;
    
    __weak IBOutlet UIImageView *imageLive;
    IBOutlet UIButton *btnToggle;
    
    BOOL isPlayingAudio;
    SVGImageView *svgImageView;
    
    IBOutlet UIView *viewDj;
    IBOutlet UIView *viewDjInfo;
    IBOutlet UIButton *btnOnAir;
    IBOutlet UIImageView *imgDj;
    IBOutlet UIImageView *imgFadeDj;
    IBOutlet UILabel *nameDj;
    IBOutlet UILabel *lblTime;
    
    IBOutlet UICollectionView *objCollection;
    
    MPNowPlayingInfoCenter *infoCenter;
    NSMutableArray *arrayNews;
    
    NSTimer *timerCheck;
}

@property (nonatomic,strong) PlayerVC *playerView;
@property (weak, nonatomic) IBOutlet UIImageView *imgLogo;

@end

@implementation HomeViewController
@synthesize playerLayer;

+ (instancetype)sharedInstance
{
    static HomeViewController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HomeViewController alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    arrrayNextSongs = [[NSMutableArray alloc]init];
    
    arrayList = [[NSMutableArray alloc]init];
    arrayNews = [[NSMutableArray alloc]init];
    
//    viewHeader.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width*0.63);
//
//    if ([UIScreen mainScreen].bounds.size.height == 568) {
//        viewHeader.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width*0.43);
//    }
//
//    if ([UIScreen mainScreen].bounds.size.height == 667) {
//        viewHeader.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width*0.63);
//    }
//
//    if ([UIScreen mainScreen].bounds.size.height == 736) {
//        viewHeader.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width*0.74);
//    }
//
//    if ([UIScreen mainScreen].bounds.size.height == 812) {
//        viewHeader.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width);
//    }
//
//    if ([UIScreen mainScreen].bounds.size.height >= 1024) {
//        viewHeader.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width*0.63);
//    }
    
//    tbList.tableHeaderView = viewHeader;
    tbList.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    
    _playerView = [PlayerVC sharedInstance];
    
    _playerView.view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height -70, [UIScreen mainScreen].bounds.size.width, 400);
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        _playerView.view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 120, [UIScreen mainScreen].bounds.size.width, 600);
    }
    
    [AppDelegate shared].strArtistGlobal = @"Muzică, nu zgomot";
    _playerView.lblArtist.text = @"Muzică, nu zgomot";
    [_playerView.tbPlayerSongs reloadData];
    [_playerView.btnScrollUp removeTarget:nil  action:NULL forControlEvents:UIControlEventTouchUpInside];
    [_playerView.btnScrollUp addTarget:self action:@selector(actionShowAll:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_playerView.view];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.playerView.btnScrollUp addGestureRecognizer:pan];
//    http://stream.radiozu.ro:9123/radiozumobile.aacp
//    http://5.254.113.34:9123/radiozu.aacp
    [arrayList addObject:@{
                           @"Type": @"Audio",
                           @"Title": @"Audio",
                           @"Artist": @"artist audio",
                           @"Link": @"http://live.romanticfm.ro:9123/rfmmobile.aacp"
                           }];
    
    [arrayList addObject:@{
                           @"Type": @"Video",
                           @"Title": @"Video",
                           @"Artist": @"artist video",
                           @"Link": @"https://play.myovn.com/s1/cache/radiozu/playlist.m3u8"
                           }];
    
    //    http://5.254.113.34:1935/shoutcast/radiozu.stream/playlist.m3u8
    
    [objCollection registerClass:[HomeNewsCell class] forCellWithReuseIdentifier:@"HomeNewsCellID"];
    [objCollection registerNib:[UINib nibWithNibName:@"HomeNewsCell" bundle:nil] forCellWithReuseIdentifier:@"HomeNewsCellID"];
    
    NSString *audioUrl = [[arrayList firstObject] valueForKey:@"Link"];
    isPlayingAudio = YES;
    
    _scrollHeader.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width*2, [UIScreen mainScreen].bounds.size.width*0.9);
    [self playAudio:audioUrl];
    
    NSOperationQueue *myOQ = [[NSOperationQueue alloc] init];
    
    __weak typeof(self) weakSelf = self;
    
    NSBlockOperation *firstOperation = [NSBlockOperation blockOperationWithBlock:^{
        [weakSelf checkNextSongs];
    }];
    
    NSBlockOperation *secOperation = [NSBlockOperation blockOperationWithBlock:^{
        [weakSelf loadDataForCurrentSong];
    }];
    
    NSBlockOperation *thdOperation = [NSBlockOperation blockOperationWithBlock:^{
        [weakSelf getPreviousSongs];
    }];
    
    NSBlockOperation *forthOperation = [NSBlockOperation blockOperationWithBlock:^{
        [weakSelf getNews];
    }];
    
    [myOQ addOperation:firstOperation];
    [myOQ addOperation:secOperation];
    [myOQ addOperation:thdOperation];
    [myOQ addOperation:forthOperation];
    
    [myOQ setMaxConcurrentOperationCount:4];

}

-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:YES];
    
    if (![self.view.subviews containsObject:_playerView.view]) {
        
        _playerView = [PlayerVC sharedInstance];
        _playerView.view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height -70, [UIScreen mainScreen].bounds.size.width, 400);
       
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            _playerView.view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 120, [UIScreen mainScreen].bounds.size.width, 600);
        }
        
        [_playerView.btnScrollUp removeTarget:nil  action:NULL forControlEvents:UIControlEventTouchUpInside];
        [_playerView.btnScrollUp addTarget:self action:@selector(actionShowAll:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_playerView.view];
     
        _playerView.lblArtist.text = [AppDelegate shared].strArtistGlobal;
        _playerView.lblSong.text =  [AppDelegate shared].strSongGlobal;
        [_playerView setPlayerButton];
    }
   
    [[UIApplication sharedApplication]supportedInterfaceOrientationsForWindow:[AppDelegate shared].window];
    [_playerView setPlayerButton];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden {
    return NO;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Play Audio
- (void)playAudio:(NSString *)audioUrl {
    
    [btnToggle setImage:[UIImage imageNamed:@"Live_Video_Icon"] forState:UIControlStateNormal];

    audioAlbum.hidden = NO;
    
    playerLayer.player = nil;
    [playerLayer removeFromSuperlayer];
    playerLayer = nil;
    
    [AppDelegate shared].playerGlobal = playerLayer.player;
    __weak typeof(self) weakSelf = self;
    
    AVPlayerItem* playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:audioUrl]];
    [AppDelegate shared].playerItemGlobal = playerItem;
    [[AppDelegate shared].playerItemGlobal addObserver:self forKeyPath:@"timedMetadata" options:NSKeyValueObservingOptionPrior context:nil];
    
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    
    // create a player view controller
    playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.frame = CGRectMake(0, 0, 1, 1);
    playerLayer.backgroundColor = [UIColor whiteColor].CGColor;
    playerLayer.hidden = YES;
    [self.view.layer addSublayer:playerLayer];
    [player play];
   
    [AppDelegate shared].playerGlobal = player;
    [[AppDelegate shared].playerGlobal addObserver:self forKeyPath:@"status" options:0 context:nil];
    
//    [viewHeader bringSubviewToFront:btnToggle];
//    [viewHeader bringSubviewToFront:imageLive];
    
    [self setNowPlayinfInfo:@"logo_icon"];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.playerView setPlayerButton];
    });
    
}

#pragma mark - Play Video
- (void)playVideo:(NSString *)videoUrl {
    
    [playerLayer.player pause];
    [[PlayerVC sharedInstance]setPlayerButton];
    [AppDelegate shared].playerGlobal = playerLayer.player;
    
    VideoVC *objVideo = [[VideoVC alloc]init];
    [self.navigationController pushViewController:objVideo animated:YES];
    
}

#pragma mark - Setup OuterPlayer Controller
-(void)setNowPlayinfInfo:(NSString*)imageString {
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
    
    UIImage *artworkImage = [UIImage imageNamed:imageString];
    
    artworkImage = [self resizeImageWithImage:artworkImage scaledToSize:CGSizeMake(100, 100)];

    MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc]  initWithBoundsSize:CGSizeMake(100, 100) requestHandler:^UIImage * _Nonnull(CGSize size) {
        return artworkImage;
    }];
    
    [dictionary setValue:albumArt forKey:MPMediaItemPropertyArtwork];
    
    [dictionary setValue:[AppDelegate shared].strArtistGlobal forKey:MPMediaItemPropertyTitle];
    
    infoCenter = [MPNowPlayingInfoCenter defaultCenter];
    infoCenter.nowPlayingInfo = dictionary;
    
}

- (UIImage *)resizeImageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - Show Previous Songs List
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
        
        _playerView.view.frame = newframe;
        
    }
    
}

#pragma mark - UIButton Methods
- (IBAction)sideMenuAction:(id)sender {
    [[AppDelegate shared].leftMenuViewController.menuTable reloadData];
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (IBAction)actionTogglePlayer:(id)sender {
    [self playVideo:[[arrayList objectAtIndex:1] valueForKey:@"Link"]];
}

#pragma mark - Audio Observer Method
- (void) observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object
                         change:(NSDictionary*)change context:(void*)context {
    
    __weak typeof(self) weakSelf = self;
    
    timerCheck = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(checkStatus) userInfo:nil repeats:YES];
    
    if ([keyPath isEqualToString:@"timedMetadata"])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            AVPlayerItem* playerItem = object;
            
            if (playerItem.timedMetadata.count == 0) {
                _playerView.lblArtist.text = @"ZU";
                _playerView.lblSong.text = @"";
                
                [weakSelf loadImageFromArtist:weakSelf.playerView.lblArtist.text];
            }
            
            for (AVMetadataItem* metadata in playerItem.timedMetadata)
            {
                NSArray *array = [metadata.stringValue componentsSeparatedByString:@"-"];
                if (array.count==1) {
                    _playerView.lblArtist.text = metadata.stringValue;
                    _playerView.lblSong.text = @"";
                } else {
                    _playerView.lblArtist.text = [[metadata.stringValue componentsSeparatedByString:@"-"] firstObject];
                    _playerView.lblSong.text = [[metadata.stringValue componentsSeparatedByString:@"-"] lastObject];
                    
                    //Change Avatar Image
                    NSString* strImage = [[arrrayNextSongs objectAtIndex:0] valueForKey:@"image"];
                    UIImage* avatar;
                    if (strImage.length == 0) {
                        avatar = [UIImage imageNamed:@"upimage"];
                    } else {
                        NSURL *url = [NSURL URLWithString:strImage];
                        NSData *data = [NSData dataWithContentsOfURL:url];
                        avatar = [[UIImage alloc] initWithData:data];
                    }
                    _imgAvatarBig.image = avatar;
                }
            
                [AppDelegate shared].strArtistGlobal = _playerView.lblArtist.text;
                [AppDelegate shared].strSongGlobal = _playerView.lblSong.text;
                
                NSMutableDictionary *playInfo = [NSMutableDictionary dictionaryWithDictionary:[MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo] ;
                
                [playInfo setObject:[AppDelegate shared].strSongGlobal forKey:MPMediaItemPropertyTitle];
                [playInfo setObject:[AppDelegate shared].strArtistGlobal forKey:MPMediaItemPropertyArtist];
                
                [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = playInfo;
                
                NSOperationQueue *myOQ = [[NSOperationQueue alloc] init];
                
                NSBlockOperation *firstOperation = [NSBlockOperation blockOperationWithBlock:^{
                    [weakSelf loadImageFromArtist:weakSelf.playerView.lblArtist.text];
                }];
                [myOQ addOperation:firstOperation];
                [myOQ setMaxConcurrentOperationCount:1];
                
            }
        });
        
    }
}

-(void)checkStatus {
    
    if ([[AppDelegate shared].playerGlobal timeControlStatus] == AVPlayerTimeControlStatusPlaying) {
        [self.playerView setPlayerButton];
        [timerCheck invalidate];
    }
    
}

#pragma mark - API's
-(void)checkNextSongs {
    
    __weak typeof(self) weakSelf = self;

    NSString *url_string = [NSString stringWithFormat:@"http://live.romanticfm.ro/andro/urmatoarea_piesa_rfm.html"];
    
    [[[NSURLSession sharedSession]dataTaskWithURL:[NSURL URLWithString:url_string] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                
                [arrrayNextSongs removeAllObjects];
                
                for (NSDictionary *diction in [[json valueForKey:@"list"] valueForKey:@"songs"])
                {
                    NSMutableDictionary *dictionMut = [diction mutableCopy];
                    [dictionMut setValue:@"" forKey:@"image"];
                    [arrrayNextSongs addObject:dictionMut];
                }
                
                [tbList reloadData];
                [weakSelf.playerView.tbPlayerSongs reloadData];
                
                
                NSOperationQueue *myOQ = [[NSOperationQueue alloc] init];
                
                __weak typeof(self) weakSelf = self;
                
                if (arrrayNextSongs.count > 0) {
                    NSString* strArtist1 = [[arrrayNextSongs objectAtIndex:0] valueForKey:@"artist"];
                    [weakSelf loadImageForFirstSong:strArtist1];
                }
                
                NSBlockOperation *firstOperation = [[NSBlockOperation alloc] init];
                firstOperation = [NSBlockOperation blockOperationWithBlock:^{
                    [myOQ addOperation:firstOperation];
                }];
                
                if (arrrayNextSongs.count > 1) {
                    NSString* strArtist2 = [[arrrayNextSongs objectAtIndex:1] valueForKey:@"artist"];
                    [weakSelf loadImageForSecSong:strArtist2];
                }
                
                NSBlockOperation *secOperation = [[NSBlockOperation alloc] init];
                secOperation = [NSBlockOperation blockOperationWithBlock:^{
                    [myOQ addOperation:secOperation];
                }];
                
                if (arrrayNextSongs.count > 2) {
                    NSString* strArtist3 = [[arrrayNextSongs objectAtIndex:2] valueForKey:@"artist"];
                    [weakSelf loadImageForThrSong:strArtist3];
                }
                
                NSBlockOperation *thrOperation = [[NSBlockOperation alloc] init];
                thrOperation = [NSBlockOperation blockOperationWithBlock:^{
                    [myOQ addOperation:thrOperation];
                }];
                
                [myOQ setMaxConcurrentOperationCount: 3];
            });
        }
    }]resume];
}


-(void)loadImageForFirstSong:(NSString*)artist {
    NSString* strArtist = [artist stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
//    strArtist = @"PERRY%20COMO";
    NSString *url_string = [NSString stringWithFormat:@"http://romanticfm.ro/api/artisti?nume=%@", strArtist];
    
    [[[NSURLSession sharedSession]dataTaskWithURL:[NSURL URLWithString:url_string] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                if (json.count > 0) {
                    NSDictionary *imageJson = [json firstObject];
                    if ([imageJson.allKeys containsObject:@"poza"]) {
                        if (![[imageJson valueForKey:@"poza"] isEqualToString:@""]) {
                            //show image on
                            NSString *imageStr = [imageJson valueForKey:@"poza"];
                            imageStr = [imageStr stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
                            // NSURL *imageURL = [NSURL URLWithString:imageStr];
                            NSMutableDictionary *dict1 =  [arrrayNextSongs firstObject];
                            [dict1 setValue:imageStr forKey:@"image"];
                            [tbList reloadData];
                        }
                    }
                }
            }
        });
    }] resume];
}

-(void)loadImageForSecSong:(NSString*)artist {
    NSString* strArtist = [artist stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
//    strArtist = @"DEMIS%20ROUSSOS";
    NSString *url_string = [NSString stringWithFormat:@"http://romanticfm.ro/api/artisti?nume=%@", strArtist];
    
    [[[NSURLSession sharedSession]dataTaskWithURL:[NSURL URLWithString:url_string] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (!error) {
                NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                if (json.count > 0) {
                    NSDictionary *imageJson = [json firstObject];
                    if ([imageJson.allKeys containsObject:@"poza"]) {
                        if (![[imageJson valueForKey:@"poza"] isEqualToString:@""]) {
                            //show image on
                            NSString *imageStr = [imageJson valueForKey:@"poza"];
                            imageStr = [imageStr stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
//                            NSURL *imageURL = [NSURL URLWithString:imageStr];
                            NSMutableDictionary *dict1 =  [arrrayNextSongs objectAtIndex:1];
                            [dict1 setValue:imageStr forKey:@"image"];
                            [tbList reloadData];
                        }
                    }
                }
            }
            
        });
    }] resume];
    
}

-(void)loadImageForThrSong:(NSString*)artist {
    NSString* strArtist = [artist stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    //    strArtist = @"DEMIS%20ROUSSOS";
    NSString *url_string = [NSString stringWithFormat:@"http://romanticfm.ro/api/artisti?nume=%@", strArtist];
    [[[NSURLSession sharedSession]dataTaskWithURL:[NSURL URLWithString:url_string] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                if (json.count > 0) {
                    NSDictionary *imageJson = [json firstObject];
                    if ([imageJson.allKeys containsObject:@"poza"]) {
                        if (![[imageJson valueForKey:@"poza"] isEqualToString:@""]) {
                            //show image on
                            NSString *imageStr = [imageJson valueForKey:@"poza"];
                            imageStr = [imageStr stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
                            //                            NSURL *imageURL = [NSURL URLWithString:imageStr];
                            NSMutableDictionary *dict1 =  [arrrayNextSongs objectAtIndex:2];
                            [dict1 setValue:imageStr forKey:@"image"];
                            [tbList reloadData];
                        }
                    }
                }
            }
            
        });
    }] resume];
    
}

-(void)loadImageFromArtist:(NSString*)artist {
    __weak typeof(self) weakSelf = self;
    NSString* strArtist = [artist stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
//    strArtist = @"JOE%20COCKER";
    NSString *url_string = [NSString stringWithFormat:@"http://romanticfm.ro/api/artisti?nume=%@", strArtist];
    
    [[[NSURLSession sharedSession]dataTaskWithURL:[NSURL URLWithString:url_string] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [audioAlbum setImage:[UIImage imageNamed:@"sigla zu buna"]];
            audioAlbum.contentMode = UIViewContentModeScaleAspectFit;
            [[AppDelegate shared].leftMenuViewController.imageBg setImage:[UIImage imageNamed:@""]];
            [tbList reloadData];
            
            if (!error) {
                NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                if (json.count > 0) {
                    NSDictionary *imageJson = [json firstObject];
                    if ([imageJson.allKeys containsObject:@"poza"]) {
                        if (![[imageJson valueForKey:@"poza"] isEqualToString:@""]) {
                            //show image on
                            NSString *imageStr = [imageJson valueForKey:@"poza"];
                            imageStr = [imageStr stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
                            NSURL *imageURL = [NSURL URLWithString:imageStr];
                            [audioAlbum sd_setImageWithURL:imageURL];
                            audioAlbum.contentMode = UIViewContentModeScaleAspectFill;
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                UIImage *artworkImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageStr]]];
                                [[AppDelegate shared].leftMenuViewController.imageBg setImage:artworkImage];
                                [tbList reloadData];
                                
                                [_imgLogo setHidden:true];
                            });
                        } else {
                            [_imgLogo setHidden:false];
                        }
                    }
                }
            }            
            [weakSelf loadDataForCurrentSong];
        });
    }] resume];
    
}

-(void)loadDataForCurrentSong {
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"YYYY-dd-MM"];

    __weak typeof(self) weakSelf = self;
    
    NSString *url_string = [NSString stringWithFormat:@"http://romanticfm.ro/api/program?start=%@",[dateFormat stringFromDate:[NSDate date]]];

     [[[NSURLSession sharedSession]dataTaskWithURL:[NSURL URLWithString:url_string] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
         
         dispatch_async(dispatch_get_main_queue(), ^{
             
             btnOnAir.hidden = true;
             viewDjInfo.hidden = true;
             [imgDj setImage:[UIImage imageNamed:@"sigla zu buna"]];
             [weakSelf checkNextSongs];
             imgDj.contentMode = UIViewContentModeScaleAspectFit;
             
             if (!error) {
                 NSMutableArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                 if ([json isKindOfClass:[NSArray class]]) {
                     if (json.count>0) {
                         btnOnAir.hidden = false;
                         viewDjInfo.hidden = false;
                         NSDictionary *dictionDJ = [json firstObject];
                         NSString *strDJImage = [dictionDJ objectForKey:@"poza"];
                         strDJImage = [strDJImage stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
                         [imgDj sd_setImageWithURL:[NSURL URLWithString:strDJImage]];

                         imgDj.contentMode = UIViewContentModeScaleAspectFill;
                         nameDj.text = [dictionDJ valueForKey:@"nume"];
                         
                         NSString *startTime = [dictionDJ valueForKey:@"start"];
                         NSString *endTime = [dictionDJ valueForKey:@"end"];
                         
                         startTime = [startTime substringToIndex:startTime.length-3];
                         endTime = [endTime substringToIndex:endTime.length-3];
                         
                         lblTime.text = [NSString stringWithFormat:@"%@ - %@",startTime,endTime];
                     }
                 }
                 
             }
             
         });

     }] resume];
    
}

-(void)getPreviousSongs {
    
    __weak typeof(self) weakSelf = self;
    
    NSString *url_string = [NSString stringWithFormat:@"http://live.romanticfm.ro/andro/liverfm.php"];
    
    [[[NSURLSession sharedSession]dataTaskWithURL:[NSURL URLWithString:url_string] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            
        } else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                
                if([[json valueForKey:@"success"] boolValue]){
                    
//                    NSMutableArray *arrayLocal = [[[NSUserDefaults standardUserDefaults]valueForKey:@"localArray"] mutableCopy];
                    
                    NSMutableArray *arrayLocal = [[NSMutableArray alloc]init];
                    
                    if (arrayLocal.count==0) {
                        arrayLocal = [[NSMutableArray alloc]init];
                    } else {
                        [arrayLocal removeAllObjects];
                    }
                    
                    if ([[json valueForKey:@"piese"] isKindOfClass:[NSArray class]]) {
                        for (NSDictionary *dict in [json valueForKey:@"piese"]) {
//                            if (![[dict valueForKey:@"piesa"]containsObject:@"PUB"] && ![[dict valueForKey:@"piesa"]containsObject:@"Let's do the ZU"]) {
                            
                            NSString *strArtist = [[[dict valueForKey:@"piesa"] componentsSeparatedByString:@"-"] firstObject];
                            
                            NSString *strSong = [[[dict valueForKey:@"piesa"] componentsSeparatedByString:@"-"] lastObject];
                            
                            if ([strArtist containsString:@"PUB"] || [strArtist containsString:@"Let's do the ZU"]) {
                                [arrayLocal addObject:@{
                                                        @"artist":strArtist,
                                                        @"song":@""
                                                        }];
                            } else {
                                [arrayLocal addObject:@{
                                                        @"artist":strArtist,
                                                        @"song":strSong
                                                        }];
                            }
//                            }
                        }
                    }
                    
                    NSArray *arrayPem = [[NSSet setWithArray:arrayLocal] allObjects];
                    [[NSUserDefaults standardUserDefaults]setObject:arrayPem forKey:@"localArray"];
                }
                [weakSelf.playerView.tbPlayerSongs reloadData];
            });
        }
    }]resume];
    
}

-(void)getNews {
    
//    __weak typeof(self) weakSelf = self;
    
    NSString *url_string = [NSString stringWithFormat:@"http://romanticfm.ro/api/stiri-live"];
    
    [[[NSURLSession sharedSession]dataTaskWithURL:[NSURL URLWithString:url_string] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            
        } else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                
                if([[json valueForKey:@"data"] isKindOfClass:[NSArray class]]){
                    
                    NSMutableArray *arrayLocal = [[NSMutableArray alloc]init];
                    
                    if (arrayLocal.count==0) {
                        arrayLocal = [[NSMutableArray alloc]init];
                    } else {
                        [arrayLocal removeAllObjects];
                    }
                    
                    for (NSDictionary *dict in [json valueForKey:@"data"]) {
                        [arrayLocal addObject:dict];
                    }
                    
                    arrayNews = [arrayLocal mutableCopy];
                }
                
                [objCollection reloadData];
                
            });
            
        }
        
        
    }]resume];
    
}

#pragma mark - UICollectionView DataSources and Delegates
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake([UIScreen mainScreen].bounds.size.width*0.8, collectionView.frame.size.height);
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return arrayNews.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HomeNewsCell *objCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HomeNewsCellID" forIndexPath:indexPath];
    NSDictionary *dictNews = [arrayNews objectAtIndex:indexPath.row];
    
    NSString *strImage = [[dictNews valueForKey:@"poza"] stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    if (strImage.length == 0){
        [objCell.imgNews setImage:[UIImage imageNamed:@"logo"]];
    } else {
        [objCell.imgNews sd_setImageWithURL:[NSURL URLWithString:strImage] placeholderImage:[UIImage imageNamed:@"logo"]];
    }
//    [objCell.imgNews sd_setImageWithURL:[NSURL URLWithString:strImage]];
    objCell.lblNews.text = [dictNews valueForKey:@"titlu"];
    objCell.btn.tag = indexPath.row;
    [objCell.btn addTarget:self action:@selector(actionWebView:) forControlEvents:UIControlEventTouchUpInside];
    
    return objCell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
   
    
}

-(void)actionWebView:(UIButton*)sender {
    WebViewController *objWeb = [[WebViewController alloc]init];
    objWeb.strLink = [[arrayNews objectAtIndex:sender.tag] valueForKey:@"link"];
    UINavigationController *navSleepController = [[UINavigationController alloc]initWithRootViewController:objWeb];
    navSleepController.navigationBar.barStyle = UIBarStyleBlack;
    navSleepController.navigationBar.hidden = YES;
    navSleepController.interactivePopGestureRecognizer.enabled = NO;
    [self presentViewController:navSleepController animated:YES completion:nil];
}

-(void)actionSocialAccounts:(NSString*)link {
    WebViewController *objWeb = [[WebViewController alloc]init];
    objWeb.strLink = link;
    UINavigationController *navSleepController = [[UINavigationController alloc]initWithRootViewController:objWeb];
    navSleepController.navigationBar.barStyle = UIBarStyleBlack;
    navSleepController.navigationBar.hidden = YES;
    navSleepController.interactivePopGestureRecognizer.enabled = NO;
    [self presentViewController:navSleepController animated:YES completion:nil];
}

#pragma mark - UITableview DataSources and Delegates
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        return 140;
    } else {
        return 80;
    }
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return arrrayNextSongs.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HomeTbCell *homeCell = [tableView dequeueReusableCellWithIdentifier:@"homeTbCellId"];
    
    if (homeCell==nil) {
        homeCell = [[[NSBundle mainBundle]loadNibNamed:@"HomeTbCell" owner:self options:nil] firstObject];
    }
    
    homeCell.lblArtist.text = [[arrrayNextSongs objectAtIndex:indexPath.row] valueForKey:@"artist"];
    homeCell.lblSong.text = [[arrrayNextSongs objectAtIndex:indexPath.row] valueForKey:@"song"];
    
    homeCell.next.hidden = NO;
    if (indexPath.row > 0) {
        homeCell.next.hidden = YES;
    }
    
    NSString *strImage = [[arrrayNextSongs objectAtIndex:indexPath.row] valueForKey:@"image"];
    if (strImage.length == 0) {
        [homeCell.albumArt setImage:[UIImage imageNamed:@"logo_icon"]];
    } else {
        [homeCell.albumArt sd_setImageWithURL:[NSURL URLWithString:strImage] placeholderImage:[UIImage imageNamed:@"logo_icon"]];
        NSLog(@"imageUrl%ld-----%@", (long)indexPath.row, strImage);
    }
    
    return homeCell;
}

@end

