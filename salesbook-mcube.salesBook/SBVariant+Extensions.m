//
//  SBVariant+Extensions.m
//  SalesBook
//
//  Created by Andreas Kucher on 18.01.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBVariant+Extensions.h"

#import "SAGSyncManager.h"
#import "SBItem+Extensions.h"

#import "SBAttribute+Extensions.h"
#import "SBMedia+Extensions.h"

#import "SBPrice+Extensions.h"

#import "SBCustomer+Extensions.h"

#import "SBPriceGroup+Extensions.h"
#import "SBStock+Extensions.h"

#import "SAGMenuController.h"

@implementation SBVariant (Extensions)

+ (SBVariant *)createNewVariant
{
    SBVariant *variant = [SBVariant MR_createEntity];
    
    variant.uniqueID = [NSString generateUniqueID]; //generateUniqueID
    variant.creationDate = [NSDate date]; //Anlage Datum aufheben
    
    return variant;
}

+ (SBVariant *)getVariantWithUniqueID:(NSString *)uniqueID
{
    return [SBVariant MR_findFirstByAttribute:@"uniqueID" withValue:uniqueID];
}

+ (SBVariant *)getVariantWithVariantNumber:(NSString *)variantNumber
{
    return [SBVariant MR_findFirstByAttribute:@"variantNumber" withValue:variantNumber];
}

#pragma mark - Update

+ (BOOL)updateDocumentFromDictionary:(NSDictionary *)dict
{
    NSString *uniqueID = [dict valueForKey:[self webserviceUniqueID]];
    
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
    
    SBVariant *variant = [self getVariantWithUniqueID:uniqueID];
    
    if ([[dict valueForKey:[self webserviceActionState]] intValue] == SAGActiveStateDeleted) //Prüfen ob gelöscht werden muss!
    {
        if (variant) //Falls das Dokument schon exisitert!
        {
            [variant MR_deleteEntity]; //Das bestehende Dokument löschen!
        }
        return YES;
    }
    
    if (!variant)
    {
        variant = [self createNewVariant]; //Neues Dokument anlegen
        variant.uniqueID = uniqueID; //Generierte UUID überschreiben
    }
    
    [variant MR_importValuesForKeysWithObject:dict]; //MR_importValuesForKeysWithObject füllt alle Daten in die entsprechenden Felder wenn in UserInfo "mappedKeyName" eingetragen ist!
    
    //variant.earliestDeliveryDate = [[dict valueForKey:@"earliestDeliveryDate"] fromISO8601FormatedString];
    //variant.latestDeliveryDate = [[dict valueForKey:@"latestDeliveryDate"] fromISO8601FormatedString];
    
    //[variant setAttributesfromDictionary:[dict valueForKey:@"customFieldValues"]]; //CustomFields
    
    variant.transferDate = [newTransferDate fromISO8601FormatedString]; //Timestamp
    variant.documentState = [NSNumber numberWithInt:SAGDocumentStateCommited]; //Datensatz wurde vom mCube bestätigt !!!
    variant.alternationDate = [NSDate date]; //Aktualisierung speichern
    
    return YES;
}

#pragma mark - Webservice Settings

+ (NSString *)localizedClassName
{
    return NSLocalizedString(@"Variants", @"SBVariant"); //Plural
}

+ (NSString *)webserviceUpdate
{
    return @"V3GetVariant";
}

+ (NSString *)webserviceDelete
{
    return @"V3GetVariantDeleted";
}

+ (NSString *)webserviceActionState
{
    return @"actionFlag";
}

+ (NSString *)webserviceUniqueID
{
    return @"variantNumber";
}

+ (NSString *)webserviceTransferDate
{
    return @"ts";
}

+ (NSString *)webserviceBlockSize
{
    return @"250";
}

+ (NSString *)webserviceDataBlock
{
    return @"variants";
}

+ (NSString *)webserviceDataBlockDeleted
{
    return @"variantsDeleted";
}

#pragma mark - reference

- (void)setGenericItem:(NSString *)genericItem
{
    [self willChangeValueForKey:@"genericItem"];
    [self setPrimitiveValue:genericItem forKey:@"genericItem"];
    [self didChangeValueForKey:@"genericItem"];

    [self setOwningItem:[SBItem getItemWithItemNumber:genericItem]];
}

+ (void)renewReferences
{
    NSArray *notReferencedObjects = [SBVariant MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"owningItem == nil"]];
    
    if (notReferencedObjects)
    {
        [notReferencedObjects enumerateObjectsUsingBlock:^(SBVariant *variant, NSUInteger idx, BOOL *stop) {
            
            variant.owningItem = [SBItem MR_findFirstByAttribute:@"itemNumber" withValue:variant.genericItem];
        }];
    }
}

#pragma mark - matrix

- (NSString *)matrixValueFor1stDimension
{
    //TODO: change 00 to correct value from settings manager
    return [self stringValueForAttribute:self.owningItem.matrixKeyFor1stDimension andLanguage:[[SAGSettingsManager sharedManager] itemDisplayLanguage]];
}

