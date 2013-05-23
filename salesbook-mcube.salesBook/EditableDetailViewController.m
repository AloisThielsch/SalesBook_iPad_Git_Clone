//
//  EditableDetailViewController.m
//  SalesBook
//
//  Created by Frank Wittmann on 16.05.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "EditableDetailViewController.h"

#import "DetailTextFieldCell.h"
#import "DetailTextViewCell.h"
#import "DetailComboCell.h"
#import "DetailDateCell.h"
#import "DetailBoolCell.h"

#import "CustomFieldData.h"
#import "NSManagedObject+CustomFields.h"

@interface EditableDetailViewController()<UITextFieldDelegate, EditableDetailCellDelegate>
@property (nonatomic, strong) NSArray *customFieldData;
@property (nonatomic) EditableDetailViewControllerMode mode;
@property (nonatomic, getter = isValid) BOOL valid;
@end

@implementation EditableDetailViewController

+ (EditableDetailViewController *)editableDetailViewController
{
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
	EditableDetailViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"editableDetail"];
	return controller;
}

- (void)presentInViewController:(UIViewController *)controller
{
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self];
	navController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	navController.modalPresentationStyle = UIModalPresentationPageSheet;
	[controller presentViewController:navController animated:YES completion:nil];
}

- (void)commonInit
{
	_mode = EditableDetailViewControllerModeDisplay;
	_editingMode = EditableDetailViewControllerEditingModeNew;
	_entity = nil;
	_providesEditing = YES;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		[self commonInit];
    }
    return self;
}

- (void)awakeFromNib
{
	[self commonInit];
}

- (void)setEntity:(NSManagedObject *)entity
{
	_entity = entity;
	
	NSArray *customFieldDefinitions = [_entity getEditableData];
	if (_editingMode == EditableDetailViewControllerEditingModeNew) {
		[_entity setDefaultValues];
	}
	
	NSMutableArray *customFieldData = [NSMutableArray array];
//	for (NSDictionary *customFieldDefinition in customFieldDefinitions) {
//		[customFieldData addObject:[CustomFieldData customFieldDataWithDictionary:customFieldDefinition]];
//	}
	
	CustomFieldData *cfd = [[CustomFieldData alloc] init];
	cfd.fieldType = SAGCustomFieldTypeBool;
	cfd.label = @"Bin ich ein Schalter?";
	cfd.value = @NO;
	[customFieldData addObject:cfd];

	cfd = [[CustomFieldData alloc] init];
	cfd.fieldType = SAGCustomFieldTypeDate;
	cfd.label = @"Wann soll ich vorbeikommen?";
	[customFieldData addObject:cfd];

	cfd = [[CustomFieldData alloc] init];
	cfd.fieldType = SAGCustomFieldTypeSelect;
	cfd.label = @"Gender";
	cfd.uniqueID = @"SBContact.APSex";
	[customFieldData addObject:cfd];

	cfd = [[CustomFieldData alloc] init];
	cfd.fieldType = SAGCustomFieldTypeText;
	cfd.label = @"Kommentar";
	cfd.mandatory = YES;
	[customFieldData addObject:cfd];

	_customFieldData = customFieldData;
}

- (BOOL)isValid
{
	return [self validate];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self setupNavigationItems];
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.customFieldData count];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	if (self.providesEditing) {
		return self.isValid ? nil : NSLocalizedString(@"Some fields contain invalid entries.", @"Some fields contain invalid entries.");
	}
	
	return nil;
}

#pragma mark UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CustomFieldData *customFieldData = self.customFieldData[indexPath.row];
	DetailBaseCell *cell;
	
	switch (customFieldData.fieldType) {
		case SAGCustomFieldTypeBool:
			cell = [tableView dequeueReusableCellWithIdentifier:@"detailBoolCell" forIndexPath:indexPath];
			break;

		case SAGCustomFieldTypeDate:
			cell = [tableView dequeueReusableCellWithIdentifier:@"detailDateCell" forIndexPath:indexPath];
			break;

		case SAGCustomFieldTypeSelect:
			cell = [tableView dequeueReusableCellWithIdentifier:@"detailComboCell" forIndexPath:indexPath];
			break;

		case SAGCustomFieldTypeText:
		default:
			cell = [tableView dequeueReusableCellWithIdentifier:@"detailTextFieldCell" forIndexPath:indexPath];
			break;
	}

	cell.label.text = customFieldData.label;
	cell.valueLabel.text = [customFieldData displayValue];
	cell.mode = self.mode;

	cell.value.text = [customFieldData displayValue];
	cell.value.tag = indexPath.row;
	
	cell.customFieldData = customFieldData;
	cell.delegate = self;
	
	if (self.providesEditing) {
		cell.imageView.image = customFieldData.isValid ? nil : [UIImage imageNamed:@"bullet_red.png"];
		cell.label.textColor = customFieldData.isValid ? [UIColor darkTextColor] : RGB(0x99, 0x00, 0x00);
	}
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CustomFieldData *customFieldData = self.customFieldData[indexPath.row];

	switch (customFieldData.fieldType) {
		case SAGCustomFieldTypeText:
		case SAGCustomFieldTypeDate:
		case SAGCustomFieldTypeBool:
			return 44.0;
			break;
			
		default:
			return 44.0;
			break;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//	CustomFieldData *customFieldData = self.customFieldData[indexPath.row];
//	[self becomeFirstResponder];
}

#pragma mark - EditableDetailCellDelegate

- (void)detailCell:(DetailBaseCell *)detailCell didEnterValue:(id)value
{
	NSLog(@"cell %@ did provide value %@", detailCell, value);
	detailCell.customFieldData.value = value;
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
//	[self.tableView reloadRowsAtIndexPaths:@[ [self.tableView indexPathForCell:detailCell] ] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)detailCellDidCancelEditing:(DetailBaseCell *)detailCell
{
	NSLog(@"cell %@ did cancel editing", detailCell);
}

#pragma mark - Helpers

- (BOOL)inEditingMode
{
	return self.mode == EditableDetailViewControllerModeEditing;
}

- (BOOL)inDisplayMode
{
	return self.mode == EditableDetailViewControllerModeDisplay;
}

- (void)toggleMode
{
	_mode = [self inDisplayMode] ? EditableDetailViewControllerModeEditing : EditableDetailViewControllerModeDisplay;
	
	[self setupNavigationItems];
	[self.tableView reloadData];
}

- (void)setupNavigationItems
{
	if ([self inDisplayMode]) {
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close"
																				 style:UIBarButtonItemStyleBordered
																				target:self
																				action:@selector(closeTapped:)];
		if (self.providesEditing) {
			self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
																								   target:self
																								   action:@selector(editTapped:)];
		}
	} else if ([self inEditingMode]) {
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																							  target:self
																							  action:@selector(cancelTapped:)];
		if (self.providesEditing) {
			self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																								   target:self
																								   action:@selector(doneTapped:)];
		}
	}
}

- (void)closeTapped:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)editTapped:(id)sender
{
	[self toggleMode];
}

- (void)cancelTapped:(id)sender
{
	[self toggleMode];
}

- (void)doneTapped:(id)sender
{
	if (self.isValid) {
		[self toggleMode];
	} else {
		[self.tableView reloadData];
	}
}

- (BOOL)validate
{
	__block BOOL isValid = YES;
	
	[self.customFieldData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		CustomFieldData *item = (CustomFieldData *)obj;
		if (![item validateWithCurrentValue]) {
			NSLog(@"%@ failed validation", item.label);
			isValid = NO;
			*stop = YES;
		}
	}];
	
	return isValid;
}

@end
