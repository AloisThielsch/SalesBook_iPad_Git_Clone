//
//  SBShoppingCart+Extensions.m
//  SalesBook
//
//  Created by Julian Knab on 08.02.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBShoppingCart+Extensions.h"

#import "SAGMenuController.h"

#import "SBPrice+Extensions.h"

#import "SBRebateAbsolute.h"
#import "SBRebatePercental.h"

@implementation SBShoppingCart (Extensions)

//TODO: change notifications. add observer(s) to get informed about changes etc.

+ (SBShoppingCart *)createNewCart
{
    SBShoppingCart *newCart = [SBShoppingCart MR_createEntity];

    newCart.uniqueID = [NSString generateUniqueID];
    newCart.creationDate = [NSDate date];
    newCart.documentType = [NSNumber numberWithInt:30];

    newCart.earliestDeliveryDate = newCart.creationDate;

    newCart.humanReadableName = newCart.creationDate.asLocalizedString;

    newCart.customer = [[SAGMenuController defaultController] customer];

    [newCart addObserver:newCart forKeyPath:@"positions" options:NSKeyValueObservingOptionNew context:NULL];

    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];

    [[NSNotificationCenter defaultCenter] postNotificationName:notificationShoppingCartCreated object:newCart];

    return newCart;
}

+ (SBShoppingCart *)createNewCartWithName:(NSString *)cartName
{
    SBShoppingCart *newCart = [SBShoppingCart getCartWithName:cartName];

    if (newCart == nil)
    {
        newCart = [SBShoppingCart createNewCart];

        newCart.humanReadableName = cartName;
    }

    return newCart;
}

+ (SBShoppingCart *)getCartWithName:(NSString *)cartName
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"humanReadableName == %@", cartName];

    return [SBShoppingCart MR_findFirstWithPredicate:predicate];
}

- (SBDocumentPosition *)addItemVariant:(SBVariant *)variantToAdd
{
    NSString *variantNumber = variantToAdd.variantNumber;

    NSDate *deliveryDate = self.earliestDeliveryDate;

    return [SBShoppingCart addItemVariantWithNumber:variantNumber forDeliveryDate:deliveryDate toCart:self];
}

+ (SBDocumentPosition *)addItemVariant:(SBVariant *)variantToAdd toCart:(SBShoppingCart *)cartToAddTo
{
    NSString *variantNumber = variantToAdd.variantNumber;

    NSDate *deliveryDate = cartToAddTo.earliestDeliveryDate;

    return [SBShoppingCart addItemVariantWithNumber:variantNumber forDeliveryDate:deliveryDate toCart:cartToAddTo];
}

- (SBDocumentPosition *)addItemVariantWithNumber:(NSString *)variantNumber
{
    NSDate *deliveryDate = self.earliestDeliveryDate;
    
    return [SBShoppingCart addItemVariantWithNumber:variantNumber forDeliveryDate:deliveryDate toCart:self];
}

+ (SBDocumentPosition *)addItemVariantWithNumber:(NSString *)variantNumber toCart:(SBShoppingCart *)cartToAddTo
{
    NSDate *deliveryDate = cartToAddTo.earliestDeliveryDate;

    return [SBShoppingCart addItemVariantWithNumber:variantNumber forDeliveryDate:deliveryDate toCart:cartToAddTo];
}

- (SBDocumentPosition *)addItemVariant:(SBVariant *)variantToAdd forDeliveryDate:(NSDate *)deliveryDate
{
    NSString *variantNumber = variantToAdd.variantNumber;

    return [SBShoppingCart addItemVariantWithNumber:variantNumber forDeliveryDate:deliveryDate toCart:self];
}

+ (SBDocumentPosition *)addItemVariant:(SBVariant *)variantToAdd forDeliveryDate:(NSDate *)deliveryDate toCart:(SBShoppingCart *)cartToAddTo
{
    NSString *variantNumber = variantToAdd.variantNumber;

    return [SBShoppingCart addItemVariantWithNumber:variantNumber forDeliveryDate:deliveryDate toCart:cartToAddTo];
}

- (SBDocumentPosition *)addItemVariantWithNumber:(NSString *)variantNumber forDeliveryDate:(NSDate *)deliveryDate
{
    return [SBShoppingCart addItemVariantWithNumber:variantNumber forDeliveryDate:deliveryDate toCart:self];
}

