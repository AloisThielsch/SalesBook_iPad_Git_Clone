//
//  ItemDetailAttributesViewController.m
//  SalesBook
//
//  Created by Frank Wittmann on 22.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "ItemDetailAttributesViewController.h"

#import "SAGObjectSelectionManager.h"

@interface ItemDetailAttributesViewController()<ObjectSelectionManagerProtocol>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *visibleData;
@end

@implementation ItemDetailAttributesViewController

- (void)setVariant:(SBVariant *)variant
{
	_variant = variant;
	self.visibleData = [_variant getVisibleData];
}

- (void)viewWillAppear:(BOOL)animated
{
	[[SAGObjectSelectionManager sharedManager] addSubscriber:self forEntity:@"SBVariant"];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[[SAGObjectSelectionManager sharedManager] removeSubscriber:self forEntity:@"SBVariant"];
}

- (void)updateUI
{
	[self.tableView reloadData];
}

#pragma mark - ObjectSelectionManagerProtocol

- (void)didSelectEntity:(NSString *)entityName withObjectID:(NSManagedObjectID *)objectID
{
	self.variant = (SBVariant *)[[NSManagedObjectContext MR_contextForCurrentThread] existingObjectWithID:objectID error:nil];
	[self updateUI];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.visibleData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ItemAttributeCell" forIndexPath:indexPath];
	
	NSDictionary *visibleDataItem = [self.visibleData objectAtIndex:indexPath.row];
	cell.textLabel.text = visibleDataItem[@"value"];
	cell.detailTextLabel.text = visibleDataItem[@"label"];
	
	return cell;
}

@end
