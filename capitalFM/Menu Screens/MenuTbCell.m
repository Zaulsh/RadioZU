//
//  MenuTbCell.m
//  capitalFM
//
//  Created by Sahil garg on 16/03/18.
//  Copyright © 2018 DS. All rights reserved.
//

#import "MenuTbCell.h"

@implementation MenuTbCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _notifySwitch.transform = CGAffineTransformMakeScale(0.75, 0.75);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
