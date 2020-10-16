//
//  HomeNewsCell.h
//  capitalFM
//
//  Created by Sahil garg on 26/05/18.
//  Copyright © 2018 DS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeNewsCell : UICollectionViewCell

@property (nonatomic,strong) IBOutlet UIImageView *imgNews;
@property (nonatomic,strong) IBOutlet UITextView *lblNews;
@property (strong, nonatomic) IBOutlet UIButton *btn;

@end
