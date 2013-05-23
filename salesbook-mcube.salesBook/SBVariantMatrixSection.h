//
//  SBVariantMatrixSubSection.h
//  SalesBook
//
//  Created by Julian Knab on 01.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SBDocumentPosition+Extensions.h"

@class SBVariantMatrix, SBVariantMatrixSumRow;

@interface SBVariantMatrixSection : NSObject

@property (nonatomic, retain) NSArray *deliveryDates;
@property (nonatomic, retain) SBVariantMatrix *variantMatrix;

@property (nonatomic, retain) NSArray *dataRows;
@property (nonatomic, retain) SBVariantMatrixSumRow *sumRow;

- (void)initializeWithDimensionOneValues:(NSArray *)dimensionOneValues andDimensionTwoValue:(NSString *)dimensionTwoValue forDeliveryDates:(NSArray *)deliveryDates;

@end