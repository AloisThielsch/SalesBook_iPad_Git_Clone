//
//  SBAddress+Extensions.m
//  SalesBook
//
//  Created by Andreas Kucher on 18.01.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBAddress+Extensions.h"

#import "SAGSyncManager.h"
#import "SBCustomer+Extensions.h"

@implementation SBAddress (Extensions)

+ (SBAddress *)createNewAddress
{
    SBAddress *address = [SBAddress MR_createEntity];
    
    address.uniqueID = [NSString generateUniqueID]; //generateUniqueID
    address.creationDate = [NSDate date]; //Anlage Datum aufheben
    
    return address;
}

+ (SBAddress *)getAddressWithUniqueID:(NSString *)uniqueID
{
    return [SBAddress MR_findFirstByAttribute:@"uniqueID" withValue:uniqueID];
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
    
    SBAddress *address = [self getAddressWithUniqueID:uniqueID];
    
    if ([[dict valueForKey:[self webserviceActionState]] intValue] == SAGActiveStateDeleted) //Prüfen ob gelöscht werden muss!
    {
        if (address) //Falls das Dokument schon exisitert!
        {
            [address MR_deleteEntity]; //Das bestehende Dokument löschen!
        }
        return YES;
    }
    
    if (!address)
    {
        address = [self createNewAddress]; //Neues Dokument anlegen
        address.uniqueID = uniqueID; //Generierte UUID überschreiben
    }
    
    [address MR_importValuesForKeysWithObject:dict]; //MR_importValuesForKeysWithObject füllt alle Daten in die entsprechenden Felder wenn in UserInfo "mappedKeyName" eingetragen ist!
    
    [address setAttributesfromDictionary:[dict valueForKey:@"customFieldValues"]]; //CustomFields
    
    address.transferDate = [newTransferDate fromISO8601FormatedString]; //Timestamp
    address.documentState = [NSNumber numberWithInt:SAGDocumentStateCommited]; //Datensatz wurde vom mCube bestätigt !!!
    address.alternationDate = [NSDate date]; //Aktualisierung speichern
    
    return YES;
}

#pragma mark - Webservice Settings

+ (NSString *)localizedClassName
{
    return NSLocalizedString(@"Addresses", @"SBAddress"); //Plural
}

+ (NSString *)webserviceUpdate
{
    return @"V3GetCustomerAddress";
}

+ (NSString *)webserviceDelete
{
    return @"V3GetCustomerAddressDeleted";
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
    return @"customerAddresses";
}

+ (NSString *)webserviceDataBlockDeleted
{
    return @"customerAddressesDeleted";
}

#pragma mark - Class Methods

- (NSString *)zipCity
{
    NSMutableString *returnValue = [NSMutableString new];
    
    if (self.postalCode.length > 0)
    {
        [returnValue appendFormat:@"%@ ", self.postalCode];
    }
    
    if (self.city.length > 0)
    {
        [returnValue appendString:self.city];
    }
    
    return returnValue;
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
    NSArray *notReferencedObjects = [SBAddress MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"customer == nil"]];
    
    if (notReferencedObjects)
    {
        [notReferencedObjects enumerateObjectsUsingBlock:^(SBAddress *address, NSUInteger idx, BOOL *stop) {
            
            address.customer = [SBCustomer MR_findFirstByAttribute:@"customerNumber" withValue:address.customerNumber];
        }];
    }
}

@end
