//
//  SBAssortment+Extensions.m
//  SalesBook
//
//  Created by Andreas Kucher on 17.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBAssortment+Extensions.h"

#import "SAGSyncManager.h"

@implementation SBAssortment (Extensions)

+ (SBAssortment *)createNewAssortment
{
    SBAssortment *assortment = [SBAssortment MR_createEntity];
    
    assortment.uniqueID = [NSString generateUniqueID]; //generateUniqueID
    assortment.creationDate = [NSDate date]; //Anlage Datum aufheben
    
    return assortment;
}

+ (SBAssortment *)getAssortmentWithUniqueID:(NSString *)uniqueID
{
    return [SBAssortment MR_findFirstByAttribute:@"uniqueID" withValue:uniqueID];
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
    
    SBAssortment *assortment = [self getAssortmentWithUniqueID:uniqueID];
    
    if ([[dict valueForKey:[self webserviceActionState]] intValue] == SAGActiveStateDeleted) //Prüfen ob gelöscht werden muss!
    {
        if (assortment) //Falls das Dokument schon exisitert!
        {
            [assortment MR_deleteEntity]; //Das bestehende Dokument löschen!
        }
        return YES;
    }
    
    if (!assortment)
    {
        assortment = [self createNewAssortment]; //Neues Dokument anlegen
        assortment.uniqueID = uniqueID; //Generierte UUID überschreiben
    }
    
    [assortment MR_importValuesForKeysWithObject:dict]; //MR_importValuesForKeysWithObject füllt alle Daten in die entsprechenden Felder wenn in UserInfo "mappedKeyName" eingetragen ist!
    
    assortment.transferDate = [newTransferDate fromISO8601FormatedString]; //Timestamp
    assortment.documentState = [NSNumber numberWithInt:SAGDocumentStateCommited]; //Datensatz wurde vom mCube bestätigt !!!
    assortment.alternationDate = [NSDate date]; //Aktualisierung speichern
    
    return YES;
}

#pragma mark - Webservice Settings

+ (NSString *)localizedClassName
{
    return NSLocalizedString(@"Assortments", @"SBAssortment"); //Plural
}

+ (NSString *)webserviceUpdate
{
    return @"V3GetAssortmentDetails";
}

+ (NSString *)webserviceDelete
{
    return @"V3GetAssortmentDetailsDeleted";
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
    return @"250";
}

+ (NSString *)webserviceDataBlock
{
    return @"assortmentDetails";
}

+ (NSString *)webserviceDataBlockDeleted
{
    return @"assortmentDetailsDeleted";
}

#pragma mark - other funtions

+ (NSDictionary *)sizeIndexWithAssortment:(NSString *)assortment andSeason:(NSString *)season
{
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"SBAssortment"];
    fetch.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"sizeIndex" ascending:@YES]];
    fetch.predicate = [NSPredicate predicateWithFormat:@"assortment = %@ AND season = %@", assortment, season];
    fetch.propertiesToFetch = @[@"quantity", @"size"];
    fetch.resultType = NSDictionaryResultType;
 
    NSArray *foundAssortments = [NSManagedObject MR_executeFetchRequest:fetch];
    
    double total = 0;
    
    for (NSDictionary *dict in foundAssortments)
    {
        total += [[dict valueForKey:@"quantity"] doubleValue];
    }
    
    return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:total], @"total", season, @"season", assortment, @"assortment", foundAssortments, @"sizeIndex", nil];
}

@end
