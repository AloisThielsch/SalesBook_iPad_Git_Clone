//
//  SBVariantMatrixDataCell.m
//  SalesBook
//
//  Created by Julian Knab on 28.02.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBVariantMatrixDataCell.h"

#import "SBVariantMatrix.h"

#import "SBShoppingCart+Extensions.h"

@implementation SBVariantMatrixDataCell

- (int)getAmount
{
    return self.documentPosition.amount.intValue;
}

- (void)setAmount:(int)amount
{
    if (amount < 0)
    {
        @throw [NSException exceptionWithName:@"VariantMatrixException" reason:@"amount of a documentPosition mustn't be negative" userInfo:nil];
    }

    int old = [self getAmount];

    self.documentPosition.amount = [NSNumber numberWithInt:amount];

    if (old == 0 && amount != old)
    {
        [self.matrix.cart addPositionsObject:self.documentPosition];
    }
    else if (amount == 0)
    {
        [self.matrix.cart removePositionsObject:self.documentPosition];
    }

    [self.correspondingSumCell dataCell:self didChangeValueFrom:old to:amount];
}

- (void)increaseAmountBy:(int)amount
{
    int old = [self getAmount];

    int new = old+amount;

    [self setAmount:new];
}

- (void)decreaseAmountBy:(int)amount
{
    int old = [self getAmount];

    int new = old-amount < 0 ? 0 : old-amount;

    [self setAmount:new];
}

@end