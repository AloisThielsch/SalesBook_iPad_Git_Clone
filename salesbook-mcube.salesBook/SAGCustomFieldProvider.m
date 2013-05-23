//
//  SAGCustomFieldProvider.m
//  SalesBook
//
//  Created by Frank Wittmann on 19.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SAGCustomFieldProvider.h"

#import "SAGCustomFieldProviderCell.h"

@implementation SAGCustomFieldProvider

- (id)init
{
	self = [super init];
	if (self) {
	}
	return self;
}

- (void)setTableView:(UITableView *)tableView
{
	_tableView = tableView;
	_tableView.dataSource = self;
	[_tableView registerClass:[SAGCustomFieldProviderCell class] forCellReuseIdentifier:@"customFieldProviderCell"];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.visibleData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"customFieldProviderCell" forIndexPath:indexPath];
	NSDictionary *visibleDataItem = [self.visibleData objectAtIndex:indexPath.row];
	
	cell.textLabel.text = visibleDataItem[@"label"];
	cell.detailTextLabel.text = visibleDataItem[@"value"];
	
	return cell;
}

@end
