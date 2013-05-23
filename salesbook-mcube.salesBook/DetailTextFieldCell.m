//
//  DetailTextFieldCell.m
//  SalesBook
//
//  Created by Frank Wittmann on 16.05.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "DetailTextFieldCell.h"

@interface DetailTextFieldCell()<UITextFieldDelegate>
@end

@implementation DetailTextFieldCell

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
	self.valueLabel.hidden = [self inEditingMode];
	self.value.hidden = [self inDisplayMode];
	self.value.delegate = self;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	self.customFieldData.value = textField.text;
	[textField resignFirstResponder];
	[self notifyDelegateWithValue:textField.text];
	return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
	NSLog(@"Did end editing");
}

@end
