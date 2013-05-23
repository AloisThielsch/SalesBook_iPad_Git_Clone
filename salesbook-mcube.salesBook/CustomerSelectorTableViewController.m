//
//  CustomerSelectorTableViewController.m
//  SalesBook
//
//  Created by Julian Knab on 07.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "CustomerSelectorTableViewController.h"

#import "SBCustomer+Extensions.h"
#import "SBAddress+Extensions.h"

#import "CustomerSelectorTableViewCell.h"

#import "SAGObjectSelectionManager.h"
#import "SAGFilterManager.h"
#import "SAGFilterBuilder.h"

@interface CustomerSelectorTableViewController()<UITableViewDataSource, UITableViewDelegate, FilterManagerDelegate>
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sortSegments;
@end

@implementation CustomerSelectorTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.tableView.rowHeight = 100.0f;
	[self setupSegmentedControl];
	[self switchToSortSegmentWithIndex:0];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(filterChanged:) name:notificationFilterChanged object:nil];
	[SAGFilterManager sharedManager].delegate = self;
	[[SAGFilterManager sharedManager] activateFilterForEntity:@"SBAddress"];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[SAGFilterManager sharedManager].delegate = nil;
}

- (void)didSelectFilter:(SBFilter *)filter forEntityName:(NSString *)entityName
{
	NSInteger segmentIndex = self.sortSegments.selectedSegmentIndex;
	NSString *sortBy = @"name1";
	
	switch (segmentIndex) {
		case 0:
		default:
			sortBy = @"name1";
			break;
			
		case 1:
			sortBy = @"customerNumber";
			break;
			
		case 2:
			sortBy = @"postalCode";
			break;
	}
	
	NSPredicate *predicate;
	NSPredicate *addressTypePredicate = [NSPredicate predicateWithFormat:@"addressType in %@", @[ @(SAGAddressTypePrimaryAddress), @(SAGAddressTypeDeliveryAddress) ]];

	if (filter) {
		NSArray *addresses = [SBAddress MR_findAllWithPredicate:addressTypePredicate];
		[filter setObjectsToFilter:[NSSet setWithArray:addresses]];
		NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"self in %@", [filter getResult]];
		predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[ addressTypePredicate, filterPredicate ]];
	} else {
		predicate = addressTypePredicate;
	}

	_fetchedResultsController = [SBAddress MR_fetchAllSortedBy:sortBy
													 ascending:YES
												 withPredicate:predicate
													   groupBy:nil
													  delegate:nil];
	NSError *error = nil;
	[_fetchedResultsController performFetch:&error];
	
	[[SAGObjectSelectionManager sharedManager] broadcastDeselectionOfEntity:@"SBCustomer"];
	[self.tableView reloadData];
}

- (void)filterChanged:(NSNotification *)notification
{
}


- (NSFetchedResultsController *)fetchedResultsController
{
//	if (!_fetchedResultsController) {
//		NSPredicate *addressTypePredicate = [NSPredicate predicateWithFormat:@"addressType in %@", @[ @(SAGAddressTypePrimaryAddress), @(SAGAddressTypeDeliveryAddress) ]];
//		_fetchedResultsController = [SBAddress MR_fetchAllSortedBy:@"name1" ascending:YES withPredicate:addressTypePredicate groupBy:nil delegate:nil];
//	}
	return _fetchedResultsController;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CustomerSelectorTableViewCell";
    CustomerSelectorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

	SBAddress *address = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	cell.lblCustomerNumber.text = address.customerNumber;
	cell.lblCustomerName.text = address.name1;
	cell.lblCustomerStreet.text = address.street;
	cell.lblCustomerZipAndCity.text = [address zipCity];
	cell.lblCustomerCountry.text = address.country;
	cell.lblCustomerAddressType.text = [self addressTypeString:address];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo name];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self.fetchedResultsController sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	cell.contentView.backgroundColor = (indexPath.row % 2 == 0) ? [UIColor whiteColor] : [UIColor colorWithWhite:0.9 alpha:0.5];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	SBAddress *address = [self.fetchedResultsController objectAtIndexPath:indexPath];
	SBCustomer *customer = address.customer;
	
	[[SAGObjectSelectionManager sharedManager] broadcastSelectionOfEntity:@"SBCustomer" withObjectID:customer.objectID];
}

- (IBAction)sortSegmentChanged:(UISegmentedControl *)sender
{
	[self switchToSortSegmentWithIndex:sender.selectedSegmentIndex];
}

#pragma mark - Helpers

- (void)setupSegmentedControl
{
	[self.sortSegments removeAllSegments];
	[self.sortSegments insertSegmentWithTitle:NSLocalizedString(@"Name", @"Name") atIndex:0 animated:NO];
	[self.sortSegments insertSegmentWithTitle:NSLocalizedString(@"Number", @"Number") atIndex:1 animated:NO];
	[self.sortSegments insertSegmentWithTitle:NSLocalizedString(@"ZIP Code", @"ZIP Code") atIndex:2 animated:NO];
}

- (void)switchToSortSegmentWithIndex:(NSInteger)segmentIndex
{
	[self.sortSegments setSelectedSegmentIndex:segmentIndex];
	NSString *sortBy = @"name1";
	
	switch (segmentIndex) {
		case 0:
		default:
			sortBy = @"name1";
			break;
			
		case 1:
			sortBy = @"customerNumber";
			break;

		case 2:
			sortBy = @"postalCode";
			break;
	}
	
	SBFilter *filter = [[SAGFilterManager sharedManager] filterForEntity:@"SBAddress"];
	
	[SVProgressHUD show];
	
	SAGFilterBuilder *builder = [SAGFilterBuilder filterBuilderWithEntityClass:[SBAddress class]];
	[builder addPredicate:[NSPredicate predicateWithFormat:@"addressType in %@", @[ @(SAGAddressTypePrimaryAddress), @(SAGAddressTypeDeliveryAddress) ]]];
	
	NSPredicate *addressTypePredicate = [NSPredicate predicateWithFormat:@"addressType in %@", @[ @(SAGAddressTypePrimaryAddress), @(SAGAddressTypeDeliveryAddress) ]];
	_fetchedResultsController = [SBAddress MR_fetchAllSortedBy:sortBy
													 ascending:YES
												 withPredicate:addressTypePredicate
													   groupBy:nil
													  delegate:nil];
	NSError *error = nil;
	[_fetchedResultsController performFetch:&error];
	
	[SVProgressHUD dismiss];

	[self.tableView reloadData];
}

- (NSString *)addressTypeString:(SBAddress *)address
{
	switch ([address.addressType integerValue]) {
		case SAGAddressTypePrimaryAddress:
			return NSLocalizedString(@"Primary", @"Primary");
			break;
			
		case SAGAddressTypeDeliveryAddress:
			return NSLocalizedString(@"Delivery", @"Delivery");
			break;

		default:
			return NSLocalizedString(@"<unknown>", @"<unknown>");
			break;
	}
}

@end
