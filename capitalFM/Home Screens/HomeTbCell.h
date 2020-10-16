//
//  HomeTbCell.h
//  capitalFM
//
//  Created by Sahil garg on 14/03/18.
//  Copyright © 2018 DS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeTbCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *albumArt;
@property (weak, nonatomic) IBOutlet UILabel *lblArtist;
@property (weak, nonatomic) IBOutlet UILabel *lblSong;
@property (weak, nonatomic) IBOutlet UILabel *next;
@end
