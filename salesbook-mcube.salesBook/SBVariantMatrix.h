//
//  SBVariantMatrix.h
//  SalesBook
//
//  Created by Julian Knab on 26.02.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SBItem.h"

#import "SBVariantMatrixSection.h"

@class SBShoppingCart;

@interface SBVariantMatrix : NSObject

@property (nonatomic, retain) SBItem *item;

@property (nonatomic, retain) SBShoppingCart *cart;

@property (nonatomic, retain) NSArray *sections;

@property (nonatomic, retain) NSArray *dimensionOneValues;
@property (nonatomic, retain) NSArray *dimensionTwoValues;

@property (nonatomic, retain) NSArray *deliveryDates;

- (id)initWithItem:(SBItem *)theItem andCart:(SBShoppingCart *)theCart;

- (int)getAmountOfDataCellAtSection:(int)section inRow:(int)row inColumn:(int)column;
- (void)setAmount:(int)amountToset ofDataCellAtSection:(int)section inRow:(int)row inColumn:(int)column;
- (void)increaseAmountOfDataCellAtSection:(int)section inRow:(int)row inColumn:(int)column by:(int)amountToIncrease;
- (void)decreaseAmountOfDataCellAtSection:(int)section inRow:(int)row inColumn:(int)column by:(int)amountToDecrease;

- (int)getAmountOfSumCellAtSection:(int)section inColumn:(int)column;

- (int)numberOfSections;
- (int)numberOfRowsInSection:(int)section;

- (int)numberOfColumns;

@end