//
//  CustomerContactCollectionViewController.m
//  SalesBook
//
//  Created by Frank Wittmann on 29.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "CustomerContactCollectionViewController.h"
#import "CustomerContactDetailViewController.h"

#import "SBContact+Extensions.h"

#import "ContactCell.h"
#import "CommonCollectionHeaderView.h"

@interface CustomerContactCollectionViewController()
@property (nonatomic, strong) NSArray *contactDataArray;
@property (nonatomic, strong) NSArray *contactArray;
@end

@implementation CustomerContactCollectionViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self reloadCustomer];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customerChanged:) name:notificationCustomerFilterChanged object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)customerChanged:(NSNotification *)notification
{
	if (notification.object) {
		self.customer = notification.object;
	}
}

- (void)setCustomer:(SBCustomer *)customer
{
	_customer = customer;
	[self reloadCustomer];
}

- (NSString *)customField:(NSArray *)customFields WithID:(NSString *)uniqueID
{
	NSDictionary *customField = [[customFields filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.uniqueID == %@", uniqueID]] lastObject];
	return customField[@"value"];
}

- (void)reloadCustomer
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[self buildContactData];
		[self.collectionView reloadData];
	});
}

- (void)buildContactData
{
	NSMutableArray *contactData = [NSMutableArray array];
	NSMutableArray *contacts = [NSMutableArray array];
	
	for (SBContact *contact in self.customer.contacts) {
		[contactData addObject:[contact getVisibleData]];
		[contacts addObject:contact];
	}
	self.contactDataArray = contactData;
	self.contactArray = contacts;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"contactDetail"]) {
		SBContact *contact = [[((CustomerContactCollectionViewController *)segue.sourceViewController) selectedContacts] lastObject];
		((CustomerContactDetailViewController *)segue.destinationViewController).contact = contact;
	}
}

- (NSArray *)selectedContacts
{
	NSMutableArray *contacts = [NSMutableArray array];
	for (NSIndexPath *indexPath in [self.collectionView indexPathsForSelectedItems]) {
		[contacts addObject:[self contactAtIndexPath:indexPath]];
	}
	return contacts;
}

- (SBContact *)contactAtIndexPath:(NSIndexPath *)indexPath
{
	SBContact *contact = self.contactArray[indexPath.row];
	return contact;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return [self.contactDataArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	ContactCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ContactCell" forIndexPath:indexPath];
	
//	SBContact *contact = self.contactArray[indexPath.row];
	
	NSArray *contact = [self.contactDataArray objectAtIndex:indexPath.row];
	
	NSString *fullName = [@[ [self customField:contact WithID:@"SBContact.name1"], [self customField:contact WithID:@"SBContact.name2"] ] componentsJoinedByString:@" "];
	
	cell.labelContactName.text = fullName;
	cell.labelPosition.text = [self customField:contact WithID:@"SBContact.position"];
	cell.labelPhone.text = [self customField:contact WithID:@"SBContact.tel"];
	cell.labelFax.text = [self customField:contact WithID:@"SBContact.fax"];
	cell.labelEMail.text = [self customField:contact WithID:@"SBContact.mail"];
		
	return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
	CommonCollectionHeaderView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"CommonHeaderView" forIndexPath:indexPath];
	
	view.labelHeader.text = NSLocalizedString(@"Contact Data", @"Contact Data");
	
	return view;
}

@end
