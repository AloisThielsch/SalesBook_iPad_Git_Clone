//
//  SBItemGroup+Extensions.m
//  SalesBook
//
//  Created by Andreas Kucher on 08.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBItemGroup+Extensions.h"

#import "SAGSyncManager.h"
#import "SBCustomer+Extensions.h"

#include <stdlib.h>

@implementation SBItemGroup (Extensions)

+ (SBItemGroup *)createNewItemGroup
{
    SBItemGroup *itemGroup = [SBItemGroup MR_createEntity];
    
    itemGroup.uniqueID = [NSString generateUniqueID]; //generateUniqueID
    itemGroup.creationDate = [NSDate date]; //Anlage Datum aufheben
    
    return itemGroup;
}

+ (SBItemGroup *)getItemGroupWithUniqueID:(NSString *)uniqueID
{
    return [SBItemGroup MR_findFirstByAttribute:@"uniqueID" withValue:uniqueID];
}

+ (SBItemGroup *)getItemGroupWithItemGroupNumber:(NSString *)itemGroupNumber
{
    return [SBItemGroup MR_findFirstByAttribute:@"itemGroupNumber" withValue:itemGroupNumber];
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
    
    SBItemGroup *itemGroup = [self getItemGroupWithUniqueID:uniqueID];
    
    if ([[dict valueForKey:[self webserviceActionState]] intValue] == SAGActiveStateDeleted) //Prüfen ob gelöscht werden muss!
    {
        if (itemGroup) //Falls das Dokument schon exisitert!
        {
            [itemGroup MR_deleteEntity]; //Das bestehende Dokument löschen!
        }
        return YES;
    }
    
    if (!itemGroup)
    {
        itemGroup = [self createNewItemGroup]; //Neues Dokument anlegen
        itemGroup.uniqueID = uniqueID; //Generierte UUID überschreiben
    }
    
    [itemGroup MR_importValuesForKeysWithObject:dict]; //MR_importValuesForKeysWithObject füllt alle Daten in die entsprechenden Felder wenn in UserInfo "mappedKeyName" eingetragen ist!
    
    itemGroup.transferDate = [newTransferDate fromISO8601FormatedString]; //Timestamp
    itemGroup.documentState = [NSNumber numberWithInt:SAGDocumentStateCommited]; //Datensatz wurde vom mCube bestätigt !!!
    itemGroup.alternationDate = [NSDate date]; //Aktualisierung speichern
    
    return YES;
}

#pragma mark - rerferences

- (void)setParentGroup:(NSString *)parentGroup
{
    [self willChangeValueForKey:@"parentGroup"];
    [self setPrimitiveValue:parentGroup forKey:@"parentGroup"];
    [self didChangeValueForKey:@"parentGroup"];
    
    self.topGroup = [SBItemGroup getItemGroupWithItemGroupNumber:parentGroup];
}

#pragma mark - Webservice Settings

+ (NSString *)localizedClassName
{
    return NSLocalizedString(@"Product groups", @"SBItemGroups"); //Plural
}

+ (NSString *)webserviceUpdate
{
    return @"V3GetItemGroup";
}

+ (NSString *)webserviceDelete
{
    return nil; //@"V3GetItemGroupDeleted";
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
    return @"itemGroups";
}

+ (NSString *)webserviceDataBlockDeleted
{
    return @"V3GetItemGroupDeleted";
}

- (NSString *)itemGroupDenoation
{
    NSString *localizedDennotaion = [self stringValueForAttribute:@"denotation" andLanguage:[[SAGSettingsManager sharedManager] itemDisplayLanguage]];
    
    if (localizedDennotaion.length > 0) return localizedDennotaion;
    
    return self.itemGroupNumber;
}

@end