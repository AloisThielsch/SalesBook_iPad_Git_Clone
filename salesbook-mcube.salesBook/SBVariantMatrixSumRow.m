//
//  SBVariantMatrixSumRow.m
//  SalesBook
//
//  Created by Julian Knab on 28.02.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBVariantMatrix.h"
#import "SBVariantMatrixDataCell.h"
#import "SBVariantMatrixDataRow.h"
#import "SBVariantMatrixSection.h"
#import "SBVariantMatrixSumRow.h"

@implementation SBVariantMatrixSumRow

- (void)initWithDataRows:(NSArray *)dataRows andSection:(SBVariantMatrixSection *)section
{
    self.section = section;
    section.sumRow = self;

    int countCols = section.variantMatrix.dimensionOneValues.count;
    int countRows = dataRows.count;

    NSMutableArray *sumCells = [[NSMutableArray alloc] initWithCapacity:countCols];

    for (int i = 0; i < countCols; i++)
    {
        SBVariantMatrixSumCell *sumCell = [[SBVariantMatrixSumCell alloc] init];

        for (int j = 0; j < countRows; j++)
        {
            SBVariantMatrixDataRow *dataRow = [dataRows objectAtIndex:j];

            SBVariantMatrixDataCell *dataCell = [dataRow.dataCells objectAtIndex:i];

            dataCell.correspondingSumCell = sumCell;
            
            sumCell.count += dataCell.documentPosition.amount.intValue;
            sumCell.sumRow = self;
            
            [sumCell.underlyingDataCells addObject:dataCell];
        }

        [sumCells addObject:sumCell];
    }

    self.sumCells = sumCells;
}

@end