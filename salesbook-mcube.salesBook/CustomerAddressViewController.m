//
//  CustomerAddressViewController.m
//  SalesBook
//
//  Created by Frank Wittmann on 26.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "CustomerAddressViewController.h"
#import "CustomerAddressCollectionViewController.h"
#import "CustomerAddressDetailViewController.h"

#import "ECSlidingViewController.h"

#import "SAGMenuController.h"

@interface CustomerAddressViewController()
@property (nonatomic, strong) SBCustomer *customer;
@property (nonatomic, weak) CustomerAddressCollectionViewController *collectionViewController;
@end

@implementation CustomerAddressViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	self.customer = [SAGMenuController defaultController].customer;
	
	if ([segue.identifier isEqualToString:@"embedCollectionView"]) {
		self.collectionViewController = segue.destinationViewController;
		self.collectionViewController.customer = self.customer;
	}
}

- (IBAction)revealMenu:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

#pragma mark - Unwind Detail

- (IBAction)unwindAddressDetail:(UIStoryboardSegue *)sender
{
}

@end
