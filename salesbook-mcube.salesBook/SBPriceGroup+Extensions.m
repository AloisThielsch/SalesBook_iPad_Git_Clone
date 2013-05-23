//
//  SBPriceGroup+Extensions.m
//  SalesBook
//
//  Created by Andreas Kucher on 11.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBPriceGroup+Extensions.h"

#import "SBCustomer+Extensions.h"
#import "SBPrice+Extensions.h"

@implementation SBPriceGroup (Extensions)

+ (SBPriceGroup *)getPriceGroupWithPriceGroupNumber:(NSString *)priceGroupNumber //Gibt immer eine Pricegroup zurück!
{
    if (priceGroupNumber.length == 0)
    {
        return nil;
    }
    
    SBPriceGroup *priceGroup = [SBPriceGroup MR_findFirstByAttribute:@"priceGroupNumber" withValue:priceGroupNumber];
    
    if (!priceGroup)
    {
        priceGroup = [SBPriceGroup MR_createEntity];
        priceGroup.priceGroupNumber = priceGroupNumber;
    }

    return priceGroup;
}

+ (bool)existsPriceGroupWithPriceGroupNumber:(NSString *)priceGroupNumber //Notwendig um zu prüfen ob es eine Pricesgroup gibt!
{
    if ([SBPriceGroup MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"priceGroupNumber == %@", priceGroupNumber]] > 0)
    {
        return YES;
    }
    
    return NO;
}

//Importiert wird das ganze in SBPrice+Extension! Durch das setzen der Referenzen werden die Gruppen automatisch angeleget!

@end
