//
//  SBGetItemText.m
//  SalesBook
//
//  Created by Andreas Kucher on 06.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBItemText.h"

#import "SBItem+Extensions.h"
#import "SAGSyncManager.h"

@implementation SBItemText

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
    
    SBItem *item = [SBItem getItemWithUniqueID:uniqueID];
    
    if ([[dict valueForKey:[self webserviceActionState]] intValue] == SAGActiveStateDeleted) //Wenn das Document gelöscht werden soll...
    {
        if (item) //Und es existiert...
        {
            [item deleteAttributesWithLanguage:[dict valueForKey:@"language"]]; //Alle Schlüssel einer Sprache löschen....
        }
        
        return YES; //Fertig!
    }
    
    if (!item) //Mit Errorstatus anlegen, da die Texte gespeichert werden müssen aber das Dokument noch nicht da ist.
    {
        item = [SBItem createNewItem]; //Neues Dokument anlegen
        item.uniqueID = uniqueID; //Generierte UUID überschreiben
        item.transferState = [NSNumber numberWithInt:SAGTransferStateError];
    }
    
    [item setAttributesfromDictionary:[dict valueForKey:@"customFieldValues"]]; //CustomFields
    
    return YES;
}

#pragma mark - Webservice Settings

+ (NSString *)localizedClassName
{
    return NSLocalizedString(@"Item texts", @"SBItemText"); //Plural
}

+ (NSString *)webserviceUpdate
{
    return @"V3GetItemText";
}

+ (NSString *)webserviceDelete
{
    return @"V3GetItemTextDeleted";
}

+ (NSString *)webserviceActionState
{
    return @"actionFlag";
}

+ (NSString *)webserviceUniqueID
{
    return @"itemNumber";
}

+ (NSString *)webserviceTransferDate
{
    return @"ts";
}

+ (NSString *)webserviceBlockSize
{
    return @"300";
}

+ (NSString *)webserviceDataBlock
{
    return @"itemTexts";
}

+ (NSString *)webserviceDataBlockDeleted
{
    return @"itemTextsDeleted";
}

@end
