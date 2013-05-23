//
//  SBClerk+Extensions.m
//  SalesBook
//
//  Created by Andreas Kucher on 13.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBClerk+Extensions.h"

#import "SBAddress+Extensions.h"
#import "SBLanguage+Extensions.h"

#import "SAGSyncManager.h"

@implementation SBClerk (Extensions)

+ (SBClerk *)createNewClerk
{
    SBClerk *clerk = [SBClerk MR_createEntity];
    
    clerk.uniqueID = [NSString generateUniqueID]; //generateUniqueID
    clerk.creationDate = [NSDate date]; //Anlage Datum aufheben
    
    return clerk;
}

+ (SBClerk *)getClerkWithUniqueID:(NSString *)uniqueID
{
    return [SBClerk MR_findFirstByAttribute:@"uniqueID" withValue:uniqueID];
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
    
    SBClerk *clerk = [self getClerkWithUniqueID:uniqueID];
    
    if ([[dict valueForKey:[self webserviceActionState]] intValue] == SAGActiveStateDeleted) //Prüfen ob gelöscht werden muss!
    {
        if (clerk) //Falls das Dokument schon exisitert!
        {
            [clerk MR_deleteEntity]; //Das bestehende Dokument löschen!
        }
        return YES;
    }
    
    if (!clerk)
    {
        clerk = [self createNewClerk]; //Neues Dokument anlegen
        clerk.uniqueID = uniqueID; //Generierte UUID überschreiben
    }
    
    [clerk MR_importValuesForKeysWithObject:dict]; //MR_importValuesForKeysWithObject füllt alle Daten in die entsprechenden Felder wenn in UserInfo "mappedKeyName" eingetragen ist!
    
    NSDictionary *clerkAddress = [dict valueForKey:@"clerkAddress"];
    
    if (clerkAddress)
    {
        if ([SBAddress updateDocumentFromDictionary:clerkAddress])
        {
            [clerk setAddress:[SBAddress getAddressWithUniqueID:[clerkAddress valueForKey:@"uniqueID"]]];
        }
    }
    
    NSArray *languages = [dict valueForKey:@"languages"]; //TODO: Sicherstellen, das es immer Languages gibt!
    
    for (NSDictionary *aLanguage in languages) 
    {
        [SBLanguage updateDocumentFromDictionary:aLanguage];
    }
    
    clerk.transferDate = [newTransferDate fromISO8601FormatedString]; //Timestamp
    clerk.documentState = [NSNumber numberWithInt:SAGDocumentStateCommited]; //Datensatz wurde vom mCube bestätigt !
    clerk.alternationDate = [NSDate date]; //Aktualisierung speichern
    
    return YES;
}

#pragma mark - Webservice Settings

+ (NSString *)localizedClassName
{
    return NSLocalizedString(@"Clerk Infos", @"SBClerk"); //Plural
}

+ (NSString *)webserviceUpdate
{
    return @"V3GetClerkInfo";
}

+ (NSString *)webserviceDelete
{
    return nil; //@"V3GetClerkInfoDeleted";
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
    return @"100";
}

+ (NSString *)webserviceDataBlock
{
    return @"clerkInfos";
}

+ (NSString *)webserviceDataBlockDeleted
{
    return @"clerkInfosDeleted";
}

+ (BOOL)shouldRemoveDataBeforeImport
{
    return YES;
}

#pragma mark - class methods

- (SBLanguage *)getDefaultLanguage
{
    NSArray *languages = [[self.languages filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"isDefault = %@", @YES]] allObjects];
    
    if (languages.count == 0)
    {
        return nil;
    }
        
    return [languages objectAtIndex:0];
}

@end