+ (SBDocumentPosition *)addItemVariantWithNumber:(NSString *)variantNumber forDeliveryDate:(NSDate *)deliveryDate toCart:(SBShoppingCart *)cartToAddTo
{
    SBVariant *variant = [SBVariant getVariantWithVariantNumber:variantNumber];

    SBPrice *price = [variant getPriceForCustomerOrNil:cartToAddTo.customer];

    if (![price.currency isEqualToString:cartToAddTo.currencyCode]) return nil;

    SBDocumentPosition *position = [SBDocumentPosition getDocumentPositionForItemVariantWithNumber:variantNumber andDeliveryDate:deliveryDate fromCart:cartToAddTo];

    if (position == nil)
    {
        position = [SBDocumentPosition MR_createEntity];
        position.document = cartToAddTo;
        position.referencedVariant = variant;
        position.calculatedDeliveryDate = deliveryDate;
    }

    position.amount = [NSNumber numberWithInt:position.amount.intValue+1];

    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];

    [[NSNotificationCenter defaultCenter] postNotificationName:notificationShoppingCartChanged object:cartToAddTo];

    return position;
}

- (void)removeItemVariant:(SBVariant *)variantToRemove
{
    NSString *variantNumber = variantToRemove.variantNumber;

    NSDate *deliveryDate = self.earliestDeliveryDate;

    [SBShoppingCart removeItemVariantWithNumber:variantNumber forDeliveryDate:deliveryDate fromCart:self];
}

+ (void)removeItemVariant:(SBVariant *)variantToRemove fromCart:(SBShoppingCart *)cartToRemoveFrom
{
    NSString *variantNumber = variantToRemove.variantNumber;

    NSDate *deliveryDate = cartToRemoveFrom.earliestDeliveryDate;

    [SBShoppingCart removeItemVariantWithNumber:variantNumber forDeliveryDate:deliveryDate fromCart:cartToRemoveFrom];
}

- (void)removeItemVariantWithNumber:(NSString *)variantNumber
{
    NSDate *deliveryDate = self.earliestDeliveryDate;

    [SBShoppingCart removeItemVariantWithNumber:variantNumber forDeliveryDate:deliveryDate fromCart:self];
}

+ (void)removeItemVariantWithNumber:(NSString *)variantNumber fromCart:(SBShoppingCart *)cartToRemoveFrom
{
    NSDate *deliveryDate = cartToRemoveFrom.earliestDeliveryDate;

    [SBShoppingCart removeItemVariantWithNumber:variantNumber forDeliveryDate:deliveryDate fromCart:cartToRemoveFrom];
}

- (void)removeItemVariant:(SBVariant *)variantToRemove forDeliveryDate:(NSDate *)deliveryDate
{
    NSString *variantNumber = variantToRemove.variantNumber;

    [SBShoppingCart removeItemVariantWithNumber:variantNumber forDeliveryDate:deliveryDate fromCart:self];
}

+ (void)removeItemVariant:(SBVariant *)variantToRemove forDeliveryDate:(NSDate *)deliveryDate fromCart:(SBShoppingCart *)cartToRemoveFrom
{
    NSString *variantNumber = variantToRemove.variantNumber;

    [SBShoppingCart removeItemVariantWithNumber:variantNumber forDeliveryDate:deliveryDate fromCart:cartToRemoveFrom];
}

- (void)removeItemVariantWithNumber:(NSString *)variantNumber forDeliveryDate:(NSDate *)deliveryDate
{
    [SBShoppingCart removeItemVariantWithNumber:variantNumber forDeliveryDate:deliveryDate fromCart:self];
}

+ (void)removeItemVariantWithNumber:(NSString *)variantNumber forDeliveryDate:(NSDate *)deliveryDate fromCart:(SBShoppingCart *)cartToRemoveFrom
{
    SBDocumentPosition *position = [SBDocumentPosition getDocumentPositionForItemVariantWithNumber:variantNumber andDeliveryDate:deliveryDate fromCart:cartToRemoveFrom];

    [cartToRemoveFrom removePositionsObject:position];

    [position MR_deleteEntity];

    [[NSNotificationCenter defaultCenter] postNotificationName:notificationShoppingCartChanged object:cartToRemoveFrom];
}

