//
//  CustomerSelectorViewController.m
//  SalesBook
//
//  Created by Julian Knab on 07.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "CustomerSelectorViewController.h"

#import "HorizontalTabController.h"
#import "ContainerViewControllerProxy.h"
#import "CustomerSelectorDetailViewController.h"

#import "SAGObjectSelectionManager.h"
#import "SAGFilterManager.h"

@interface CustomerSelectorViewController()<HorizontalTabControllerDelegate>
@property (nonatomic, weak) ContainerViewControllerProxy *containerViewController;
@property (nonatomic, weak) CustomerSelectorDetailViewController *detailViewController;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *filterBarButtonItem;
@end

@implementation CustomerSelectorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(filterChanged:) name:notificationFilterChanged object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = NSLocalizedString(@"Select Customer", @"Select Customer");
	[self updateFilterButton];
}

- (IBAction)chooseFilter:(UIBarButtonItem *)sender
{
	[[SAGFilterManager sharedManager] toggleFilterPopoverForEntityName:@"SBAddress"
													 fromBarButtonItem:sender];
}

- (void)filterChanged:(NSNotification *)notification
{
	[self updateFilterButton];
}

- (void)updateFilterButton
{
	if ([[SAGFilterManager sharedManager] hasFilterForEntity:@"SBAddress"]) {
		self.filterBarButtonItem.image = [UIImage imageNamed:@"weather-sun.png"];
	} else {
		self.filterBarButtonItem.image = [UIImage imageNamed:@"weather-cloud.png"];
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"embedHorizontalTabBar"]) {
		HorizontalTabController *tabBarController = (HorizontalTabController *)segue.destinationViewController;
		tabBarController.horizontalTabControllerDelegate = self;
		[tabBarController addTabWithTitle:NSLocalizedString(@"List", @"List") forSegueIdentifier:@"embedList"];
		[tabBarController addTabWithTitle:NSLocalizedString(@"Map", @"Map") forSegueIdentifier:@"embedMap"];
		
	} else if ([segue.identifier isEqualToString:@"embedContainerProxy"]) {
		self.containerViewController = segue.destinationViewController;
	} else if ([segue.identifier isEqualToString:@"embedDetail"]) {
		self.detailViewController = segue.destinationViewController;
        self.detailViewController.delegate = self;
	}
}

#pragma mark HorizontalTabControllerDelegate

- (void)horizontalTabController:(HorizontalTabController *)tabController didSelectTabWithTitle:(NSString *)title segueIdentifier:(NSString *)segueIdentifier
{
	[self.containerViewController switchToViewControllerWithSegueIdentifier:segueIdentifier];
	[[SAGObjectSelectionManager sharedManager] broadcastDeselectionOfEntity:@"SBCustomer"];
	
//	if ([segueIdentifier isEqualToString:@"embedList"]) {
//		self.detailViewController.lblSelectionPrompt.text = NSLocalizedString(@"Please select a customer from the list", @"Please select a customer from the list");
//	} else if ([segueIdentifier isEqualToString:@"embedMap"]) {
//		self.detailViewController.lblSelectionPrompt.text = NSLocalizedString(@"Please select a customer from the map", @"Please select a customer from the map");
//	}
}

- (void)didSelectEntity:(NSString *)entityName withObjectID:(NSManagedObjectID *)objectID
{
    if ([self.delegate respondsToSelector:@selector(didSelectEntity:withObjectID:)])
    {
        [self.delegate performSelector:@selector(didSelectEntity:withObjectID:) withObject:entityName withObject:objectID];
    }
}

@end