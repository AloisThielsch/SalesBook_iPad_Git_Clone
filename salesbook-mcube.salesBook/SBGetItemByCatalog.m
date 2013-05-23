//
//  SBGetItemByCatalog.m
//  SalesBook
//
//  Created by Andreas Kucher on 07.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBGetItemByCatalog.h"
#import "SBCatalog+Extensions.h"
#import "SBItem+Extensions.h"

#import "SAGSyncManager.h"

@implementation SBGetItemByCatalog

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
    
    SBCatalog *catalog = [SBCatalog getCatalogWithUniqueID:uniqueID];

    if ([[dict valueForKey:[self webserviceActionState]] intValue] == SAGActiveStateDeleted) //Wenn das Document gelöscht werden soll und nicht existiert...
    {
        return YES; //Fertig!
    }
    
    if (!catalog) //Mit Errorstatus anlegen, da die Texte gespeichert werden müssen aber das Dokument noch nicht da ist.
    {
        catalog = [SBCatalog createNewCatalog]; //Neues Dokument anlegen
        catalog.uniqueID = uniqueID; //Generierte UUID überschreiben
        catalog.transferState = [NSNumber numberWithInt:SAGTransferStateError];
    }
    
    SBItem *item = [SBItem getItemWithItemNumber:[dict valueForKey:@"itemNumber"]];
    
    if (!item)
    {
        NSString *errorMessage = [NSString stringWithFormat:@"Error updating: %@ from Dictionary! Reason: Item with Number: %@ is missing!", [[self class] description], [dict valueForKey:@"itemNumber"]];
        
        [[SAGSyncManager sharedClient] addErrorWithMessage:errorMessage andUserInfo:dict];
        
        return NO;
    }
    
    [catalog addItemsObject:item]; //Referenz herstellen
    
    return YES;
}

#pragma mark - Webservice Settings

+ (NSString *)localizedClassName
{
    return NSLocalizedString(@"Item by Catalog", @"SBGetItemByCatalog"); //Plural
}

+ (NSString *)webserviceUpdate
{
    return @"V3GetItemByCatalog";
}

+ (NSString *)webserviceDelete
{
    return @"V3GetItemByCatalogDeleted";
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
    return @"itemByCatalogs";
}

+ (NSString *)webserviceDataBlockDeleted
{
    return @"itemByCatalogsDeleted";
}

@end
