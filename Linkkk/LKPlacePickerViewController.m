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
#import "UIBarButtonItem+Linkkk.h"
#import "UIViewController+Linkkk.h"

#import <CoreLocation/CoreLocation.h>

@interface LKPlacePickerViewController ()
{
    NSMutableArray *_results;
}
@end

@implementation LKPlacePickerViewController

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _results = [NSMutableArray arrayWithCapacity:10];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_searchBar becomeFirstResponder];
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem customBackButtonWithTarget:self action:@selector(backButtonSelected:)];
    [_searchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"searchbar_bg"] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Callbacks

- (void)backButtonSelected:(UIButton *)sender
{
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
    NSArray *terms = [[_results objectAtIndex:indexPath.row] objectForKey:@"terms"];
    if (terms == nil || terms.count == 0)
        return cell;
    cell.headingLabel.text = [[terms objectAtIndex:0] objectForKey:@"value"];
    NSString *address = @"";
    if (terms.count > 1) address = [[terms objectAtIndex:1] objectForKey:@"value"];
    if (terms.count > 2) address = [address stringByAppendingFormat:@", %@", [[terms objectAtIndex:2] objectForKey:@"value"]];
    if (terms.count > 3) address = [address stringByAppendingFormat:@", %@", [[terms objectAtIndex:3] objectForKey:@"value"]];
    cell.subHeadingLabel.text = address;
    
    return cell;
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LKPlacePickerCell *cell = (LKPlacePickerCell *)[tableView cellForRowAtIndexPath:indexPath];
    _placemarkLabel.text = [cell.headingLabel.text stringByAppendingFormat:@", %@", cell.subHeadingLabel.text];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Search Bar Delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self _fetchData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

#pragma mark - Helper Functions

- (void)_fetchData
{
    if (_searchBar.text.length == 0)
    {
        [_results removeAllObjects];
        [self.tableView reloadData];
        return;
    }
    
    CLLocationCoordinate2D coord = [LKProfile profile].location.coordinate;
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&language=zh-CH&types=establishment&location=%f,%f&radius=500&sensor=true&key=AIzaSyCc1TGG_Fb-er_y74L0zL8-10euOTr352k", [_searchBar.text stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding], coord.latitude, coord.longitude];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (data == nil || error != nil) {
            [self showErrorView:[NSString stringWithFormat:@"数据加载失败, %d:%@", ((NSHTTPURLResponse *)response).statusCode, error]];
            return;
        }
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        [_results removeAllObjects];
        NSArray *predictions = [json objectForKey:@"predictions"];
        [predictions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [_results addObject:obj];
        }];
        [self.tableView reloadData];
    }];
}

@end
