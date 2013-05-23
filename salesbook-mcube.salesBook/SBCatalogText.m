//
//  SBCatalogText.m
//  SalesBook
//
//  Created by Andreas Kucher on 11.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBCatalogText.h"
#import "SBCatalog+Extensions.h"

#import "SAGSyncManager.h"

@implementation SBCatalogText

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
    
    if ([[dict valueForKey:[self webserviceActionState]] intValue] == SAGActiveStateDeleted) //Wenn das Document gelöscht werden soll...
    {
        if (catalog) //Und es existiert...
        {
            [catalog deleteAttributesWithLanguage:[dict valueForKey:@"language"]]; //Alle Schlüssel einer Sprache löschen....
        }
        
        return YES; //Fertig!
    }
    
    if (!catalog) //Mit Errorstatus anlegen, da die Texte gespeichert werden müssen aber das Dokument noch nicht da ist.
    {
        catalog = [SBCatalog createNewCatalog]; //Neues Dokument anlegen
        catalog.uniqueID = uniqueID; //Generierte UUID überschreiben
        catalog.transferState = [NSNumber numberWithInt:SAGTransferStateError];
    }
    
    [catalog setAttributesfromDictionary:[dict valueForKey:@"customFieldValues"]]; //CustomFields
    
    return YES;
}

#pragma mark - Webservice Settings

+ (NSString *)localizedClassName
{
    return NSLocalizedString(@"Catalog Texts", @"SBCatalogText"); //Plural
}

+ (NSString *)webserviceUpdate
{
    return @"V3GetCatalogText";
}

+ (NSString *)webserviceDelete
{
    return @"V3GetCatalogTextDeleted";
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
    return @"catalogTexts";
}

+ (NSString *)webserviceDataBlockDeleted
{
    return @"catalogTextsDeleted";
}

@end
