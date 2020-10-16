//
//  NewsVideoTbCell.h
//  capitalFM
//
//  Created by Sahil garg on 18/03/18.
//  Copyright © 2018 DS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsVideoTbCell : UITableViewCell <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property(strong, nonatomic) IBOutlet UILabel *lblTitle;
@property(strong, nonatomic) IBOutlet UIButton *btnSeeAll;
@property(strong, nonatomic) IBOutlet UICollectionView *collectionVideos;
@property(strong, nonatomic) NSMutableArray *arrayCollection;
@property(strong, nonatomic) void (^loadMore)(void);
@property(strong, nonatomic) void (^clickedCell)(NSInteger);

@end
