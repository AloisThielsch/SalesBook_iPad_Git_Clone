//
//  CatalogDataProvider.h
//  SalesBook
//
//  Created by Julian Knab on 21.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CollectionViewDataProvider.h"

@class SBCatalog;

@interface CatalogsDataProvider : CollectionViewDataProvider

- (BOOL)doesRequireToDrillDown:(SBCatalog *)catalog;

@end