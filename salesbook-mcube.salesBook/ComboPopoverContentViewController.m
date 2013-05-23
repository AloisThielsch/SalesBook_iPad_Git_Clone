//
//  ComboPopoverContentViewController.m
//  SalesBook
//
//  Created by Frank Wittmann on 07.05.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "ComboPopoverContentViewController.h"

#import "ComboPopoverCell.h"

@interface ComboPopoverContentViewController()
@end

@implementation ComboPopoverContentViewController

static NSString *CellIdentifier = @"ComboPopoverCell";

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self.tableView registerClass:[ComboPopoverCell class]
		   forCellReuseIdentifier:CellIdentifier];
}

@end
