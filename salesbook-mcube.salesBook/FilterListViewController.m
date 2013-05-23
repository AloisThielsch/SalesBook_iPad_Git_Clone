//
//  FilterListViewController.m
//  SalesBook
//
//  Created by Frank Wittmann on 07.05.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "FilterListViewController.h"
#import "FilterManagerViewController.h"

#import "SAGFilterManager.h"

#import "FilterListCell.h"

@interface FilterListViewController()
@end

@implementation FilterListViewController

static NSString *CellIdentifier = @"FilterListCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self.tableView registerClass:[FilterListCell class]
		   forCellReuseIdentifier:CellIdentifier];

	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																						   target:self
																						   action:@selector(addFilter:)];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(filterChanged:) name:notificationFilterEdited object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];

	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)filterChanged:(NSNotification *)notification
{
	[self.tableView reloadData];
}

- (void)addFilter:(id)sender
{
	NSLog(@"Adding filter");
	FilterManagerViewController *controller = [FilterManagerViewController filterManagerViewControllerForEntityName:self.entityName];
	controller.editingMode = FilterManagerEditingModeNew;
	[self presentViewController:controller
					   animated:YES
					 completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0) {
		return 1;
	}

	return [self.filterArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0) {
		FilterListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
															   forIndexPath:indexPath];
		cell.textLabel.text = NSLocalizedString(@"Clear Filter", @"Clear Filter");
		cell.accessoryType = UITableViewCellAccessoryNone;
		
		return cell;
	} else {
		FilterListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
															   forIndexPath:indexPath];
		
		SBFilter *filter = self.filterArray[indexPath.row];
		
		cell.textLabel.text = filter.name;
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
		
		return cell;
	}
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([_filterArray count] >= 1) {
		SBFilter *filter = self.filterArray[indexPath.row];
		if ([[SAGFilterManager sharedManager] isActiveFilter:filter forEntity:self.entityName]) {
			cell.backgroundColor = [UIColor colorWithWhite:0.9 alpha:0.5];
			cell.textLabel.textColor = [UIColor blackColor];
		} else {
			cell.backgroundColor = [UIColor clearColor];
			cell.textLabel.textColor = [UIColor darkGrayColor];
		}
	}
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0) {
		[[NSNotificationCenter defaultCenter] postNotificationName:notificationFilterChanged
															object:self
														  userInfo:nil];
	} else {
		SBFilter *filter = self.filterArray[indexPath.row];
		[[NSNotificationCenter defaultCenter] postNotificationName:notificationFilterChanged
															object:self
														  userInfo:@{ @"filter" : filter }];
	}
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	SBFilter *filter = self.filterArray[indexPath.row];

	NSLog(@"Editing filter");
	FilterManagerViewController *controller = [FilterManagerViewController filterManagerViewControllerForEntityName:self.entityName];
	controller.filter = filter;
	controller.editingMode = FilterManagerEditingModeExisting;
	[self presentViewController:controller
					   animated:YES
					 completion:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        SBFilter *filter = self.filterArray[indexPath.row];
        [filter removeFilter];
    }
}

@end
