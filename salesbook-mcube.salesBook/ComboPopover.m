//
//  ComboPopover.m
//  SalesBook
//
//  Created by Frank Wittmann on 07.05.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "ComboPopover.h"

#import "ComboPopoverContentViewController.h"

#import "ComboPopoverCell.h"

@interface ComboPopover()<UITableViewDataSource, UITableViewDelegate, UIPopoverControllerDelegate, UISearchBarDelegate> {
	ComboPopoverContentViewController *contentController;
	UISearchBar *searchBar;
}

@property (nonatomic, strong) NSString *labelKeyPath;
@property (nonatomic, strong) NSString *valueKeyPath;
@property (nonatomic) id<ComboPopoverDelegate> delegate;
@property (nonatomic, strong) UIPopoverController *popoverController;
@property (nonatomic, strong) NSArray *filteredItemArray;
@end

@implementation ComboPopover

- (id)initWithItemArray:(NSArray *)itemArray labelKeyPath:(NSString *)labelKeyPath valueKeyPath:(NSString *)valueKeyPath delegate:(id<ComboPopoverDelegate>)delegate
{
	self = [super init];

	if (self) {
		self.itemArray = itemArray;
		self.labelKeyPath = labelKeyPath;
		self.valueKeyPath = valueKeyPath;
		self.delegate = delegate;
		self.multipleSelection = NO;
		self.searchEnabled = NO;
		self.embedInNavigationController = NO;
		[self resetStatus];
	}
	
	return self;
}

- (UIPopoverController *)popoverController
{
	if (!_popoverController) {
		
		UIViewController *popoverContentViewController;
		
		contentController = [[ComboPopoverContentViewController alloc] initWithStyle:UITableViewStylePlain];
		contentController.tableView.dataSource = self;
		contentController.tableView.delegate = self;
		
		if (self.embedInNavigationController) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:contentController];
			popoverContentViewController = navigationController;
		} else {
			popoverContentViewController = contentController;
		}
		
		_popoverController = [[UIPopoverController alloc] initWithContentViewController:popoverContentViewController];
		_popoverController.delegate = self;
		
		if (self.searchEnabled) {
			searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
			searchBar.delegate = self;
			contentController.tableView.tableHeaderView = searchBar;
		}
	}
	
	return _popoverController;
}

- (void)resetStatus
{
	_selectedItemArray = [NSMutableArray array];
}

- (void)setItemArray:(NSArray *)itemArray
{
	_itemArray = itemArray;
	[self resetStatus];
	[contentController.tableView reloadData];
}

- (NSArray *)filteredItemArray
{
	NSString *searchText = searchBar.text;
	if (searchText && [searchText length]) {
		return [self.itemArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K beginswith[cd] %@", self.valueKeyPath, searchText]];
	} else {
		return self.itemArray;
	}
}

- (void)setSelectedItemArray:(NSArray *)selectedItemArray
{
	_selectedItemArray = [selectedItemArray mutableCopy];
	[contentController.tableView reloadData];
}

- (UINavigationItem *)navigationItem
{
	return contentController.navigationItem;
}

- (void)toggleFromRect:(CGRect)frame inView:(UIView *)view {
	[self toggleFromRect:frame inView:view direction:UIPopoverArrowDirectionAny];
}

- (void)toggleFromRect:(CGRect)frame inView:(UIView *)view direction:(UIPopoverArrowDirection)direction
{
	if (self.popoverController.isPopoverVisible) {
		[self.popoverController dismissPopoverAnimated:YES];
	} else {
		[self.popoverController presentPopoverFromRect:frame
												inView:view
							  permittedArrowDirections:direction
											  animated:YES];
		[contentController.tableView reloadData];
	}
}

- (void)dismiss
{
	if (self.popoverController.isPopoverVisible) {
		[self.popoverController dismissPopoverAnimated:YES];
	}
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.filteredItemArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ComboPopoverCell" forIndexPath:indexPath];
	
	id item = self.filteredItemArray[indexPath.row];
	cell.textLabel.text = [item valueForKeyPath:self.labelKeyPath];
	cell.accessoryType = ([self.selectedItemArray containsObject:item] && self.multipleSelection) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	id item = self.filteredItemArray[indexPath.row];
	if ([self.selectedItemArray containsObject:item]) {
		[self.selectedItemArray removeObject:item];
	} else {
		[self.selectedItemArray addObject:item];
	}
	
	[tableView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];

	if (!self.multipleSelection) {
		[self.popoverController dismissPopoverAnimated:YES];
	}

	if (self.delegate && [self.delegate respondsToSelector:@selector(comboPopover:didSelectObject:)]) {
		[self.delegate comboPopover:self didSelectObject:self.itemArray[indexPath.row]];
	}
}

#pragma mark - UIPopoverControllerDelegate

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	NSLog(@"%@", searchText);
	[contentController.tableView reloadData];
}

@end
