//
//  SBItemGroupText.m
//  SalesBook
//
//  Created by Andreas Kucher on 11.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBItemGroupText.h"

#import "SBItemGroup+Extensions.h"
#import "SAGSyncManager.h"

@implementation SBItemGroupText

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
    
    SBItemGroup *itemGroup = [SBItemGroup getItemGroupWithUniqueID:uniqueID];
    
    if ([[dict valueForKey:[self webserviceActionState]] intValue] == SAGActiveStateDeleted) //Wenn das Document gelöscht werden soll...
    {
        if (itemGroup) //Und es existiert...
        {
            [itemGroup deleteAttributesWithLanguage:[dict valueForKey:@"language"]]; //Alle Schlüssel einer Sprache löschen....
        }
        
        return YES; //Fertig!
    }
    
    if (!itemGroup) //Mit Errorstatus anlegen, da die Texte gespeichert werden müssen aber das Dokument noch nicht da ist.
    {
        itemGroup = [SBItemGroup createNewItemGroup]; //Neues Dokument anlegen
        itemGroup.uniqueID = uniqueID; //Generierte UUID überschreiben
        itemGroup.transferState = [NSNumber numberWithInt:SAGTransferStateError];
    }
    
    [itemGroup setAttributesfromDictionary:[dict valueForKey:@"customFieldValues"]]; //CustomFields
    
    return YES;
}

#pragma mark - Webservice Settings

+ (NSString *)localizedClassName
{
    return NSLocalizedString(@"Product group texts", @"SBItemGroupText"); //Plural
}

+ (NSString *)webserviceUpdate
{
    return @"V3GetItemGroupText";
}

+ (NSString *)webserviceDelete
{
    return @"V3GetItemGroupTextDeleted";
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
    return @"itemGroupTexts";
}

+ (NSString *)webserviceDataBlockDeleted
{
    return @"itemGroupTextsDeleted";
}

@end
