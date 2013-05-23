//
//  DetailComboCell.m
//  SalesBook
//
//  Created by Frank Wittmann on 16.05.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "DetailComboCell.h"

#import "ComboPopover.h"

@interface DetailComboCell()<ComboPopoverDelegate> {
	UITapGestureRecognizer *_recognizer;
}
@property (nonatomic, strong) ComboPopover *comboPopover;
@end

@implementation DetailComboCell

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
	
	if (!_comboPopover) {
		_comboPopover = [[ComboPopover alloc] initWithItemArray:self.customFieldData.value labelKeyPath:@"label" valueKeyPath:@"value" delegate:self];
		_comboPopover.embedInNavigationController = YES;
	}
}

- (void)openSelection:(UITapGestureRecognizer *)recognizer
{
	[self.comboPopover toggleFromRect:self.contentView.frame inView:self.contentView direction:UIPopoverArrowDirectionLeft];

	self.comboPopover.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																									   target:self
																									   action:@selector(cancelSelection:)];
	self.comboPopover.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																										target:self
																										action:@selector(useSelection:)];
}

- (void)useSelection:(id)sender
{
	[self.comboPopover dismiss];
	[self notifyDelegateWithValue:self.comboPopover.selectedItemArray];
}

- (void)cancelSelection:(id)sender
{
	[self.comboPopover dismiss];
	[self notifyDelegateAboutCancel];
}

#pragma mark ComboPopoverDelegate

- (void)comboPopover:(ComboPopover *)comboPopover didSelectObject:(id)object
{
	[self notifyDelegateWithValue:object];
}

- (void)didDismissComboPopover:(ComboPopover *)comboPopover
{
	[self notifyDelegateAboutCancel];
}

@end
