//
//  LKPlaceCell.m
//  Linkkk
//
//  Created by Vincent Wen on 4/16/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import "LKNearbyCell.h"
#import "LKPlace.h"

#import "UIImageView+WebCache.h"

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
    _addressLabel.text = [NSString stringWithFormat:@"距离%d米, %@", _place.distance, _place.location];
    _userLabel.text = [NSString stringWithFormat:@"By@%@", [_place.author objectForKey:@"nickname"]];
    _favLabel.text = [NSString stringWithFormat:@"%d", _place.score];
    _heartLabel.font = [UIFont fontWithName:@"Entypo" size:30.0];
    if (_place.hasFaved)
        _heartLabel.textColor = [UIColor redColor];
    
    _photoView1.hidden = YES;
    _photoView2.hidden = YES;
    _photoView3.hidden = YES;
    
    NSArray *album = _place.album;
    if (album.count > 0) {
        NSURL *url = [NSURL URLWithString:[[album objectAtIndex:0] objectForKey:@"square"]];
        [_photoView1 setImageWithURL:url];
        _photoView1.hidden = NO;
    }
    if (album.count > 1) {
        NSURL *url = [NSURL URLWithString:[[album objectAtIndex:1] objectForKey:@"square"]];
        [_photoView2 setImageWithURL:url];
        _photoView2.hidden = NO;
    }
    if (album.count > 2) {
        NSURL *url = [NSURL URLWithString:[[album objectAtIndex:2] objectForKey:@"square"]];
        [_photoView3 setImageWithURL:url];
        _photoView3.hidden = NO;
    }
}

@end
