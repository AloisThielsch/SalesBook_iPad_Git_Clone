//
//  CustomerContactViewController.m
//  SalesBook
//
//  Created by Frank Wittmann on 29.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "CustomerContactViewController.h"
#import "CustomerContactCollectionViewController.h"
#import "ECSlidingViewController.h"

#import "SBCustomer+Extensions.h"

#import "SAGMenuController.h"

@interface CustomerContactViewController()
@property (nonatomic, strong) SBCustomer *customer;
@property (nonatomic, weak) CustomerContactCollectionViewController *collectionViewController;
@end

@implementation CustomerContactViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	self.customer = [SAGMenuController defaultController].customer;
	
	if ([segue.identifier isEqualToString:@"embedContactsCollectionView"]) {
		self.collectionViewController = segue.destinationViewController;
		self.collectionViewController.customer = self.customer;
	}
}

- (IBAction)revealMenu:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

#pragma mark - Unwind Detail

- (IBAction)unwindContactDetail:(UIStoryboardSegue *)sender
{
}

@end
