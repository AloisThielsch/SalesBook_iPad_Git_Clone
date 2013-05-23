//
//  CustomerAddressCollectionViewController.m
//  SalesBook
//
//  Created by Frank Wittmann on 26.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "CustomerAddressCollectionViewController.h"
#import "CustomerAddressDetailViewController.h"

#import "SBCustomer+Extensions.h"
#import "SBAddress+Extensions.h"

#import "AddressCell.h"
#import "CommonCollectionHeaderView.h"

@interface CustomerAddressCollectionViewController()
@property (nonatomic, strong) NSArray *addressTypeArray;
@end

@implementation CustomerAddressCollectionViewController

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

- (void)reloadCustomer
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[self buildAddressData];
		[self.collectionView reloadData];
	});
}

- (void)buildAddressData
{
	NSMutableArray *addressTypeArray = [NSMutableArray array];
	NSDictionary *addressTypeMap = [NSMutableDictionary dictionary];
	SBAddress *address = [self.customer primaryAddress];
	
	if (address) {
		addressTypeMap = @{ @"type":@(SAGAddressTypePrimaryAddress),
					  @"label":NSLocalizedString(@"Primary Address", @"Primary Address"),
					  @"array":@[ address ]
					  };
		[addressTypeArray addObject:addressTypeMap];
	}
	
	NSSet *addressSet;
	addressSet = [self.customer getInvoiceAddressesWithFallback:NO];
	if (addressSet) {
		addressTypeMap = @{ @"type":@(SAGAddressTypeInvoiceAddress),
					  @"label":NSLocalizedString(@"Invoice Addresses", @"Invoice Addresses"),
					  @"array":[addressSet allObjects]
					  };
		[addressTypeArray addObject:addressTypeMap];
	}
	
	addressSet = [self.customer getDeliveryAddressesWithFallback:NO];
	if (addressSet) {
		addressTypeMap = @{ @"type":@(SAGAddressTypeDeliveryAddress),
					  @"label":NSLocalizedString(@"Delivery Addresses", @"Delivery Addresses"),
					  @"array":[addressSet allObjects]
					  };
		[addressTypeArray addObject:addressTypeMap];
	}

	self.addressTypeArray = addressTypeArray;	
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"addressDetail"]) {
		SBAddress *address = [[((CustomerAddressCollectionViewController *)segue.sourceViewController) selectedAddresses] lastObject];
		((CustomerAddressDetailViewController *)segue.destinationViewController).address = address;
	}
}

- (SBAddress *)addressAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *addressData = self.addressTypeArray[indexPath.section];
	return addressData[@"array"][indexPath.row];
}

- (NSArray *)selectedAddresses
{
	NSMutableArray *addresses = [NSMutableArray array];
	for (NSIndexPath *indexPath in [self.collectionView indexPathsForSelectedItems]) {
		[addresses addObject:[self addressAtIndexPath:indexPath]];
	}
	return addresses;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	NSDictionary *addressData = self.addressTypeArray[section];
	return [addressData[@"array"] count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return [self.addressTypeArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	AddressCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AddressCell" forIndexPath:indexPath];
	
	SBAddress *address = [self addressAtIndexPath:indexPath];
	cell.labelCustomerNumber.text = address.customerNumber;
	cell.labelCustomerName.text = address.name1 ? address.name1 : address.name2;
	cell.labelStreet.text = address.street;
	cell.labelCityZip.text = [address zipCity];
	cell.labelCountry.text = address.country;
	
	return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
	CommonCollectionHeaderView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"CommonHeaderView" forIndexPath:indexPath];

	NSDictionary *addressData = self.addressTypeArray[indexPath.section];
	view.labelHeader.text = addressData[@"label"];

	return view;
}

@end
