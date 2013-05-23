//
//  FilterManagerViewController.m
//  SalesBook
//
//  Created by Frank Wittmann on 07.05.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "FilterManagerViewController.h"

#import "SBFilterLevel+Extensions.h"
#import "SBCustomField+Extensions.h"

#import "SAGFilterManager.h"

#import "ComboPopover.h"

@interface FilterManagerViewController()<UITableViewDataSource, UITableViewDelegate, ComboPopoverDelegate>
@property (nonatomic, strong) NSString *entityName;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *textFieldKey;
@property (weak, nonatomic) IBOutlet UITextField *textFieldValue;
@property (weak, nonatomic) IBOutlet UIButton *buttonAddChange;

@property (weak, nonatomic) IBOutlet UITextField *textFieldFilterName;
@property (weak, nonatomic) IBOutlet UIButton *buttonSaveFilter;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *titleItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *edit;

@property (nonatomic, strong) ComboPopover *keyComboPopover;
@property (nonatomic, strong) ComboPopover *valueComboPopover;
@property (nonatomic, strong) NSString *selectedKey;
@property (nonatomic, strong) NSArray *selectedValues;
@property (nonatomic) FilterManagerEditingMode currentCellEditingMode;
@property (nonatomic, weak) SBFilterLevel *currentLevel;
@end

BOOL isEditing;

@implementation FilterManagerViewController

+ (FilterManagerViewController *)filterManagerViewControllerForEntityName:(NSString *)entityName
{
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FilterManager"
														 bundle:nil];
	FilterManagerViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"FilterManager"];
	controller.entityName = entityName;

	return controller;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
//	[SBFilter MR_truncateAll];
//	[SBFilterLevel MR_truncateAll];
//	[[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
    
	self.selectedValues = [NSArray array];
	self.currentCellEditingMode = FilterManagerEditingModeNew;
	
	self.titleItem.title = self.textFieldFilterName.text = self.filter.name;
	[self.tableView reloadData];
}

- (IBAction)close:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (SBFilter *)filter
{
	if (!_filter) {
		_filter = [SBFilter filterWithTargetEntity:self.entityName andName:nil];
	}
	return _filter;
}

- (void)setSelectedKey:(NSString *)selectedKey
{
	_selectedKey = selectedKey;
    
	NSArray *itemArray = [self.filter distinctValuesForKey:selectedKey];
    
	self.textFieldKey.text = [[SBCustomField getCustomFieldWithTargetEntity:self.filter.targetEntity andKey:selectedKey] label];
    self.textFieldValue.text = @"";
    
    self.currentLevel = [self.filter filterlevelforKey:selectedKey];
    
    if (self.currentLevel)
    {
        self.selectedValues = self.currentLevel.theValue;
        self.currentCellEditingMode = FilterManagerEditingModeExisting;
    }
    else
    {
        self.selectedValues = [NSArray array];
        self.currentCellEditingMode = FilterManagerEditingModeNew;
    }
    
	self.valueComboPopover.itemArray = itemArray;
	self.valueComboPopover.selectedItemArray = self.currentLevel.theValue;
}

- (void)setSelectedValues:(NSArray *)selectedValues
{
	_selectedValues = selectedValues;
	
	NSArray *selectedValueTexts = [selectedValues valueForKeyPath:@"value"];
	NSString *selectedValueString = [selectedValueTexts componentsJoinedByString:@", "];
	
	self.textFieldValue.text = selectedValueString;
}

- (void)setCurrentCellEditingMode:(FilterManagerEditingMode)currentCellEditingMode
{
	_currentCellEditingMode = currentCellEditingMode;
	NSString *buttonTitle;

	switch (currentCellEditingMode) {
		case FilterManagerEditingModeNew:
			buttonTitle = NSLocalizedString(@"Add", @"Add");
		default:
			break;
			
		case FilterManagerEditingModeExisting:
			buttonTitle = NSLocalizedString(@"Update", @"Update");
			break;
	}

	[self.buttonAddChange setTitle:buttonTitle forState:UIControlStateNormal];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.filter.levels count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"FilterLevelCell"
																 forIndexPath:indexPath];
	
	SBFilterLevel *level = [self.filter.levels objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [[SBCustomField getCustomFieldWithTargetEntity:self.filter.targetEntity andKey:level.theKey] label];

#if TARGET_IPHONE_SIMULATOR
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%u)", [level.theLabels componentsJoinedByString:@", "], level.type.unsignedIntValue];
#else
    cell.detailTextLabel.text = [level.theLabels componentsJoinedByString:@", "];
