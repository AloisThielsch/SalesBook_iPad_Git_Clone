//
//  SBVariantMatrixDataRow.h
//  SalesBook
//
//  Created by Julian Knab on 28.02.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SBVariantMatrixSumCell;

@interface SBVariantMatrixDataRow : NSObject

@property (nonatomic, retain) NSDate *deliveryDate;

@property (nonatomic, retain) NSMutableArray *dataCells;

@end