- (NSString *)matrixValueFor2ndDimension
{
    //TODO: change 00 to correct value from settings manager
    return [self stringValueForAttribute:self.owningItem.matrixKeyFor2ndDimension andLanguage:[[SAGSettingsManager sharedManager] itemDisplayLanguage]];
}

- (NSString *)matrixValueFor3rdDimension
{
    //TODO: change 00 to correct value from settings manager    
    return [self stringValueForAttribute:self.owningItem.matrixKeyFor3rdDimension andLanguage:[[SAGSettingsManager sharedManager] itemDisplayLanguage]];
}

#pragma mark - Images

- (UIImage *)defaultImageWithImageMediaType:(enum SAGMediaType)mediaType
{
    return [[SBMedia MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"SELF in %@ AND mediaType = %@ AND isDownloaded = %@", self.mediaFiles, [NSNumber numberWithInt:mediaType], @YES] sortedBy:@"fileName" ascending:@YES] getImage];
}

- (NSArray *)getDownloadedMediaFilesWithImageMediaType:(enum SAGMediaType)mediaType
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"mediaType = %@ AND isDownloaded = %@", [NSNumber numberWithInt:mediaType], @YES];

    return [[self.mediaFiles filteredSetUsingPredicate:predicate] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"fileName" ascending:YES]]];
}

#pragma mark - Preisabfrage

- (SBPrice *)getPriceForCustomerOrNil:(SBCustomer *)customer
{
    NSString *priceGroupNumber;

    if (customer)
    {
        priceGroupNumber = customer.priceGroupNumber;
    }
    else
    {
        //TODO: change 13 to country price group number
        priceGroupNumber = [[SAGSettingsManager sharedManager] itemDisplayLanguage];
    }

    if (priceGroupNumber.length == 0)
    {
        return nil;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"variant == %@ AND priceGroupNumber == %@", self, priceGroupNumber];
    SBPrice *price = [SBPrice MR_findFirstWithPredicate:predicate];
    return price;
}

- (NSString *)getPriceAsStringForCustomerOrNil:(SBCustomer *)customer
{
    SBPrice *price = [self getPriceForCustomerOrNil:customer];
    
    if (price.price.intValue == 0)
    {
        return nil;
    }

    NSString *str = [price.price stringWithCurrencyCode:price.currency withLocale:nil];

    return str;
}

- (NSString *)getPrice2AsStringForCustomerOrNil:(SBCustomer *)customer
{
    SBPrice *price = [self getPriceForCustomerOrNil:customer];
    
    if (price.price2.intValue == 0)
    {
        return nil;
    }

    NSString *str = [price.price2 stringWithCurrencyCode:price.currency withLocale:nil];

    return str;
}

- (NSString *)getRecommendedPriceAsStringForCustomerOrNil:(SBCustomer *)customer
{
    SBPrice *price = [self getPriceForCustomerOrNil:customer];
    
    if (price.recommendedPrice.intValue == 0)
    {
        return nil;
    }
    
    NSString *str = [price.recommendedPrice stringWithCurrencyCode:price.currency withLocale:nil];
    
    return str;
}

#pragma mark - Grundfarbe

- (UIImage *)baseColorImage
{
    return [[SBMedia MR_findFirstByAttribute:@"colorNumber" withValue:self.baseColorNumber] getImage];
}

#pragma mark - Wortmann spezial

- (NSString *)assortment
{
    //TODO: change 00 to correct value from settings manager    
    return [self stringValueForAttribute:@"Sortiment" andLanguage:[[SAGSettingsManager sharedManager] itemDisplayLanguage]];
}

- (NSString *)season
{
    //TODO: change 00 to correct value from settings manager    
    return [self stringValueForAttribute:@"Saison-Schluessel" andLanguage:[[SAGSettingsManager sharedManager] itemDisplayLanguage]];
}


- (SBStock *)getStock
{
    return [SBStock MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"variant = %@ AND stockType = %@", self, [[SAGSettingsManager sharedManager] stockType]]];
}

- (UIImage *)getSignalLightImage
{
    return [[self getStock] getSignalLightImage];
}

- (NSString *)price
{
    return [self getPriceAsStringForCustomerOrNil:nil];
}

- (NSString *)price2
{
    return [self getPrice2AsStringForCustomerOrNil:nil];
}

- (NSString *)recommendedPrice
{
    return [self getRecommendedPriceAsStringForCustomerOrNil:nil];
}

- (NSString *)wmFruehesterLiefertermin
{
    NSString *wmLiefertermin = [self stringValueForAttribute:@"FruehesterLiefertermin" andLanguage:[[SAGSettingsManager sharedManager] itemDisplayLanguage]];
   
    if (wmLiefertermin.length == 8)
    {
        return [[wmLiefertermin fromShortDate] asWortmannFormattedString];
    }
    
    return wmLiefertermin;
}

- (NSString *)wmSpaetesterLiefertermin
{
    NSString *wmLiefertermin = [self stringValueForAttribute:@"SpaetesterLiefertermin" andLanguage:[[SAGSettingsManager sharedManager] itemDisplayLanguage]];
    
    if (wmLiefertermin.length == 8)
    {
        return [[wmLiefertermin fromShortDate] asWortmannFormattedString];
    }
    
    return wmLiefertermin;
}

@end