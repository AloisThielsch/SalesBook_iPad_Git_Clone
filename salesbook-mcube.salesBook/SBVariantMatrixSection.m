//
//  SBVariantMatrixSubSection.m
//  SalesBook
//
//  Created by Julian Knab on 01.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBVariantMatrixSection.h"

#import "SBVariantMatrix.h"
#import "SBVariantMatrixDataCell.h"
#import "SBVariantMatrixDataRow.h"
#import "SBVariantMatrixSumRow.h"

#import "SBItem+Extensions.h"
#import "SBVariant+Extensions.h"

@implementation SBVariantMatrixSection

- (void)initializeWithDimensionOneValues:(NSArray *)dimensionOneValues andDimensionTwoValue:(NSString *)dimensionTwoValue forDeliveryDates:(NSArray *)deliveryDates
{
    int countRows = deliveryDates.count;

    NSMutableArray *dataRows = [[NSMutableArray alloc] initWithCapacity:countRows];

    self.deliveryDates = deliveryDates;

    for (NSDate *deliveryDate in deliveryDates)
    {
        SBVariantMatrixDataRow *dataRow = [[SBVariantMatrixDataRow alloc] init];
        dataRow.deliveryDate = deliveryDate;

        for (NSString *dimOneValue in dimensionOneValues)
        {
            SBVariant *itemVariant = [self.variantMatrix.item getVariantWithMatrixKey1:dimOneValue andMatrixKey2:dimensionTwoValue];

            SBDocumentPosition *docPos = nil;

            if (itemVariant != nil)
            {
                docPos = [self.variantMatrix.cart getPositionForItemVariant:itemVariant andDeliveryDate:deliveryDate];
                
                if (docPos == nil)
                {
                    docPos = [SBDocumentPosition MR_createInContext:itemVariant.managedObjectContext];
                    docPos.calculatedDeliveryDate = deliveryDate;
                    docPos.referencedVariant = itemVariant;
                }
            }

            SBVariantMatrixDataCell *dataCell = [[SBVariantMatrixDataCell alloc] init];
            dataCell.itemVariant = itemVariant;
            dataCell.documentPosition = docPos;
            dataCell.overlyingDataRow = dataRow;
            dataCell.matrix = self.variantMatrix;

            [dataRow.dataCells addObject:dataCell];
        }

        [dataRows addObject:dataRow];
    }

    self.dataRows = dataRows;

    SBVariantMatrixSumRow *sumRow = [[SBVariantMatrixSumRow alloc] init];
    [sumRow initWithDataRows:self.dataRows andSection:self];
    
    self.sumRow = sumRow;
}

@end