//
//  SBVariantMatrix.m
//  SalesBook
//
//  Created by Julian Knab on 26.02.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBVariantMatrix.h"

#import "SBItem+Extensions.h"

#import "SBVariantMatrixDataCell.h"
#import "SBVariantMatrixDataRow.h"

#import "SBVariantMatrixSumCell.h"
#import "SBVariantMatrixSumRow.h"

#import "NSDate+Extensions.h"

@interface SBVariantMatrix (private)

- (NSDate *)getDateForHalf:(int)half ofMonth:(int)month andYear:(int)year;
- (NSArray *)getDeliveryDatesBetween:(NSDate *)date1 and:(NSDate *)date2;

- (void)setAmount:(int)amountToset ofSumCellAtSection:(int)section inColumn:(int)column;

@end

@implementation SBVariantMatrix

- (id)initWithItem:(SBItem *)theItem andCart:(SBShoppingCart *)theCart
{
    self.item = theItem;
    self.cart = theCart;

//    NSString *strDate1 = @"11.04.2013";
//    NSString *strDate2 = @"26.06.2013";
//
//    NSDateFormatter *df = [NSDateFormatter new];
//    [df setDateFormat:@"dd.MM.yyyy"];
//
//    NSDate *date1 = [df dateFromString:strDate1];
//    NSDate *date2 = [df dateFromString:strDate2];
//
//    self.deliveryDates = [self getDeliveryDatesBetween:date1 and:date2];

    self.dimensionOneValues = [theItem getMatrixKey1Values];
    self.dimensionTwoValues = [theItem getMatrixKey2Values];
//    self.dimensionOneValues = [self getAttributesWithKey:self.item.matrixKeyFor1stDimension];
//    self.dimensionTwoValues = [self getAttributesWithKey:self.item.matrixKeyFor2ndDimension];

    [self prepareSections];
    
    return self;
}

- (void)prepareSections
{
    NSMutableArray *sections = [NSMutableArray new];

    int count = self.dimensionTwoValues.count;

    for (int i = 0; i < count; i++)
    {
        NSString *dimTwoValue = self.dimensionTwoValues[i];

        NSDate *date1 = [self.item earliestDeliveryDateWithMatrix2Value:dimTwoValue];
        NSDate *date2 = [self.item latestDeliveryDateWithMatrix2Value:dimTwoValue];

        NSArray *dates = [self getDeliveryDatesBetween:date1 and:date2];

        SBVariantMatrixSection *section = [SBVariantMatrixSection new];
        section.variantMatrix = self;

        [section initializeWithDimensionOneValues:self.dimensionOneValues andDimensionTwoValue:dimTwoValue forDeliveryDates:dates];
        [sections addObject:section];
    }

    self.sections = sections;
}

- (NSArray *)getDeliveryDatesBetween:(NSDate *)date1 and:(NSDate *)date2
{
    if ([date1 earlierDate:date2] != date1)
    {
        @throw [NSException exceptionWithName:@"VariantMatrixException" reason:@"date1 > date2 is not allowed in 'getDeliveryDatesBetween:date1 and:date2' method" userInfo:nil];
    }

    NSMutableArray *dates = [NSMutableArray new];

    int year1 = date1.year;
    int year2 = date2.year;

    int month1 = date1.month;
    int month2 = date2.month;

    BOOL needToSwitchYear = year1 < year2;

    BOOL isFirstYearDone = NO;

    NSDate *now = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:now];
    [components setHour:0], [components setMinute:0], [components setSecond:0];
    NSDate *todayAtMidnight = [calendar dateFromComponents:components];

    [dates addObject:todayAtMidnight];

    for (int year = year1; year <= year2; year++)
    {
        int monthLoopStart = (needToSwitchYear && isFirstYearDone) ? 1 : month1;
        int monthLoopLimit = (needToSwitchYear && !isFirstYearDone) ? 12 : month2;

        for (int month = monthLoopStart; month <= monthLoopLimit; month++)
        {
            BOOL b = (month == month1 && date1.halfOfMonth == 2 && ((needToSwitchYear && !isFirstYearDone) || !needToSwitchYear)) ? 1 : 0;

            do
            {
                NSDate *date = [self getDateForHalf:b+1 ofMonth:month andYear:year];

                if (date == [date laterDate:now])
                {
                    [dates addObject:date];
                }

                if (month == month2 && date2.halfOfMonth == b+1 && ((needToSwitchYear && isFirstYearDone) || !needToSwitchYear)) break;

                b = !b;

            } while (b);
        }

        if (needToSwitchYear) isFirstYearDone = YES;
    }

    return dates;
}

- (NSDate *)getDateForHalf:(int)half ofMonth:(int)month andYear:(int)year
{
    NSDateComponents *comp = [NSDateComponents new];

    comp.year = year;
    comp.month = month;
    comp.day = (half == 1) ? 1 : 16;

    comp.hour = 0;
    comp.minute = 0;
    comp.second = 0;

    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

    NSDate *date = [gregorian dateFromComponents:comp];

    return date;
}

