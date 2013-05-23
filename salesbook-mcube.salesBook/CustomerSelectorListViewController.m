//
//  CustomerSelectorListViewController.m
//  SalesBook
//
//  Created by Frank Wittmann on 15.05.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "CustomerSelectorListViewController.h"

#import "SBCustomer+Extensions.h"

@interface CustomerSelectorListViewController()
@property (nonatomic, strong) SBCustomer *selectedCustomer;
@property (nonatomic, strong) NSArray *visibleData;
@end

@implementation CustomerSelectorListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[[SAGObjectSelectionManager sharedManager] addSubscriber:self forEntity:@"SBCustomer"];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[[SAGObjectSelectionManager sharedManager] removeSubscriber:self forEntity:@"SBCustomer"];
}

- (void)updateUI
{
//	self.customFieldProvider.visibleData = [self.selectedCustomer getVisibleData];
	self.visibleData = [self.selectedCustomer getVisibleData];
	[self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.visibleData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomerSelectorListCell" forIndexPath:indexPath];

	NSDictionary *visibleDataItem = [self.visibleData objectAtIndex:indexPath.row];
	
	cell.textLabel.text = visibleDataItem[@"value"];
	cell.detailTextLabel.text = visibleDataItem[@"label"];

	return cell;
}

#pragma mark - ObjectSelectionManagerProtocol

- (void)didSelectEntity:(NSString *)entityName withObjectID:(NSManagedObjectID *)objectID
{
	self.selectedCustomer = (SBCustomer *)[[NSManagedObjectContext MR_contextForCurrentThread] existingObjectWithID:objectID error:nil];
	[self updateUI];
}

- (void)didDeselectEntity:(NSString *)entityName
{
	self.selectedCustomer = nil;
	[self updateUI];
}

@end
