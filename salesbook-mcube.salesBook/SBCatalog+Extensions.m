//
//  SBCatalog+Extensions.m
//  SalesBook
//
//  Created by Andreas Kucher on 07.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBCatalog+Extensions.h"
#import "NSPredicate+Search.h"

#import "SAGSyncManager.h"

@implementation SBCatalog (Extensions)

+ (SBCatalog *)createNewCatalog
{
    SBCatalog *catalog = [SBCatalog MR_createEntity];
    
    catalog.uniqueID = [NSString generateUniqueID]; //generateUniqueID
    catalog.creationDate = [NSDate date]; //Anlage Datum aufheben
    
    return catalog;
}

+ (SBCatalog *)getCatalogWithUniqueID:(NSString *)uniqueID
{
    return [SBCatalog MR_findFirstByAttribute:@"uniqueID" withValue:uniqueID];
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
    
    SBCatalog *catalog = [self getCatalogWithUniqueID:uniqueID];
    
    if ([[dict valueForKey:[self webserviceActionState]] intValue] == SAGActiveStateDeleted) //Prüfen ob gelöscht werden muss!
    {
        if (catalog) //Falls das Dokument schon exisitert!
        {
            [catalog MR_deleteEntity]; //Das bestehende Dokument löschen!
        }
        return YES;
    }
    
    if (!catalog)
    {
        catalog = [self createNewCatalog]; //Neues Dokument anlegen
        catalog.uniqueID = uniqueID; //Generierte UUID überschreiben
    }
    
    [catalog MR_importValuesForKeysWithObject:dict]; //MR_importValuesForKeysWithObject füllt alle Daten in die entsprechenden Felder wenn in UserInfo "mappedKeyName" eingetragen ist!
    
    catalog.transferDate = [newTransferDate fromISO8601FormatedString]; //Timestamp
    catalog.documentState = [NSNumber numberWithInt:SAGDocumentStateCommited]; //Datensatz wurde vom mCube bestätigt !!!
    catalog.alternationDate = [NSDate date]; //Aktualisierung speichern
    
    return YES;
}

#pragma mark - Webservice Settings

+ (NSString *)localizedClassName
{
    return NSLocalizedString(@"Catalogs", @"SBCatalog"); //Plural
}

+ (NSString *)webserviceUpdate
{
    return @"V3GetCatalog";
}

+ (NSString *)webserviceDelete
{
    return @"V3GetCatalogDeleted";
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
    return @"catalogs";
}

+ (NSString *)webserviceDataBlockDeleted
{
    return @"catalogsDeleted";
}

#pragma mark - references

- (NSSet *)itemGroups //TODO: Remove
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"SBItemGroup"];
    
    [fetchRequest setReturnsDistinctResults:YES];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"level = 0 AND ANY items in %@", self.items]];
    
    NSArray *result = [NSManagedObject MR_executeFetchRequest:fetchRequest];
    
    if (result.count > 0)
    {
        return [NSSet setWithArray:result];
    }
    
    return nil;
}

+ (void)renewReferences //Nicht referenzierte Objekte zuordnen 
{
    NSArray *allCatalogs = [SBCatalog MR_findAll]; //TODO: Check
    
    [allCatalogs enumerateObjectsUsingBlock:^(SBCatalog *catalog, NSUInteger idx, BOOL *stop) {
        
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"SBItemGroup"];
        
        [fetchRequest setReturnsDistinctResults:YES];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"level = 0 AND ANY items in %@", catalog.items]];
        
        NSArray *result = [NSManagedObject MR_executeFetchRequest:fetchRequest];
        
        if (result.count > 0)
        {
            [catalog setItemGroups:[NSSet setWithArray:result]];
            
            DDLogInfo(@"Catalog: %@ -> ItemGroups: %@", catalog.catalogNumber, [[[catalog.itemGroups valueForKey:@"itemGroupNumber"] allObjects] componentsJoinedByString:@","]);
        }
    }];
}

- (NSString *)catalogDenoation
{
    NSString *localizedDennotaion = [self stringValueForAttribute:@"denotation" andLanguage:[[SAGSettingsManager sharedManager] itemDisplayLanguage]];
    
    if (localizedDennotaion.length > 0) return localizedDennotaion;
    
    return self.catalogNumber;
}

@end