- (void)removeDocumentPosition:(SBDocumentPosition *)documentPosition
{
    [SBShoppingCart removeDocumentPosition:documentPosition fromCart:self];
}

+ (void)removeDocumentPosition:(SBDocumentPosition *)documentPosition fromCart:(SBShoppingCart *)cartToRemoveFrom
{
    [cartToRemoveFrom removePositionsObject:documentPosition];

    [documentPosition MR_deleteEntity];

    [[NSNotificationCenter defaultCenter] postNotificationName:notificationShoppingCartChanged object:cartToRemoveFrom];    
}

- (SBDocumentPosition *)getPositionForItemVariant:(SBVariant *)itemVariant andDeliveryDate:(NSDate *)deliveryDate
{
    return [SBShoppingCart getPositionForItemVariant:itemVariant andDeliveryDate:deliveryDate fromCart:self];
}

+ (SBDocumentPosition *)getPositionForItemVariant:(SBVariant *)itemVariant andDeliveryDate:(NSDate *)deliveryDate fromCart:(SBShoppingCart *)cartToGetFrom
{
    NSString *variantNumber = itemVariant.variantNumber;

    return [SBShoppingCart getPositionForItemVariantWithNumber:variantNumber andDeliveryDate:deliveryDate fromCart:cartToGetFrom];
}

- (SBDocumentPosition *)getPositionForItemVariantWithNumber:(NSString *)variantNumber andDeliveryDate:(NSDate *)deliveryDate
{
    return [SBShoppingCart getPositionForItemVariantWithNumber:variantNumber andDeliveryDate:deliveryDate fromCart:self];
}

+ (SBDocumentPosition *)getPositionForItemVariantWithNumber:(NSString *)variantNumber andDeliveryDate:(NSDate *)deliveryDate fromCart:(SBShoppingCart *)cartToGetFrom
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"referencedVariant.variantNumber == %@ AND calculatedDeliveryDate == %@", variantNumber, deliveryDate];
    
    NSArray *filteredPositions = [[cartToGetFrom.positions filteredSetUsingPredicate:predicate] allObjects];
    
    SBDocumentPosition *documentPosition = nil;
    
    if (filteredPositions.count > 0)
    {
        documentPosition = filteredPositions[0];
    }
    
    return documentPosition;
}

+ (int)getTotalNumberFromAllShoppingCartsForItemVariantWithNumber:(NSString *)variantNumber betweenDeliveryDate:(NSDate *)deliveryDate1 andDeliveryDate:(NSDate *)deliveryDate2
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"referencedVariant.variantNumber == %@ AND earliestDeliveryDate >= %@ AND earliestDeliveryDate <= %@", variantNumber, deliveryDate1, deliveryDate2];

    int total = [[SBDocumentPosition MR_aggregateOperation:@"sum:" onAttribute:@"amount" withPredicate:predicate] intValue];

    return total;
}

- (int)getNumberOfPositions
{
    return self.positions.count;
}

- (int)getTotalNumberOfVariantsFromAllPositions
{
    NSNumber *sum = [self.positions valueForKeyPath:@"@sum.amount"];

    return sum.intValue;
}

- (NSDate *)getEarliestDeliveryDate
{
    NSDate *min = [self.positions valueForKeyPath:@"@min.calculatedDeliveryDate"];

    return min;
}

- (NSDate *)getLatestDeliveryDate
{
    NSDate *max = [self.positions valueForKeyPath:@"@max.calculatedDeliveryDate"];

    return max;
}

- (double)getTotalPrice
{
    double total = 0.0;

    for (SBDocumentPosition *position in self.positions)
    {
        total += [position getTotalPrice];
    }

    return total;
}

- (double)getTotalPriceWithRebate
{
    double total = [self getTotalPrice];
    
    if (!self.rebate) return total;
    
    if ([self.rebate isKindOfClass:[SBRebateAbsolute class]])
    {
        SBRebateAbsolute *rebate = (SBRebateAbsolute *)self.rebate;
        double rebateValue = rebate.value.doubleValue;
        return total - rebateValue;
    }
    else if ([self.rebate isKindOfClass:[SBRebatePercental class]])
    {
        SBRebatePercental *rebate = (SBRebatePercental *)self.rebate;
        double rebateValue = total * (rebate.percentage.doubleValue / 100);
        return total - rebateValue;
    }

    return total;
}

