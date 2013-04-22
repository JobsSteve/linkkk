//
//  LKNearbyViewController.m
//  Linkkk
//
//  Created by Vincent Wen on 4/16/13.
//  Copyright (c) 2013 Linkkk. All rights reserved.
//

#import "LKNearbyViewController.h"
#import "LKNearbyCell.h"
#import "LKPlaceViewController.h"
#import "LKPlace.h"

@interface LKNearbyViewController ()
{
    int _selectedRow;
    NSMutableArray *_places;
}
@end

@implementation LKNearbyViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self _fetchData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    LKPlaceViewController *viewController = [segue destinationViewController];
    viewController.place = [_places objectAtIndex:[self.tableView indexPathForSelectedRow].row];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"NearbyCell";
    LKNearbyCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[LKNearbyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.place = [_places objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - Helper Functions

- (void)_fetchData
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"input" ofType:@"json"];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:kNilOptions error:nil];
    NSArray *array = [json objectForKey:@"objects"];
    _places = [[NSMutableArray alloc] initWithCapacity:[array count]];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [_places addObject:[[LKPlace alloc] initWithJSON:obj]];
    }];
    [_places enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSLog(@"%@", obj);
    }];
}

@end
