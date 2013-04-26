//
//  LKPlaceCell.m
//  Linkkk
//
//  Created by Vincent Wen on 4/16/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import "LKNearbyCell.h"
#import "LKPlace.h"

@implementation LKNearbyCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setPlace:(LKPlace *)place
{
    _place = place;
    _titleLabel.text = _place.title;
    _addressLabel.text = [NSString stringWithFormat:@"距离%d米, %@", _place.distance, _place.address];
}

@end