- (SBDocumentPosition *)setAmount:(int)amountToSet ofItemVariant:(SBVariant *)itemVariant forDeliveryDate:(NSDate *)deliveryDate
{
    NSString *variantNumber = itemVariant.variantNumber;

    return [SBShoppingCart setAmount:amountToSet ofItemVariantWithNumber:variantNumber forDeliveryDate:deliveryDate inCart:self];
}

+ (SBDocumentPosition *)setAmount:(int)amountToSet ofItemVariant:(SBVariant *)itemVariant forDeliveryDate:(NSDate *)deliveryDate inCart:(SBShoppingCart *)cartToSetIn
{
    NSString *variantNumber = itemVariant.variantNumber;

    return [SBShoppingCart setAmount:amountToSet ofItemVariantWithNumber:variantNumber forDeliveryDate:deliveryDate inCart:cartToSetIn];
}

- (SBDocumentPosition *)setAmount:(int)amountToSet ofItemVariantWithNumber:(NSString *)variantNumber forDeliveryDate:(NSDate *)deliveryDate
{
    return [SBShoppingCart setAmount:amountToSet ofItemVariantWithNumber:variantNumber forDeliveryDate:deliveryDate inCart:self];
}

+ (SBDocumentPosition *)setAmount:(int)amountToSet ofItemVariantWithNumber:(NSString *)variantNumber forDeliveryDate:(NSDate *)deliveryDate inCart:(SBShoppingCart *)cartToSetIn
{
    SBDocumentPosition *position = [cartToSetIn getPositionForItemVariantWithNumber:variantNumber andDeliveryDate:deliveryDate];

    [position setAmount:[NSNumber numberWithInt:amountToSet]];

    [[NSNotificationCenter defaultCenter] postNotificationName:notificationShoppingCartChanged object:cartToSetIn];

    return position;
}

- (SBDocumentPosition *)increaseAmountOfDocumentPosition:(SBDocumentPosition *)documentPosition by:(int)amountToIncrease
{
    int oldAmount = documentPosition.amount.intValue;

    int newAmount = oldAmount + amountToIncrease;

    [documentPosition willChangeValueForKey:@"amount"];
    
    [documentPosition setAmount:[NSNumber numberWithInt:newAmount]];
    
    [documentPosition didChangeValueForKey:@"amount"];

    [[NSNotificationCenter defaultCenter] postNotificationName:notificationShoppingCartChanged object:self];
    
    return documentPosition;
}

- (SBDocumentPosition *)decreaseAmountOfDocumentPosition:(SBDocumentPosition *)documentPosition by:(int)amountToDecrease
{
    int oldAmount = documentPosition.amount.intValue;

    int newAmount = amountToDecrease > oldAmount ? 0 : oldAmount - amountToDecrease;

    [documentPosition willChangeValueForKey:@"amount"];

    [documentPosition setAmount:[NSNumber numberWithInt:newAmount]];

    [documentPosition didChangeValueForKey:@"amount"];

    [[NSNotificationCenter defaultCenter] postNotificationName:notificationShoppingCartChanged object:self];

    return documentPosition;
}

- (SBDocumentPosition *)setAmount:(int)amountToSet ofDocumentPosition:(SBDocumentPosition *)documentPosition
{
    if (amountToSet <= 0)
    {
        [self removePositionsObject:documentPosition];
        [documentPosition MR_deleteEntity];
    }
    else
    {
        [documentPosition setAmount:[NSNumber numberWithInt:amountToSet]];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:notificationShoppingCartChanged object:self];

    return documentPosition;
}

- (void)deleteCart
{
    [SBShoppingCart deleteCart:self];
}

+ (void)deleteCart:(SBShoppingCart *)cartToDelete
{
    NSString *cartNumber = cartToDelete.uniqueID;

    [cartToDelete prepareForDelete];

    [[NSNotificationCenter defaultCenter] postNotificationName:notificationShoppingCartDeleted object:cartNumber];
}

+ (void)deleteCartWithName:(NSString *)cartName
{
    SBShoppingCart *cartToDelete = [SBShoppingCart getCartWithName:cartName];

    [SBShoppingCart deleteCart:cartToDelete];
}

