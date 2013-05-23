//
//  SBStock+Extensions.m
//  SalesBook
//
//  Created by Andreas Kucher on 18.01.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBStock+Extensions.h"
#import "SAGSyncManager.h"

#import "SBVariant+Extensions.h"

@implementation SBStock (Extensions)

+ (SBStock *)createNewStock
{
    SBStock *stock = [SBStock MR_createEntity];
    
    stock.uniqueID = [NSString generateUniqueID]; //generateUniqueID
    stock.creationDate = [NSDate date]; //Anlage Datum aufheben
    
    return stock;
}

+ (SBStock *)getStockWithUniqueID:(NSString *)uniqueID
{
    return [SBStock MR_findFirstByAttribute:@"uniqueID" withValue:uniqueID];
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
    
    SBStock *stock = [self getStockWithUniqueID:uniqueID];
    
    if ([[dict valueForKey:[self webserviceActionState]] intValue] == SAGActiveStateDeleted) //Prüfen ob gelöscht werden muss!
    {
        if (stock) //Falls das Dokument schon exisitert!
        {
            [stock MR_deleteEntity]; //Das bestehende Dokument löschen!
        }
        return YES;
    }
    
    if (!stock)
    {
        stock = [self createNewStock]; //Neues Dokument anlegen
        stock.uniqueID = uniqueID; //Generierte UUID überschreiben
    }
    
    [stock MR_importValuesForKeysWithObject:dict]; //MR_importValuesForKeysWithObject füllt alle Daten in die entsprechenden Felder wenn in UserInfo "mappedKeyName" eingetragen ist!
    
    stock.transferDate = [newTransferDate fromISO8601FormatedString]; //Timestamp
    stock.documentState = [NSNumber numberWithInt:SAGDocumentStateCommited]; //Datensatz wurde vom mCube bestätigt !!!
    stock.alternationDate = [NSDate date]; //Aktualisierung speichern
    
    return YES;
}

#pragma mark - Webservice Settings

+ (NSString *)localizedClassName
{
    return NSLocalizedString(@"Stock Informations", @"SBStock"); //Plural
}

+ (NSString *)webserviceUpdate
{
    return @"V3GetStock";
}

+ (NSString *)webserviceDelete
{
    return @"V3GetStockDeleted";
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
    return @"stocks";
}

+ (NSString *)webserviceDataBlockDeleted
{
    return @"stocksDeleted";
}

#pragma mark - reference

- (void)setVariantNumber:(NSString *)variantNumber
{    
    [self willChangeValueForKey:@"variantNumber"];
    [self setPrimitiveValue:variantNumber forKey:@"variantNumber"];
    [self didChangeValueForKey:@"variantNumber"];
    
    [self setVariant:[SBVariant getVariantWithVariantNumber:variantNumber]];
}

+ (void)renewReferences //Nicht referenzierte Objekte zuordnen
{
    NSArray *notReferencedObjects = [SBStock MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"variant == nil"]];
    
    if (notReferencedObjects)
    {
        [notReferencedObjects enumerateObjectsUsingBlock:^(SBStock *stock, NSUInteger idx, BOOL *stop)
        {
            stock.variant = [SBVariant getVariantWithVariantNumber:stock.variantNumber];
        }];
    }
}

#pragma mark - internal stuff

- (UIImage *)getSignalLightImage
{
    switch ([[self availabilityState] intValue]) {
        case 30:
            //Grün
            return [UIImage imageNamed:@"status_30_s.png"];
            break;
        case 20:
            //Gelb
            return [UIImage imageNamed:@"status_20_s.png"];
            break;
        case 10:
            //Rot
            return [UIImage imageNamed:@"status_10_s.png"];
            break;
        default:
            break;
    }
    
    return nil;
}


@end
