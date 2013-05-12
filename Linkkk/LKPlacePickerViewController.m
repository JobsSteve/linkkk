//
//  LKPlacePickerViewController.m
//  Linkkk
//
//  Created by Vincent Wen on 5/6/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import "LKPlacePickerViewController.h"
#import "LKPlacePickerCell.h"
#import "LKCreateViewController.h"

#import "LKProfile.h"
#import "LKMapManager.h"

#import "UIBarButtonItem+Linkkk.h"
#import "UIViewController+Linkkk.h"

#import <CoreLocation/CoreLocation.h>
#import "BMapKit.h"

@interface LKPlacePickerViewController ()
{
    NSArray *_results;
    BMKPoiInfo *_poi;
}
@end

@implementation LKPlacePickerViewController

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _results = [LKProfile profile].address.poiList;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_searchBar becomeFirstResponder];
    [_searchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"searchbar_bg"] forState:UIControlStateNormal];
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem customBackButtonWithTitle:@"选择地址" target:self action:@selector(backButtonSelected:)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Callbacks

- (void)backButtonSelected:(UIButton *)sender
{
    [_delegate didCancelPoi];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PlacePickerCell";
    LKPlacePickerCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    BMKPoiInfo *poi = [_results objectAtIndex:indexPath.row];
    cell.headingLabel.text = poi.name;
    cell.subHeadingLabel.text = poi.address;
    
    return cell;
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_delegate didSelectPoi:[_results objectAtIndex:indexPath.row]];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Search Bar Delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length == 0)
    {
        _results = nil;
        [self.tableView reloadData];
        return;
    }
    
    [[LKMapManager sharedInstance] poiSearchNearby:searchText withCompletionHandler:^(NSArray *results) {
        _results = results;
        [self.tableView reloadData];
    }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

#pragma mark - Helper Functions



@end