- (void)renameCartToNewName:(NSString *)newName
{
    self.humanReadableName = newName;

    [[NSNotificationCenter defaultCenter] postNotificationName:notificationShoppingCartChanged object:self];
}

+ (void)renameCartWithName:(NSString *)cartName toNewName:(NSString *)newName
{
    SBShoppingCart *cartToRename = [self getCartWithName:cartName];

    [cartToRename renameCartToNewName:newName];
}

- (SBShoppingCart *)cloneCart
{
    return [SBShoppingCart cloneCart:self];
}

+ (SBShoppingCart *)cloneCart:(SBShoppingCart *)cartToClone
{
    SBShoppingCart *newCart = [SBShoppingCart createNewCart];

    NSDictionary *memberVariables = [[NSEntityDescription entityForName:@"SBShoppingCart" inManagedObjectContext:cartToClone.managedObjectContext] attributesByName];

    @try
    {
        for (NSString *mv in memberVariables)
        {
            [newCart setValue:[cartToClone valueForKey:mv] forKey:mv];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"hier batscht es!");
    }

    @try
    {
        for (SBAttribute *attr in cartToClone.attributes)
        {
            SBAttribute *newAttr = [attr cloneAttribute];

            [newCart addAttributesObject:newAttr];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"hier batscht es!");
    }

    @try
    {
        NSSet *fuckYou = cartToClone.positions;

        for (SBDocumentPosition *docPos in fuckYou)
        {
            SBDocumentPosition *newPos = [docPos clonePosition];

            [newCart addPositionsObject:newPos];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"hier batscht es!");
    }

    newCart.customer = cartToClone.customer;
    
    // IMPORTANT!
    newCart.uniqueID = [NSString generateUniqueID];
    
    newCart.humanReadableName = [NSString stringWithFormat:@"%@ (1)", cartToClone.humanReadableName];

    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];

    [[NSNotificationCenter defaultCenter] postNotificationName:notificationShoppingCartChanged object:newCart];

    return newCart;
}

- (NSArray *)splitCartAtIndex:(int)index
{
    return [SBShoppingCart splitCart:self atIndex:index];
}

+ (NSArray *)splitCart:(SBShoppingCart *)cartToSplit atIndex:(int)index
{ 
    // example: index = 3, cart with 10 positions
    //
    // 0 1 2 3 4 5 6 7 8 9
    // a b c d e f g h i j
    //     | |           |
    //     | index       |
    //     |             |
    //  index-1       count-1 (count = 10)
    //
    // after splitting:     cartToSplit     newCart
    //                      a b c           d e f g h i j

    SBShoppingCart *newCart = [cartToSplit cloneCart];

    NSArray *allPositions = [newCart.positions.allObjects sortedArrayUsingSelector:@selector(number)];

    // remove positions '0' to 'index-1' from newCart
    for (int i = 0; i < index; i++)
    {
        SBDocumentPosition *pos = [allPositions objectAtIndex:i];
        [newCart removePositionsObject:pos];
        [pos MR_deleteEntity];
    }

    allPositions = [cartToSplit.positions.allObjects sortedArrayUsingSelector:@selector(number)];

    int count = allPositions.count;

    // remove positions 'index' to 'count-1' from cartToSplit
    for (int i = index; i < count; i++)
    {
        SBDocumentPosition *pos = [allPositions objectAtIndex:i];
        [cartToSplit removePositionsObject:pos];
        [pos MR_deleteEntity];
    }

    NSArray *array = [NSArray arrayWithObjects:self, newCart, nil];

    [[NSNotificationCenter defaultCenter] postNotificationName:notificationShoppingCartChanged object:cartToSplit];
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationShoppingCartChanged object:newCart];

    return array;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqual:@"positions"])
    {
        if (self.positions.count > 0 && self.currencyCode == nil)
        {
            SBDocumentPosition *documentPosition = self.positions.allObjects[0];
            SBVariant *variant = documentPosition.referencedVariant;
            SBPrice *price = [variant getPriceForCustomerOrNil:self.customer];
            self.currencyCode = price.currency;
        }
        else if (self.positions.count == 0) self.currencyCode = nil;
    }
}

@end