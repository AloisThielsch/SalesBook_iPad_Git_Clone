//
//  SBVariantMatrixInfoProvider.m
//  SalesBook
//
//  Created by Julian Knab on 24.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBVariantMatrixInfoProvider.h"

#import "SBItem+Extensions.h"
#import "SBVariant+Extensions.h"

@implementation SBVariantMatrixInfoProvider

- (id)initWithVariant:(SBVariant *)variant
{
    if (self = [super init])
    {
        self.info = [variant getVisibleData];
    }
    
    return self;
}

- (id)initWithItem:(SBItem *)item
{
    if (self = [super init])
    {
        self.info = [item getVisibleData];
    }

    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.info.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"variantMatrixInfoCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];

    NSDictionary *dict = self.info[indexPath.row];

    cell.textLabel.text = [dict objectForKey:@"value"];
    cell.detailTextLabel.text = [dict objectForKey:@"label"];

    return cell;
}

@end