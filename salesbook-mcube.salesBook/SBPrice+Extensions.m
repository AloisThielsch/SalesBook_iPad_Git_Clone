//
//  SBPrice+Extensions.m
//  SalesBook
//
//  Created by Andreas Kucher on 20.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBPrice+Extensions.h"

#import "SBPriceGroup+Extensions.h"
#import "SBVariant+Extensions.h"

#import "SAGSyncManager.h"

@implementation SBPrice (Extensions)

+ (SBPrice *)createNewPrice
{
    SBPrice *price = [SBPrice MR_createEntity];
    
    price.uniqueID = [NSString generateUniqueID]; //generateUniqueID
    price.creationDate = [NSDate date]; //Anlage Datum aufheben
    
    return price;
}

+ (SBPrice *)getPriceWithUniqueID:(NSString *)uniqueID
{
    return [SBPrice MR_findFirstByAttribute:@"uniqueID" withValue:uniqueID];
}

#pragma mark - Update

+ (BOOL)updateDocumentFromDictionary:(NSDictionary *)dict
{
    NSString *uniqueID = [NSString stringWithFormat:@"%@_%@_%@", [dict valueForKey:@"itemNumber"], [dict valueForKey:@"currency"], [dict valueForKey:@"priceGroupNumber"]]; //TODO: Zum Standard Zurück! [dict valueForKey:[self webserviceUniqueID]];
    
    if (uniqueID.length == 0)
    {
        NSString *errorMessage = [NSString stringWithFormat:@"Can´t update %@ from Dictionary! Reason: %@ is missing!", [[self class] description], [self webserviceUniqueID]];
        
        [[SAGSyncManager sharedClient] addErrorWithMessage:errorMessage andUserInfo:dict];
        
        return NO;
    }
    
    NSString *newTransferDate = [dict valueForKey:[self webserviceTransferDate]];
    
    if (newTransferDate.length == 0)
    {
        NSString *errorMessage = [NSString stringWithFormat:@"Can´t update %@ from Dictionary! Reason: %@ is missing!", [[self class] description],[self webserviceTransferDate]];
        
        [[SAGSyncManager sharedClient] addErrorWithMessage:errorMessage andUserInfo:dict];
        
        return NO;
    }
    
    SBPrice *price = [self getPriceWithUniqueID:uniqueID];
    
    if ([[dict valueForKey:[self webserviceActionState]] intValue] == SAGActiveStateDeleted) //Prüfen ob gelöscht werden muss!
    {
        if (price) //Falls das Dokument schon exisitert!
        {
            [price MR_deleteEntity]; //Das bestehende Dokument löschen!
        }
        return YES;
    }
    
    if (!price)
    {
        price = [self createNewPrice]; //Neues Dokument anlegen
        price.uniqueID = uniqueID; //Generierte UUID überschreiben
    }
    
    [price MR_importValuesForKeysWithObject:dict]; //MR_importValuesForKeysWithObject füllt alle Daten in die entsprechenden Felder wenn in UserInfo "mappedKeyName" eingetragen ist!
    
    price.transferDate = [newTransferDate fromISO8601FormatedString]; //Timestamp
    price.documentState = [NSNumber numberWithInt:SAGDocumentStateCommited]; //Datensatz wurde vom mCube bestätigt !!!
    price.alternationDate = [NSDate date]; //Aktualisierung speichern
    
    return YES;
}

#pragma mark - references

- (void)setVariantNumber:(NSString *)variantNumber
{
    [self willChangeValueForKey:@"variantNumber"];
    [self setPrimitiveValue:variantNumber forKey:@"variantNumber"];
    [self didChangeValueForKey:@"variantNumber"];
    
    [self setVariant:[SBVariant getVariantWithVariantNumber:variantNumber]];
}

- (void)setPriceGroupNumber:(NSString *)priceGroupNumber
{
    [self willChangeValueForKey:@"priceGroupNumber"];
    [self setPrimitiveValue:priceGroupNumber forKey:@"priceGroupNumber"];
    [self didChangeValueForKey:@"priceGroupNumber"];
    
    [self setPriceGroup:[SBPriceGroup getPriceGroupWithPriceGroupNumber:priceGroupNumber]]; //Erstellt automatisch eine PriceGroup!!!
}

#pragma mark - Webservice Settings

+ (NSString *)localizedClassName
{
    return NSLocalizedString(@"Pricegroup Prices", @"SBPrice"); //Plural
}

+ (NSString *)webserviceUpdate
{
    return @"V3GetItemPriceGroup";
}

+ (NSString *)webserviceDelete
{
    return @"V3GetItemPriceGroupDeleted";
}

+ (NSString *)webserviceActionState
{
    return @"actionFlag";
}

+ (NSString *)webserviceUniqueID
{
    return @"uniqueID";
}

+ (NSString *)webserviceTransferDate
{
    return @"ts";
}

+ (NSString *)webserviceBlockSize
{
    return @"500";
}

+ (NSString *)webserviceDataBlock
{
    return @"itemPriceGroups";
}

+ (NSString *)webserviceDataBlockDeleted
{
    return [NSString stringWithFormat:@"%@Deleted", [self webserviceDataBlock]];
}

@end
