//
//  DetailBaseCell.h
//  SalesBook
//
//  Created by Frank Wittmann on 16.05.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EditableDetailViewTypes.h"

#import "CustomFieldData.h"

@class DetailBaseCell;

@protocol EditableDetailCellDelegate<NSObject>
@optional
- (void)detailCell:(DetailBaseCell *)detailCell didEnterValue:(id)value;
- (void)detailCellDidCancelEditing:(DetailBaseCell *)detailCell;
@end

@interface DetailBaseCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UITextField *value;
@property (nonatomic) id<EditableDetailCellDelegate> delegate;
@property (nonatomic, strong) CustomFieldData *customFieldData;

@property (nonatomic) EditableDetailViewControllerMode mode;

- (BOOL)inEditingMode;
- (BOOL)inDisplayMode;

- (void)notifyDelegateWithValue:(id)value;
- (void)notifyDelegateAboutCancel;

@end
