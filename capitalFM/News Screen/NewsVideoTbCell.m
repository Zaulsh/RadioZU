//
//  NewsVideoTbCell.m
//  capitalFM
//
//  Created by Sahil garg on 18/03/18.
//  Copyright © 2018 DS. All rights reserved.
//

#import "NewsVideoTbCell.h"
#import "NewVideoCollectionCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "NSDate+TimeAgo.h"

@implementation NewsVideoTbCell 

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _arrayCollection = [[NSMutableArray alloc]init];
    [_collectionVideos registerNib:[UINib nibWithNibName:@"NewVideoCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"videoCellID"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _arrayCollection.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    return CGSizeMake(_collectionVideos.frame.size.width-70, _collectionVideos.frame.size.height);
}
-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row+1 == _arrayCollection.count && _arrayCollection.count%10 == 0) {
        _loadMore();
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    NewVideoCollectionCell *newVideoCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"videoCellID" forIndexPath:indexPath];
    
    NSString *strDate = [[_arrayCollection objectAtIndex:indexPath.row] valueForKey:@"Data"];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormat dateFromString:strDate];
    newVideoCell.lblTime.text = [date timeAgo];

    newVideoCell.lblTitle.text = [[_arrayCollection objectAtIndex:indexPath.item] valueForKey:@"Titlu"];
    [newVideoCell.newsImage sd_setImageWithURL:[NSURL URLWithString:[[_arrayCollection objectAtIndex:indexPath.item] valueForKey:@"Poza"]] placeholderImage:[UIImage imageNamed:@"logo"]];
    
    newVideoCell.layer.cornerRadius = 10.0;
    newVideoCell.layer.masksToBounds = YES;
    
    return newVideoCell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    _clickedCell(indexPath.row);
}

@end
