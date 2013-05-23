//
//  CustomerSelectorDetailViewController.m
//  SalesBook
//
//  Created by Julian Knab on 07.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "CustomerSelectorDetailViewController.h"

#import "SAGMenuController.h"

#import "SBCustomer+Extensions.h"
#import "SBAddress+Extensions.h"

@interface CustomerSelectorDetailViewController()
@property (weak, nonatomic) IBOutlet UIButton *btnSelectCustomer;
@property (weak, nonatomic) IBOutlet UIButton *btnAddCustomer;
@property (nonatomic, strong) SBCustomer *selectedCustomer;
@end

@implementation CustomerSelectorDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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

- (IBAction)selectCustomer:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didSelectEntity:withObjectID:)])
    {
        [self.delegate performSelector:@selector(didSelectEntity:withObjectID:) withObject:@"SBCustomer" withObject:self.selectedCustomer.objectID];
    }
	// [[SAGMenuController defaultController] setCustomer:self.selectedCustomer];
	[self.parentViewController performSegueWithIdentifier:@"unwindCustomerSelection" sender:self];
}

- (IBAction)addCustomer:(id)sender {
}

- (void)updateUI
{
	self.btnSelectCustomer.enabled = self.btnAddCustomer.enabled = !!self.selectedCustomer;
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
