//
//  SBVariantMatrixSumRow.h
//  SalesBook
//
//  Created by Julian Knab on 28.02.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SBVariantMatrixSection.h"
#import "SBVariantMatrixSumCell.h"

@class SBVariantMatrixSection;

@interface SBVariantMatrixSumRow : NSObject

@property (nonatomic, retain) SBVariantMatrixSection *section;

@property (nonatomic, retain) NSArray *sumCells;

- (void)initWithDataRows:(NSArray *)dataRows andSection:(SBVariantMatrixSection *)subSection;

@end