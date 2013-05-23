//
//  VariantDataProvider.h
//  SalesBook
//
//  Created by Julian Knab on 25.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CollectionViewDataProvider.h"

@class SBItem, SBVariant;

@interface ItemsDataProvider : CollectionViewDataProvider

- (UIImage *)prepareImageForSmallCardCellAtIndexPath:(NSIndexPath *)indexPath withVariant:(SBVariant *)variant;
- (UIImage *)prepareImageForLongRowCellAtIndexPath:(NSIndexPath *)indexPath withVariant:(SBVariant *)variant;

@end