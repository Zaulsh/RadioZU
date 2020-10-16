//
//  NewVideoCollectionCell.h
//  capitalFM
//
//  Created by Sahil garg on 18/03/18.
//  Copyright © 2018 DS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewVideoCollectionCell : UICollectionViewCell

@property(strong,nonatomic) IBOutlet UILabel *lblTime;
@property(strong,nonatomic) IBOutlet UILabel *lblTitle;
@property(strong,nonatomic) IBOutlet UIImageView *newsImage;
@property(strong,nonatomic) IBOutlet UIButton *btnPlay;

@end
