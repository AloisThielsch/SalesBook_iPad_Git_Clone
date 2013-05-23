//
//  SAGCustomFieldProvider.h
//  SalesBook
//
//  Created by Frank Wittmann on 19.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SAGCustomFieldProvider : NSObject<UITableViewDataSource>

@property (nonatomic, strong) NSArray *visibleData;			 // of NSDictionaries from getVisibleData
@property (nonatomic, weak) IBOutlet UITableView *tableView; // associated table view

@end
