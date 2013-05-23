//
//  SBContact+Extensions.m
//  SalesBook
//
//  Created by Andreas Kucher on 21.01.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBContact+Extensions.h"

#import "SAGSyncManager.h"
#import "SBCustomer+Extensions.h"
#import "SBAddress+Extensions.h"

@implementation SBContact (Extensions)

+ (SBContact *)createNewContact
{
    SBContact *contact = [SBContact MR_createEntity];
    
    contact.uniqueID = [NSString generateUniqueID]; //generateUniqueID
    contact.creationDate = [NSDate date]; //Anlage Datum aufheben
    
    return contact;
}

+ (SBContact *)getContactWithUniqueID:(NSString *)uniqueID
{
    return [SBContact MR_findFirstByAttribute:@"uniqueID" withValue:uniqueID];
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
    
    SBContact *contact = [self getContactWithUniqueID:uniqueID];
    
    if ([[dict valueForKey:[self webserviceActionState]] intValue] == SAGActiveStateDeleted) //Prüfen ob gelöscht werden muss!
    {
        if (contact) //Falls das Dokument schon exisitert!
        {
            [contact MR_deleteEntity]; //Das bestehende Dokument löschen!
        }
        return YES;
    }
    
    if (!contact)
    {
        contact = [self createNewContact]; //Neues Dokument anlegen
        contact.uniqueID = uniqueID; //Generierte UUID überschreiben
    }
    
    [contact MR_importValuesForKeysWithObject:dict]; //MR_importValuesForKeysWithObject füllt alle Daten in die entsprechenden Felder wenn in UserInfo "mappedKeyName" eingetragen ist!
    
    //[contact setAttributesfromDictionary:[dict valueForKey:@"customFieldValues"]]; //CustomFields
    
    contact.transferDate = [newTransferDate fromISO8601FormatedString]; //Timestamp
    contact.documentState = [NSNumber numberWithInt:SAGDocumentStateCommited]; //Datensatz wurde vom mCube bestätigt !!!
    contact.alternationDate = [NSDate date]; //Aktualisierung speichern
    
    return YES;
}

#pragma mark - Webservice Settings

+ (NSString *)localizedClassName
{
    return NSLocalizedString(@"Contacts", @"SBContact"); //Plural
}

+ (NSString *)webserviceUpdate
{
    return @"V3GetCustomerContact";
}

+ (NSString *)webserviceDelete
{
    return @"V3GetCustomerContactDeleted";
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
    return @"customerContacts";
}

+ (NSString *)webserviceDataBlockDeleted
{
    return @"customerContactsDeleted";
}

#pragma mark - reference

- (void)setCustomerNumber:(NSString *)customerNumber
{    
    [self willChangeValueForKey:@"customerNumber"];
    [self setPrimitiveValue:customerNumber forKey:@"customerNumber"];
    [self didChangeValueForKey:@"customerNumber"];
    
    [self setCustomer:[SBCustomer getCustomerWithCustomerNumber:customerNumber]];
}

+ (void)renewReferences //Nicht referenzierte Objekte zuordnen
{
    NSArray *notReferencedObjects = [SBContact MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"customer == nil"]];
    
    if (notReferencedObjects)
    {
        [notReferencedObjects enumerateObjectsUsingBlock:^(SBContact *contact, NSUInteger idx, BOOL *stop) {
            
            contact.customer = [SBCustomer MR_findFirstByAttribute:@"customerNumber" withValue:contact.customerNumber];
        }];
    }
}

@end
