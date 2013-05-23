//
//  SBCustomerMedia.m
//  SalesBook
//
//  Created by Andreas Kucher on 11.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBCustomerMedia.h"

#import "SBMedia+Extensions.h"
#import "SAGSyncManager.h"


@implementation SBCustomerMedia

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
    
    if ([[dict valueForKey:[self webserviceActionState]] intValue] == SAGActiveStateDeleted) //Prüfen ob gelöscht werden muss!
    {
        if (media) //Falls das Dokument schon exisitert!
        {
            [media deleteMediaObject];
        }
        
        return YES;
    }
    
    if (!media)
    {
        media = [SBMedia createNewMedia]; //Neues Dokument anlegen
        media.uniqueID = uniqueID; //Generierte UUID überschreiben
    }
    else if (![media.hashCode isEqualToString:[dict valueForKey:@"hashCode"]])
    {
        media.isDownloaded = [NSNumber numberWithBool:NO];
    }
    
    [media MR_importValuesForKeysWithObject:dict]; //MR_importValuesForKeysWithObject füllt alle Daten in die entsprechenden Felder wenn in UserInfo "mappedKeyName" eingetragen ist!
    
    media.transferDate = [newTransferDate fromISO8601FormatedString]; //Timestamp
    media.documentState = [NSNumber numberWithInt:SAGDocumentStateCommited]; //Datensatz wurde vom mCube bestätigt !!!
    media.alternationDate = [NSDate date]; //Aktualisierung speichern
    
    return YES;
}

#pragma mark - Webservice Settings

+ (NSString *)localizedClassName
{
    return NSLocalizedString(@"Customer Mediainfos", @"SBCustomerMedia"); //Plural
}

+ (NSString *)webserviceUpdate
{
    return @"V3GetCustomerMedia";
}

+ (NSString *)webserviceDelete
{
    return @"V3GetCustomerMediaDeleted";
}

+ (NSString *)webserviceActionState
{
    return @"actionFlag";
}

+ (NSString *)webserviceUniqueID
{
    return @"fileName";
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
    return @"customerMedias";
}

+ (NSString *)webserviceDataBlockDeleted
{
    return @"customerMediasDeleted";
}

@end
