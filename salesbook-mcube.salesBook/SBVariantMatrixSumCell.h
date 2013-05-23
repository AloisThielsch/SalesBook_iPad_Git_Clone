//
//  SBVariantMatrixSumCell.h
//  SalesBook
//
//  Created by Julian Knab on 28.02.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SBVariantMatrixSumRow, SBVariantMatrixDataCell;

@interface SBVariantMatrixSumCell : NSObject

@property int count;

@property (nonatomic, retain) SBVariantMatrixSumRow *sumRow;

@property (nonatomic, retain) NSMutableArray *underlyingDataCells;

- (void)dataCell:(SBVariantMatrixDataCell *)cell didChangeValueFrom:(int)fromValue to:(int)toValue;

@end