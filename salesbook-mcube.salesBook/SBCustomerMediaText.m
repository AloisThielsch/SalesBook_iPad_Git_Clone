//
//  SBCustomerMediaText.m
//  SalesBook
//
//  Created by Andreas Kucher on 11.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBCustomerMediaText.h"
#import "SBMedia+Extensions.h"

#import "SAGSyncManager.h"

@implementation SBCustomerMediaText

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
    
    SBMedia *media = [SBMedia getMediaWithUniqueID:uniqueID];
    
    if ([[dict valueForKey:[self webserviceActionState]] intValue] == SAGActiveStateDeleted) //Wenn das Document gelöscht werden soll...
    {
        if (media) //Und es existiert...
        {
            [media deleteAttributesWithLanguage:[dict valueForKey:@"language"]]; //Alle Schlüssel einer Sprache löschen....
        }
        
        return YES; //Fertig!
    }
    
    if (!media) //Mit Errorstatus anlegen, da die Texte gespeichert werden müssen aber das Dokument noch nicht da ist.
    {
        media = [SBMedia createNewMedia]; //Neues Dokument anlegen
        media.uniqueID = uniqueID; //Generierte UUID überschreiben
        media.transferState = [NSNumber numberWithInt:SAGTransferStateError];
    }
    
    [media setAttributesfromDictionary:[dict valueForKey:@"customFieldValues"]]; //CustomFields
    
    return YES;
}

#pragma mark - Webservice Settings

+ (NSString *)localizedClassName
{
    return NSLocalizedString(@"Customer Mediatexts", @"SBCustomerMediaText"); //Plural
}

+ (NSString *)webserviceUpdate
{
    return @"V3GetCustomerMediaText";
}

+ (NSString *)webserviceDelete
{
    return @"V3GetCustomerMediaTextDeleted";
}

+ (NSString *)webserviceActionState
{
    return @"actionFlag";
}

+ (NSString *)webserviceUniqueID
{
    return @"variantNumber";
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
    return @"customerMediaTexts";
}

+ (NSString *)webserviceDataBlockDeleted
{
    return @"customerMediaTextsDeleted";
}

@end
