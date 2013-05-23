//
//  SBVariantMatrixDataRow.m
//  SalesBook
//
//  Created by Julian Knab on 28.02.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBVariantMatrixDataRow.h"

@implementation SBVariantMatrixDataRow

- (id)init
{
    self = [super init];
    self.dataCells = [NSMutableArray new];
    return self;
}

@end