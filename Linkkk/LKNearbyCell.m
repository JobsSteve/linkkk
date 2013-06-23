//
//  LKPlaceCell.m
//  Linkkk
//
//  Created by Vincent Wen on 4/16/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import "LKNearbyCell.h"
#import "LKProfile.h"
#import "LKPlace.h"

#import "UIImageView+WebCache.h"
#import "UIViewController+Linkkk.h"

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
    NSString *distString = (_place.distance >= 1000) ? [NSString stringWithFormat:@"距离%.2f公里", _place.distance/1000.0] : [NSString stringWithFormat:@"距离%d米", _place.distance];
    _addressLabel.text = [NSString stringWithFormat:@"%@, %@", distString, _place.location];
    _userLabel.text = [NSString stringWithFormat:@"By@%@", [_place.author objectForKey:@"nickname"]];
    _favLabel.text = [NSString stringWithFormat:@"%d", _place.score];
    _heartButton.titleLabel.font = [UIFont fontWithName:@"Entypo" size:30.0];
    _heartButton.selected = _place.hasFaved;
    [_heartButton addTarget:self action:@selector(_favButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
    if (_place.score < 10) {
        _heartButton.center = CGPointMake(282, _heartButton.center.y);
    } else if (_place.score < 100) {
        _heartButton.center = CGPointMake(274, _heartButton.center.y);
    } else {
        _heartButton.center = CGPointMake(266, _heartButton.center.y);
    }
    
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

- (void)_favButtonSelected:(UIButton *)sender
{
    NSString *post = [NSString stringWithFormat:@"exp_id=%d&format=json", _place.placeID];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *urlString = _place.hasFaved ? @"http://www.linkkk.com/v5/unfavourite/exp/" : @"http://www.linkkk.com/v5/favourite/exp/";
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = postData;
    [request setValue:[NSString stringWithFormat:@"%d", [postData length]] forHTTPHeaderField:@"Content-Length"];
    [request setValue:[LKProfile profile].csrf forHTTPHeaderField:@"X-XSRF-TOKEN"];
    [request setValue:[LKProfile profile].cookie forHTTPHeaderField:@"Cookie"];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (data == nil || error != nil) {
            [UIViewController showErrorView:[NSString stringWithFormat:@"数据加载失败, %d:%@", ((NSHTTPURLResponse *)response).statusCode, error]];
            return;
        }
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        NSLog(@"%@", json);
        if (![[json objectForKey:@"status"] isEqualToString:@"okay"]) {
            [UIViewController showErrorView:@"Server failure"];
        } else {
            _place.hasFaved = !_place.hasFaved;
            _heartButton.selected = _place.hasFaved;
        }
    }];
}

@end