#endif
    
    if (level.type.unsignedIntValue == 0)
    {
        cell.detailTextLabel.textColor = [UIColor grayColor];
    }
    else
    {
        cell.detailTextLabel.textColor = RGB(56, 84, 135);
    }
	
	return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	self.selectedKey = [[self.filter.levels objectAtIndex:indexPath.row] theKey];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self.filter removeFilterAtLevel:indexPath.row];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        self.selectedKey = nil;
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (IBAction)switchEditMode:(UIBarButtonItem *)sender
{
    isEditing = !isEditing;
    
    [self.tableView setEditing:isEditing animated:YES];
    [self.filter saveFilter];
    [self.tableView reloadData];
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [self.filter moveFilterLevelAtIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
}

#pragma mark - Other

- (IBAction)keyFieldTapped:(id)sender
{
	if (!_keyComboPopover)
    {
		_keyComboPopover = [[ComboPopover alloc] initWithItemArray:[self.filter availableKeys]
													  labelKeyPath:@"label"
													  valueKeyPath:@"self"
														  delegate:self];
	}
	
	[self.keyComboPopover toggleFromRect:self.textFieldKey.frame inView:self.view];
}

- (IBAction)valueFieldTapped:(id)sender
{
	if (self.selectedKey)
    {
		NSArray *itemArray = [self.filter distinctValuesForKey:self.selectedKey];
		NSMutableArray *selectedItemArray = self.currentLevel ? self.currentLevel.theValue : [NSMutableArray array];
		if (!_valueComboPopover) {
			_valueComboPopover = [[ComboPopover alloc] initWithItemArray:itemArray
															labelKeyPath:@"label"
															valueKeyPath:@"value"
																delegate:self];
			_valueComboPopover.multipleSelection = YES;
			_valueComboPopover.searchEnabled = YES;
			_valueComboPopover.selectedItemArray = selectedItemArray;
		} else {
			self.valueComboPopover.itemArray = itemArray;
			self.valueComboPopover.selectedItemArray = selectedItemArray;
		}
		
		[self.valueComboPopover toggleFromRect:self.textFieldValue.frame inView:self.view];
	}
}

- (IBAction)saveButtonTapped:(id)sender
{
	if (self.currentCellEditingMode == FilterManagerEditingModeExisting)
    {
        [self.filter addFilterLevelWithValues:self.selectedValues andKey:self.selectedKey]; //Egal ob Edit immer den hier nehmen!
	}
    else if (self.currentCellEditingMode == FilterManagerEditingModeNew)
    {
		[self.filter addFilterLevelWithValues:self.selectedValues andKey:self.selectedKey];
	}
	
	self.selectedKey = nil;
	self.selectedValues = nil;
	self.currentCellEditingMode = FilterManagerEditingModeNew;

	[self.tableView reloadData];
}

- (IBAction)saveFilterButtonTapped:(id)sender {
	NSString *filterName = self.textFieldFilterName.text;
	
	if (filterName && ![filterName isEqualToString:@""]) {
		self.filter.name = filterName;
		[self.filter saveFilter];
		[self dismissViewControllerAnimated:YES completion:^{
			[[NSNotificationCenter defaultCenter] postNotificationName:notificationFilterEdited object:self];
		}];
	} else {
		[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Filter Manager", @"Filter Manager")
									message:NSLocalizedString(@"Please provide a filter name", @"Please provide a filter name")
								   delegate:nil
						  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
						  otherButtonTitles:nil] show];
	}
}

#pragma mark - ComboPopoverDelegate

- (void)comboPopover:(ComboPopover *)comboPopover didSelectObject:(id)object
{
	if ([comboPopover isEqual:self.keyComboPopover])
    {
        self.selectedKey = [object valueForKeyPath:@"key"];
	}
    else if ([comboPopover isEqual:self.valueComboPopover])
    {
		self.selectedValues = comboPopover.selectedItemArray;
	}
}

- (void)didDismissComboPopover:(ComboPopover *)comboPopover
{
	if ([comboPopover isEqual:self.keyComboPopover]) {
	} else if ([comboPopover isEqual:self.valueComboPopover]) {
		self.selectedValues = nil;
	}
}

@end
