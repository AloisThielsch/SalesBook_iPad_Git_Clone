//
//  SAGFilterManager.m
//  SalesBook
//
//  Created by Frank Wittmann on 07.05.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SAGFilterManager.h"

#import "FilterListViewController.h"

@interface SAGFilterManager() {
	FilterListViewController *filterListController;
}
@property (nonatomic, strong) NSString *entityName;
@property (nonatomic, strong) NSMutableDictionary *filterMap;
@property (nonatomic, strong) UIPopoverController *popoverController;
@end

@implementation SAGFilterManager

+ (SAGFilterManager *)sharedManager
{
	static dispatch_once_t onceToken;
	static SAGFilterManager *_instance = nil;
	dispatch_once(&onceToken, ^{
		_instance = [[SAGFilterManager alloc] init];
	});
	return _instance;
}

- (id)init
{
	self = [super init];

	if (self) {
		self.filterMap = [NSMutableDictionary dictionary];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(logout:)
													 name:notificationLogoutSuccessful
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(filterChanged:)
													 name:notificationFilterChanged
												   object:nil];

		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(filterEdited:)
													 name:notificationFilterEdited
												   object:nil];
}

	return self;
}

// Housekeeping, wird bei singletons nicht aufgerufen, aber ich bin brav!
- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)logout:(NSNotification *)notification
{
	NSLog(@"Logout, removing all assigned filters");
	[self.filterMap removeAllObjects];
}

- (void)filterChanged:(NSNotification *)notification
{
	SBFilter *filter = notification.userInfo[@"filter"];
	[self setFilter:filter forEntity:self.entityName];

	if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectFilter:forEntityName:)])
	{
		[self.delegate didSelectFilter:filter
						 forEntityName:self.entityName];
	}

	NSLog(@"Did select filter %@", filter.debugDescription);
	
	[self.popoverController dismissPopoverAnimated:YES];
	self.popoverController = nil;
	filterListController = nil;
}

- (void)filterEdited:(NSNotification *)notification
{
	filterListController.filterArray = [SBFilter availableFiltersForEntity:self.entityName];
	[filterListController.tableView reloadData];
}

#pragma mark - filter management

- (BOOL)hasFilterForEntity:(NSString *)entityName
{
	SBFilter *filter = self.filterMap[entityName];
	return !!filter;
}

- (SBFilter *)filterForEntity:(NSString *)entityName
{
	return self.filterMap[entityName];
}

- (void)setFilter:(SBFilter *)filter forEntity:(NSString *)entityName
{
	if (filter) {
		self.filterMap[entityName] = filter;
	} else {
		[self.filterMap removeObjectForKey:entityName];
	}
}

- (void)activateFilterForEntity:(NSString *)entityName
{
	if ([self hasFilterForEntity:entityName]) {
		if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectFilter:forEntityName:)])
		{
			[self.delegate didSelectFilter:[self filterForEntity:entityName]
							 forEntityName:self.entityName];
		}
	}
}

- (BOOL)isActiveFilter:(SBFilter *)filter forEntity:(NSString *)entityName
{
	if (![self hasFilterForEntity:entityName]) {
		return NO;
	}
	
	return [[self filterForEntity:entityName] isEqual:filter];
}

#pragma mark - filter selection popover

- (UIPopoverController *)popoverController
{
	if (!_popoverController) {
		filterListController = [[FilterListViewController alloc] initWithStyle:UITableViewStylePlain];
		UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:filterListController];
		
		filterListController.entityName = self.entityName;
		filterListController.filterArray = [SBFilter availableFiltersForEntity:self.entityName];
		
		_popoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
	}
	
	return _popoverController;
}

- (void)toggleFilterPopoverForEntityName:(NSString *)entityName
					   fromBarButtonItem:(UIBarButtonItem *)item
{
	self.entityName = entityName;
	
	if (self.popoverController.isPopoverVisible) {
		[self.popoverController dismissPopoverAnimated:YES];
	} else {
		[self.popoverController presentPopoverFromBarButtonItem:item
									   permittedArrowDirections:UIPopoverArrowDirectionAny
													   animated:YES];
	}
}

@end
