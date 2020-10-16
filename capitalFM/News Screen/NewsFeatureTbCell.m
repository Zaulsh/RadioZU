//
//  NewsFeatureTbCell.m
//  capitalFM
//
//  Created by Sahil garg on 18/03/18.
//  Copyright © 2018 DS. All rights reserved.
//

#import "NewsFeatureTbCell.h"

@implementation NewsFeatureTbCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _btnPlay.layer.cornerRadius= _btnPlay.frame.size.height/2;
    [_btnPlay setClipsToBounds:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
