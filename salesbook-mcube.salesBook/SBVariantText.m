//
//  SAGVariantText.m
//  SalesBook
//
//  Created by Andreas Kucher on 06.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBVariantText.h"

#import "SBVariant+Extensions.h"
#import "SAGSyncManager.h"

@implementation SBVariantText

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
    
    SBVariant *variant = [SBVariant getVariantWithUniqueID:uniqueID];
    
    if ([[dict valueForKey:[self webserviceActionState]] intValue] == SAGActiveStateDeleted) //Wenn das Document gelöscht werden soll...
    {
        if (variant) //Und es existiert...
        {
            [variant deleteAttributesWithLanguage:[dict valueForKey:@"language"]]; //Alle Schlüssel einer Sprache löschen....
        }
        
        return YES; //Fertig!
    }
    
    if (!variant) //Mit Errorstatus anlegen, da die Texte gespeichert werden müssen aber das Dokument noch nicht da ist.
    {
        variant = [SBVariant createNewVariant]; //Neues Dokument anlegen
        variant.uniqueID = uniqueID; //Generierte UUID überschreiben
        variant.transferState = [NSNumber numberWithInt:SAGTransferStateError];
    }
    
    [variant setAttributesfromDictionary:[dict valueForKey:@"customFieldValues"]]; //CustomFields
    
    return YES;
}

#pragma mark - Webservice Settings

+ (NSString *)localizedClassName
{
    return NSLocalizedString(@"Variant texts", @"SBVariantText"); //Plural
}

+ (NSString *)webserviceUpdate
{
    return @"V3GetVariantText";
}

+ (NSString *)webserviceDelete
{
    return @"V3GetVariantTextDeleted";
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
    return @"100";
}

+ (NSString *)webserviceDataBlock
{
    return @"variantTexts";
}

+ (NSString *)webserviceDataBlockDeleted
{
    return @"variantTextsDeleted";
}

@end
