//
//  DetailDateCell.m
//  SalesBook
//
//  Created by Frank Wittmann on 16.05.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "DetailDateCell.h"

@interface DetailDateCell() {
	UITapGestureRecognizer *_recognizer;
	UIDatePicker *_datePicker;
}
@property (nonatomic, strong) UIPopoverController *popoverController;
@end

@implementation DetailDateCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setMode:(EditableDetailViewControllerMode)mode
{
	[super setMode:mode];
	_recognizer.enabled = [self inEditingMode];
	self.accessoryType = [self inEditingMode] ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
	self.value.hidden = YES;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	if (!_recognizer) {
		_recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openSelection:)];
		_recognizer.enabled = [self inEditingMode];
		[self.contentView addGestureRecognizer:_recognizer];
	}
	
	if (!_popoverController) {
		UIViewController *contentController = [[UIViewController alloc] init];
		_datePicker = [[UIDatePicker alloc] init];
		_datePicker.datePickerMode = UIDatePickerModeDate;
		contentController.view = _datePicker;
		contentController.contentSizeForViewInPopover = _datePicker.frame.size;
		contentController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																										   target:self
																										   action:@selector(cancelSelection:)];
		contentController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																											target:self
																											action:@selector(useSelection:)];
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:contentController];
		_popoverController = [[UIPopoverController alloc] initWithContentViewController:navigationController];
	}
}

- (void)openSelection:(UITapGestureRecognizer *)recognizer
{
	if ([_popoverController isPopoverVisible]) {
		[_popoverController dismissPopoverAnimated:YES];
		[self notifyDelegateAboutCancel];
	} else {
		[_popoverController presentPopoverFromRect:self.contentView.frame
											inView:self.contentView
						  permittedArrowDirections:UIPopoverArrowDirectionLeft
										  animated:YES];
	}
}

- (void)cancelSelection:(id)sender
{
	[_popoverController dismissPopoverAnimated:YES];
	[self notifyDelegateAboutCancel];
}

- (void)useSelection:(id)sender
{
	[_popoverController dismissPopoverAnimated:YES];
	[self notifyDelegateWithValue:_datePicker.date];
}

@end
