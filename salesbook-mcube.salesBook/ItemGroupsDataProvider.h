//
//  ItemGroupsItemGroupsDataProvider.h
//  SalesBook
//
//  Created by Julian Knab on 26.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CollectionViewDataProvider.h"

@class SBItemGroup;

@interface ItemGroupsDataProvider : CollectionViewDataProvider

- (BOOL)doesRequireToDrillDown:(SBItemGroup *)itemGroup;

@end