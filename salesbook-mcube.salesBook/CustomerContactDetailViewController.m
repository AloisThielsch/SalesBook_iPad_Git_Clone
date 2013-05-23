//
//  CustomerContactDetailViewController.m
//  SalesBook
//
//  Created by Frank Wittmann on 29.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "CustomerContactDetailViewController.h"

@interface CustomerContactDetailViewController()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *visibleData;
@end

@implementation CustomerContactDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.visibleData = [self.contact getVisibleData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.visibleData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ContactDetailCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
	
	NSDictionary *visibleDataItem = [self.visibleData objectAtIndex:indexPath.row];
	
	cell.textLabel.text = visibleDataItem[@"label"];
	cell.detailTextLabel.text = visibleDataItem[@"value"];
    
    return cell;
}

@end
