//
//  DetailBaseCell.m
//  SalesBook
//
//  Created by Frank Wittmann on 16.05.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "DetailBaseCell.h"

@implementation DetailBaseCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		self.mode = EditableDetailViewControllerModeDisplay;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (BOOL)inEditingMode
{
	return self.mode == EditableDetailViewControllerModeEditing;
}

- (BOOL)inDisplayMode
{
	return self.mode == EditableDetailViewControllerModeDisplay;
}

- (void)notifyDelegateWithValue:(id)value
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(detailCell:didEnterValue:)]) {
		[self.delegate detailCell:self didEnterValue:value];
	}
}

- (void)notifyDelegateAboutCancel
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(detailCellDidCancelEditing:)]) {
		[self.delegate detailCellDidCancelEditing:self];
	}
}

@end
