//
//  SBSalesOrganization+Extensions.m
//  SalesBook
//
//  Created by Andreas Kucher on 13.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBSalesOrganization+Extensions.h"

#import "SBPriceGroup+Extensions.h"
#import "SAGSyncManager.h"

@implementation SBSalesOrganization (Extensions)

+ (SBSalesOrganization *)createNewSalesOrganization
{
    SBSalesOrganization *salesOrganization = [SBSalesOrganization MR_createEntity];
    
    salesOrganization.uniqueID = [NSString generateUniqueID]; //generateUniqueID
    salesOrganization.creationDate = [NSDate date]; //Anlage Datum aufheben
    
    return salesOrganization;
}

+ (SBSalesOrganization *)getSalesOrganizationWithUniqueID:(NSString *)uniqueID
{
    return [SBSalesOrganization MR_findFirstByAttribute:@"uniqueID" withValue:uniqueID];
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
    
    SBSalesOrganization *salesOrganization = [self getSalesOrganizationWithUniqueID:uniqueID];
    
    if ([[dict valueForKey:[self webserviceActionState]] intValue] == SAGActiveStateDeleted) //Prüfen ob gelöscht werden muss!
    {
        if (salesOrganization) //Falls das Dokument schon exisitert!
        {
            [salesOrganization MR_deleteEntity]; //Das bestehende Dokument löschen!
        }
        return YES;
    }
    
    if (!salesOrganization)
    {
        salesOrganization = [self createNewSalesOrganization]; //Neues Dokument anlegen
        salesOrganization.uniqueID = uniqueID; //Generierte UUID überschreiben
    }
    
    [salesOrganization MR_importValuesForKeysWithObject:dict]; //MR_importValuesForKeysWithObject füllt alle Daten in die entsprechenden Felder wenn in UserInfo "mappedKeyName" eingetragen ist!
    
    salesOrganization.transferDate = [newTransferDate fromISO8601FormatedString]; //Timestamp
    salesOrganization.documentState = [NSNumber numberWithInt:SAGDocumentStateCommited]; //Datensatz wurde vom mCube bestätigt !!!
    salesOrganization.alternationDate = [NSDate date]; //Aktualisierung speichern
    
    return YES;
}

#pragma mark - Webservice Settings

+ (NSString *)localizedClassName
{
    return NSLocalizedString(@"Sales Organizations", @"SBSalesOrganization"); //Plural
}

+ (NSString *)webserviceUpdate
{
    return @"V3GetSalesOrg";
}

+ (NSString *)webserviceDelete
{
    return @"V3GetSalesOrgDeleted";
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
    return @"1000";
}

+ (NSString *)webserviceDataBlock
{
    return @"salesOrgs";
}

+ (NSString *)webserviceDataBlockDeleted
{
    return @"salesOrgsDeleted";
}

- (void)setDefaultPriceGroup:(NSString *)defaultPriceGroup
{
    [self willChangeValueForKey:@"defaultPriceGroup"];
    [self setPrimitiveValue:defaultPriceGroup forKey:@"defaultPriceGroup"];
    [self didChangeValueForKey:@"defaultPriceGroup"];
    
    [self setPriceGroup:[SBPriceGroup getPriceGroupWithPriceGroupNumber:defaultPriceGroup]];
}   


@end
