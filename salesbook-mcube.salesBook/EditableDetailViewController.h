//
//  EditableDetailViewController.h
//  SalesBook
//
//  Created by Frank Wittmann on 16.05.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	EditableDetailViewControllerEditingModeNew,
	EditableDetailViewControllerEditingModeExisting
} EditableDetailViewControllerEditingMode;

@interface EditableDetailViewController : UITableViewController

@property (nonatomic) EditableDetailViewControllerEditingMode editingMode;
@property (nonatomic) NSManagedObject *entity;
@property (nonatomic) BOOL providesEditing;

+ (EditableDetailViewController *)editableDetailViewController;
- (void)presentInViewController:(UIViewController *)controller;

@end