- (NSArray *)getValuesForKey:(NSString *)theKey
{
    NSEntityDescription *ed = [SBVariant MR_entityDescription];

    if ([[ed propertiesByName] objectForKey:theKey] != nil)
    {
        return [self getPropertiesWithKey:theKey];
    }

    return [self getAttributesWithKey:theKey];
}

- (NSArray *)getPropertiesWithKey:(NSString *)theKey
{
    NSMutableArray *properties = [NSMutableArray new];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.returnsDistinctResults = YES;
    fetchRequest.resultType = NSDictionaryResultType;

    NSManagedObjectContext *context = self.item.managedObjectContext;

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SBVariant" inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self IN %@", self.item.variants];
    NSArray *props = [NSArray arrayWithObjects:theKey, nil];

    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setPropertiesToFetch:props];

    NSError *error = nil;

    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];

    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:theKey ascending:YES];

    NSArray *sortedObjects = [fetchedObjects sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];

    for (NSDictionary *dict in sortedObjects)
    {
        [properties addObject:[dict objectForKey:theKey]];
    }

    return properties;
}

- (NSArray *)getAttributesWithKey:(NSString *)theKey
{
    NSMutableArray *attributes = [NSMutableArray new];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.returnsDistinctResults = YES;
    fetchRequest.resultType = NSDictionaryResultType;
    
    NSManagedObjectContext *context = self.item.managedObjectContext;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SBAttribute" inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"variant IN %@ AND theKey == %@", self.item.variants, theKey];
    NSArray *props = [NSArray arrayWithObjects:@"theValue", nil];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setPropertiesToFetch:props];
    
    NSError *error = nil;
    
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"theValue" ascending:YES];
    
    NSArray *sortedObjects = [fetchedObjects sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    
    for (NSDictionary *dict in sortedObjects)
    {
        [attributes addObject:[dict objectForKey:@"theValue"]];
    }
    
    return attributes;
}

- (int)getAmountOfDataCellAtSection:(int)sectionNo inRow:(int)rowNo inColumn:(int)columnNo
{
    SBVariantMatrixDataCell *dataCell = [self getDataCellAtSection:sectionNo inRow:rowNo inColumn:columnNo];
    
    int amount = dataCell.getAmount;
    return amount;
}

- (void)setAmount:(int)amountToset ofDataCellAtSection:(int)sectionNo inRow:(int)rowNo inColumn:(int)columnNo
{
    SBVariantMatrixDataCell *dataCell = [self getDataCellAtSection:sectionNo inRow:rowNo inColumn:columnNo];
    [dataCell setAmount:amountToset];
}

- (void)increaseAmountOfDataCellAtSection:(int)sectionNo inRow:(int)rowNo inColumn:(int)columnNo by:(int)amountToIncrease
{
    SBVariantMatrixDataCell *dataCell = [self getDataCellAtSection:sectionNo inRow:rowNo inColumn:columnNo];
    [dataCell increaseAmountBy:amountToIncrease];
}

- (void)decreaseAmountOfDataCellAtSection:(int)sectionNo inRow:(int)rowNo inColumn:(int)columnNo by:(int)amountToDecrease
{
    SBVariantMatrixDataCell *dataCell = [self getDataCellAtSection:sectionNo inRow:rowNo inColumn:columnNo];
    [dataCell decreaseAmountBy:amountToDecrease];
}

- (int)getAmountOfSumCellAtSection:(int)sectionNo inColumn:(int)columnNo
{
    SBVariantMatrixSumCell *sumCell = [self getSumCellAtSection:sectionNo inColumn:columnNo];
    int amount = sumCell.count;
    return amount;
}

- (SBVariantMatrixDataCell *)getDataCellAtSection:(int)sectionNo inRow:(int)rowNo inColumn:(int)columnNo
{
    SBVariantMatrixSection *section = self.sections[sectionNo];
    SBVariantMatrixDataRow *dataRow = section.dataRows[rowNo];
    SBVariantMatrixDataCell *dataCell = dataRow.dataCells[columnNo];

    return dataCell;
}

- (SBVariantMatrixSumCell *)getSumCellAtSection:(int)sectionNo inColumn:(int)columnNo
{
    SBVariantMatrixSection *section = self.sections[sectionNo];
    SBVariantMatrixSumCell *sumCell = section.sumRow.sumCells[columnNo];

    return sumCell;
}

- (int)numberOfSections
{
    int count = self.sections.count;
    return count;
}

- (int)numberOfRowsInSection:(int)sectionNo
{
    SBVariantMatrixSection *section = self.sections[sectionNo];
    int count = section.dataRows.count + 1; // the + 1 is for the sum row
    return count;
}

- (int)numberOfColumns
{
    int count = self.dimensionOneValues.count;
    return count;
}

@end