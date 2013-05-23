//
//  DocumentsCollectionViewController.m
//  SalesBook
//
//  Created by Frank Wittmann on 30.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "DocumentsCollectionViewController.h"
#import "SBShoppingCartDetailViewController.h"

#import "DocumentCell.h"
#import "CommonCollectionHeaderView.h"

#import "SBDocument+Extensions.h"
#import "SBCustomer+Extensions.h"
#import "SBShoppingCart+Extensions.h"

@interface DocumentsCollectionViewController()
@property (nonatomic, strong) NSArray *customerDocumentsArray;
@end

@implementation DocumentsCollectionViewController

- (void)setDocumentArray:(NSArray *)documentArray
{
	_documentArray = documentArray;

	NSMutableArray *documentsArray = [NSMutableArray array];
	NSArray *sortByCustomer = [documentArray valueForKeyPath:@"@distinctUnionOfObjects.customer"];
	NSArray *currentArray;
	
	currentArray = [documentArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"customer = nil"]];
	if (currentArray && [currentArray count]) {
		NSMutableDictionary *unassignedDictionary = [NSMutableDictionary dictionary];
		unassignedDictionary[@"customer"] = [NSNull null];
		unassignedDictionary[@"documents"] = [documentArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"customer = nil"]];
		unassignedDictionary[@"headerLabel"] = NSLocalizedString(@"Not Assigned", @"Not Assigned");
		[documentsArray addObject:unassignedDictionary];
	}

	for (SBCustomer *customer in sortByCustomer) {
		currentArray = [documentArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"customer = %@", customer]];
		if (currentArray && [currentArray count]) {
			NSMutableDictionary *customerDictionary = [NSMutableDictionary dictionary];
			customerDictionary[@"customer"] = customer;
			customerDictionary[@"documents"] = currentArray;
			customerDictionary[@"headerLabel"] = customer.customerNumber;
			[documentsArray addObject:customerDictionary];
		}
	}
	
	self.customerDocumentsArray = documentsArray;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return [self.customerDocumentsArray[section][@"documents"] count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return [self.customerDocumentsArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	DocumentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DocumentCell" forIndexPath:indexPath];
	
	SBDocument *document;
	document = self.customerDocumentsArray[indexPath.section][@"documents"][indexPath.row];
	
	cell.labelDocumentNumber.text = document.documentNumber;
	cell.labelCustomerNumber.text = document.customerNumber;
	
	return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
	CommonCollectionHeaderView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"CommonHeaderView" forIndexPath:indexPath];

	NSDictionary *customerDictionary = self.customerDocumentsArray[indexPath.section];
	if (customerDictionary) {
		view.labelHeader.text = customerDictionary[@"headerLabel"];
	} else {
		view.labelHeader.text = nil;
	}
	
	return view;
}

// dynamische detail-vcs in abhängigkeit der sbdocument subklasse. böse oder flexibel?

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	SBDocument *document;
	document = self.customerDocumentsArray[indexPath.section][@"documents"][indexPath.row];
	
	if (document) {
		NSString *detailSelectorString = [NSString stringWithFormat:@"performDetailFor%@:", [document class]];
		SEL detailSelector = NSSelectorFromString(detailSelectorString);
		
		if ([self respondsToSelector:detailSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
			[self performSelector:detailSelector withObject:document];
#pragma clang diagnostic pop
		}
	}
}

- (void)performDetailForSBShoppingCart:(id)document
{
	SBShoppingCart *cart = (SBShoppingCart *)document;

	SBShoppingCartDetailViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"ShoppingCart"];
	controller.cart = cart;
	controller.modalPresentationStyle = UIModalPresentationFullScreen;
	[self presentViewController:controller
					   animated:YES
					 completion:nil];
}

@end
