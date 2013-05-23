//
//  SBDocumentType+Extensions.m
//  SalesBook
//
//  Created by Andreas Kucher on 16.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBDocumentType+Extensions.h"

#import "SAGMenuController.h"
#import "SAGSyncManager.h"

@implementation SBDocumentType (Extensions)

+ (SBDocumentType *)createNewDocumentType
{
    SBDocumentType *documentType = [SBDocumentType MR_createEntity];
    
    documentType.uniqueID = [NSString generateUniqueID]; //generateUniqueID
    documentType.creationDate = [NSDate date]; //Anlage Datum aufheben
    
    return documentType;
}

+ (SBDocumentType *)getDocumentTypeWithUniqueID:(NSString *)uniqueID
{
    return [SBDocumentType MR_findFirstByAttribute:@"uniqueID" withValue:uniqueID];
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
    
    SBDocumentType *documentType = [self getDocumentTypeWithUniqueID:uniqueID];
    
    if ([[dict valueForKey:[self webserviceActionState]] intValue] == SAGActiveStateDeleted) //Prüfen ob gelöscht werden muss!
    {
        if (documentType) //Falls das Dokument schon exisitert!
        {
            [documentType MR_deleteEntity]; //Das bestehende Dokument löschen!
        }
        return YES;
    }
    
    if (!documentType)
    {
        documentType = [self createNewDocumentType]; //Neues Dokument anlegen
        documentType.uniqueID = uniqueID; //Generierte UUID überschreiben
    }
    
    [documentType MR_importValuesForKeysWithObject:dict]; //MR_importValuesForKeysWithObject füllt alle Daten in die entsprechenden Felder wenn in UserInfo "mappedKeyName" eingetragen ist!
    
    documentType.transferDate = [newTransferDate fromISO8601FormatedString]; //Timestamp
    documentType.documentState = [NSNumber numberWithInt:SAGDocumentStateCommited]; //Datensatz wurde vom mCube bestätigt !!!
    documentType.alternationDate = [NSDate date]; //Aktualisierung speichern
    
    return YES;
}

#pragma mark - Webservice Settings

+ (NSString *)localizedClassName
{
    return NSLocalizedString(@"Document Types", @"SBDocumentType"); //Plural
}

+ (NSString *)webserviceUpdate
{
    return @"V3GetDocumentTypes";
}

+ (NSString *)webserviceDelete
{
    return @"V3GetDocumentTypesDeleted";
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
    return @"documentTypes";
}

+ (NSString *)webserviceDataBlockDeleted
{
    return @"documentTypesDeleted";
}

#pragma mark - other stuff

+ (NSString *)getDenoationWith:(enum SAGDocumentType)documentType andLangauge:(NSString *)language
{
    NSString *denotation = [[SBDocumentType MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"documentTypeID = %@ AND language = %@", [NSNumber numberWithInt:documentType], language]] denotationValue];
    
    if (!denotation)
    {
        return [[NSNumber numberWithInt:documentType] stringValue];
    }
    
    return denotation;
}

@end
