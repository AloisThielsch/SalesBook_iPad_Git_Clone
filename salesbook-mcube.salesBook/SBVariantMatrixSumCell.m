//
//  SBVariantMatrixSumCell.m
//  SalesBook
//
//  Created by Julian Knab on 28.02.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBVariantMatrixSumCell.h"
#import "SBVariantMatrixDataCell.h"

@implementation SBVariantMatrixSumCell

- (id)init
{
    self = [super init];

    self.underlyingDataCells = [[NSMutableArray alloc] init];
    self.count = 0;
    
    return self;
}

- (void)dataCell:(SBVariantMatrixDataCell *)cell didChangeValueFrom:(int)fromValue to:(int)toValue
{
    self.count -= fromValue;
    self.count += toValue;
}

@end