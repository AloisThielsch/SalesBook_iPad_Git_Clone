//
//  SBDocumentPosition+Extensions.m
//  SalesBook
//
//  Created by Julian Knab on 11.02.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBDocumentPosition+Extensions.h"

#import "SBPrice+Extensions.h"

#import "SBRebateAbsolute.h"
#import "SBRebatePercental.h"

@implementation SBDocumentPosition (Extensions)

- (SBDocumentPosition *)clonePosition
{
    return [SBDocumentPosition clonePosition:self];
}

+ (SBDocumentPosition *)clonePosition:(SBDocumentPosition *)positionToClone
{
    SBDocumentPosition *newPosition = [SBDocumentPosition MR_createEntity];

    NSDictionary *memberVariables = [[NSEntityDescription entityForName:@"SBDocumentPosition" inManagedObjectContext:positionToClone.managedObjectContext] attributesByName];

    @try
    {
        for (NSString *mv in memberVariables)
        {
            [newPosition setValue:[positionToClone valueForKey:mv] forKey:mv];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"hier batscht es!");
    }

    NSDictionary *relationships = [[NSEntityDescription entityForName:@"SBDocumentPosition" inManagedObjectContext:positionToClone.managedObjectContext] relationshipsByName];

    @try
    {
        for (NSString *rs in relationships)
        {
            if ([rs isEqualToString:@"document"]) continue;

            [newPosition setValue:[positionToClone valueForKey:rs] forKey:rs];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"hier batscht es!");
    }

    return newPosition;
}

+ (SBDocumentPosition *)getDocumentPositionForItemVariant:(SBVariant *)itemVariant andDeliveryDate:(NSDate *)deliveryDate fromCart:(SBShoppingCart *)cartToGetFrom
{
    NSString *variantNumber = itemVariant.variantNumber;

    return [SBDocumentPosition getDocumentPositionForItemVariantWithNumber:variantNumber andDeliveryDate:deliveryDate fromCart:cartToGetFrom];
}

+ (SBDocumentPosition *)getDocumentPositionForItemVariantWithNumber:(NSString *)variantNumber andDeliveryDate:(NSDate *)deliveryDate fromCart:(SBShoppingCart *)cartToGetFrom
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"referencedVariant.variantNumber == %@ AND calculatedDeliveryDate == %@ AND document == %@", variantNumber, deliveryDate, cartToGetFrom];

    return [SBDocumentPosition MR_findFirstWithPredicate:predicate];
}

- (void)setAmountWithInt:(int)amount
{
    SBShoppingCart *cart = (SBShoppingCart *)self.document;
    
    [cart setAmount:amount ofDocumentPosition:self];
}

- (double)getSinglePiecePrice
{
    SBVariant *variant = self.referencedVariant;

    SBPrice *price = [variant getPriceForCustomerOrNil:self.document.customer];

    return price.price.doubleValue;
}

- (double)getSinglePiecePriceWithRebate
{
    double singlePiecePrice = [self getSinglePiecePrice];

    if (!self.rebate) return singlePiecePrice;

    if ([self.rebate isKindOfClass:[SBRebateAbsolute class]])
    {
        SBRebateAbsolute *rebate = (SBRebateAbsolute *)self.rebate;
        double rebateValue = rebate.value.doubleValue;
        return singlePiecePrice - rebateValue;
    }
    else if ([self.rebate isKindOfClass:[SBRebatePercental class]])
    {
        SBRebatePercental *rebate = (SBRebatePercental *)self.rebate;
        double rebateValue = singlePiecePrice * (rebate.percentage.doubleValue / 100);
        return singlePiecePrice - rebateValue;
    }

    return singlePiecePrice;
}

- (double)getTotalPrice
{
    double singlePiecePriceWithRebate = [self getSinglePiecePriceWithRebate];
    return singlePiecePriceWithRebate * self.amount.intValue * self.referencedVariant.packQuantity.intValue;
}

@end