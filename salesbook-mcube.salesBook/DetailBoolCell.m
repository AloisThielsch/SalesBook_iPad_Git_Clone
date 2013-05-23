//
//  DetailBoolCell.m
//  SalesBook
//
//  Created by Frank Wittmann on 17.05.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "DetailBoolCell.h"

@implementation DetailBoolCell

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
	self.switchValue.enabled = [self inEditingMode];
}

- (void)setCustomFieldData:(CustomFieldData *)customFieldData
{
	[super setCustomFieldData:customFieldData];
	self.switchValue.on = [customFieldData.value boolValue];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	if (![self.switchValue.allTargets containsObject:self]) {
		[self.switchValue addTarget:self action:@selector(switchTapped:) forControlEvents:UIControlEventValueChanged];
	}
}

- (void)switchTapped:(UISwitch *)sender
{
	self.customFieldData.value = sender.isOn ? @YES : @NO;
	[self notifyDelegateWithValue:sender.isOn ? @YES : @NO];
}

@end
