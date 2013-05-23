//
//  FilterListViewController.h
//  SalesBook
//
//  Created by Frank Wittmann on 07.05.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterListViewController : UITableViewController

@property (nonatomic, strong) NSString *entityName;
@property (nonatomic, strong) NSArray *filterArray;

@end
