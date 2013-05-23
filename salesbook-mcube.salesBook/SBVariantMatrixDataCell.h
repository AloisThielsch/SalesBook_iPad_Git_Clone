//
//  SBVariantMatrixDataCell.h
//  SalesBook
//
//  Created by Julian Knab on 28.02.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SBDocumentPosition+Extensions.h"

#import "SBVariantMatrixSumCell.h"

@class SBVariant, SBVariantMatrix, SBVariantMatrixDataRow;

@interface SBVariantMatrixDataCell : NSObject

@property (nonatomic, retain) SBVariantMatrixSumCell *correspondingSumCell;
@property (nonatomic, retain) SBDocumentPosition *documentPosition;
@property (nonatomic, retain) SBVariant *itemVariant;
@property (nonatomic, retain) SBVariantMatrix *matrix;
@property (nonatomic, retain) SBVariantMatrixDataRow *overlyingDataRow;

- (int)getAmount;
- (void)setAmount:(int)amount;
- (void)increaseAmountBy:(int)amount;
- (void)decreaseAmountBy:(int)amount;

@end