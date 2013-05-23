//
//  MenuViewController.m
//  ECSlidingViewController
//
//  Created by Michael Enriquez on 1/23/12.
//  Copyright (c) 2012 EdgeCase. All rights reserved.
//

#import "MenuViewController.h"

#import "SAGLoginManager.h"
#import "SBCustomer+Extensions.h"

#import "SAGSyncManager.h"

#import "SBAddress+Extensions.h"

#import "SBVariantMatrixViewController.h"

#import "SBItem+Extensions.h"

#import "TDBadgedCell.h"
#import "CustomerSelectorViewController.h"

@interface MenuViewController()

@end

@implementation MenuViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  [self.slidingViewController setAnchorRightRevealAmount:280.0f];
  self.slidingViewController.underLeftWidthLayout = ECFullWidth;
	self.slidingViewController.shouldAllowUserInteractionsWhenAnchored = NO;
    
  [[SAGMenuController defaultController] setDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - tableView dataSoure

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return [[self arrayForSection:sectionIndex] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([self tableView:self.tableView numberOfRowsInSection:section] == 0) return nil;
    
    switch (section) {
        case 0:
            return NSLocalizedString(@"Customer", @"Customer menu header");
            break;
        case 1:
            return NSLocalizedString(@"Documents", @"Documents menu header");
            break;
        default:
            return NSLocalizedString(@"Other", @"Other menu header");
            break;
    }
    
    return nil;
}

- (NSArray *)arrayForSection:(NSInteger)sectionIndex
{
    
    switch (sectionIndex) {
        case 1:
            return [[SAGMenuController defaultController] documentMenuItems];
            break;
        case 2:
            return [[SAGMenuController defaultController] defaultMenuItems];
            break;
        default:
            return [[SAGMenuController defaultController] customerMenuItems];
            break;
    }
    
    return nil;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"MenuItemCell";
    
    TDBadgedCell *cell = [[TDBadgedCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    
    NSDictionary *menuItem = [[self arrayForSection:indexPath.section] objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [menuItem valueForKey:@"label"];
    
    if ([[menuItem valueForKey:@"numberOfObjects"] integerValue] > 0)
    {
        cell.badgeString = [[menuItem valueForKey:@"numberOfObjects"] stringValue];
    }
    
    NSString *image = [menuItem valueForKey:@"image"];
    
    if (image.length > 0)
    {
        cell.imageView.image = [UIImage imageNamed:image];
    }
    else
    {
        cell.imageView.image = nil;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [[[self arrayForSection:indexPath.section] objectAtIndex:indexPath.row] valueForKey:@"identifier"];
    NSInteger documentType = [[[[self arrayForSection:indexPath.section] objectAtIndex:indexPath.row] valueForKey:@"documentType"] integerValue];
    
    if ([identifier isEqualToString:@"SendFiles"])
    {
        [[SAGSyncManager sharedClient] trySendingFilesInBackground:YES]; //Offline Dateien wegschicken!
        return;
    }
    
    UIViewController *newTopViewController;
    
    @try
    {
        newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
		
        if (documentType && [newTopViewController respondsToSelector:@selector(setDocumentType:)])
        {
			[newTopViewController performSelector:@selector(setDocumentType:) withObject:@(documentType)];
		}
    }
    @catch (NSException *exception)
    {
        DDLogError(@"Menu Controller couldn´t find VC with identifier: %@", identifier);
        return;
    }
    
    [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
        
        CGRect frame = self.slidingViewController.topViewController.view.frame;
        self.slidingViewController.topViewController = newTopViewController;
        self.slidingViewController.topViewController.view.frame = frame;
        [self.slidingViewController resetTopView];
    
    }];
}

- (IBAction)removeSelectedCustomer
{
    [[SAGMenuController defaultController] performSelectorInBackground:@selector(setCustomer:) withObject:nil];
}

#pragma mark - SAGMenueController delegate

- (void)menuControllerRefreshSelectedCustomerDisplayWithCustomer:(SBCustomer *)customer;
{
    SBAddress *address = [customer primaryAddress];
    
    _lblCustomerNo.text = customer.customerNumber;
    _lblName1.text = address.name1;
    _lblStreet.text = address.street;
    _lblZipCity.text = address.zipCity;
    _lblCountry.text = address.country;
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    _btnRemoveSelectedCustomer.hidden = (customer == nil);
    _btnShowCustomerSelector.hidden = (customer != nil);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"selectCustomer"])
    {
        CustomerSelectorViewController *customerSelectorViewController = segue.destinationViewController;
        customerSelectorViewController.delegate = self;
    }
}

- (void)didSelectEntity:(NSString *)entityName withObjectID:(NSManagedObjectID *)objectID
{
    if ([entityName isEqualToString:@"SBCustomer"])
    {
        SBCustomer *selectedCustomer = (SBCustomer *)[[NSManagedObjectContext MR_contextForCurrentThread] existingObjectWithID:objectID error:nil];
        [[SAGMenuController defaultController] performSelectorInBackground:@selector(setCustomer:) withObject:selectedCustomer];
    }
}

- (IBAction)closeCustomerSelector:(UIStoryboardSegue *)segue
{
    
}

@end
