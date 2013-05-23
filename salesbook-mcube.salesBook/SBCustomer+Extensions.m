//
//  SBCustomer+Extensions.m
//  SalesBook
//
//  Created by Andreas Kucher on 21.01.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBCustomer+Extensions.h"

#import "SAGSyncManager.h"
#import "SAGLoginManager.h"

#import "SBAddress+Extensions.h"
#import "SBPriceGroup+Extensions.h"

#import "SBDocument+Extensions.h"

#import "NSPredicate+Search.h"

@implementation SBCustomer (Extensions)

+ (SBCustomer *)createNewCustomer
{
    SBCustomer *customer = [SBCustomer MR_createEntity];
    
    customer.uniqueID = [NSString generateUniqueID]; //generateUniqueID
    customer.creationDate = [NSDate date]; //Anlage Datum aufheben
    
    return customer;
}

+ (SBCustomer *)getCustomerWithUniqueID:(NSString *)uniqueID
{
    return [SBCustomer MR_findFirstByAttribute:@"uniqueID" withValue:uniqueID];
}

+ (SBCustomer *)getCustomerWithCustomerNumber:(NSString *)customerNumber
{
    return [SBCustomer MR_findFirstWithPredicate:[NSPredicate prediacteForNormalizedValue:customerNumber andKey:@"customerNumber"]];
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
    
    SBCustomer *customer = [self getCustomerWithUniqueID:uniqueID];
    
    if ([[dict valueForKey:[self webserviceActionState]] intValue] == SAGActiveStateDeleted) //Prüfen ob gelöscht werden muss!
    {
        if (customer) //Falls das Dokument schon exisitert!
        {
            [customer MR_deleteEntity]; //Das bestehende Dokument löschen!
        }
        return YES;
    }
    
    if (!customer)
    {
        customer = [self createNewCustomer]; //Neues Dokument anlegen
        customer.uniqueID = uniqueID; //Generierte UUID überschreiben
    }
    
    [customer MR_importValuesForKeysWithObject:dict]; //MR_importValuesForKeysWithObject füllt alle Daten in die entsprechenden Felder wenn in UserInfo "mappedKeyName" eingetragen ist!
    
    if (![SBAddress updateDocumentFromDictionary:[dict valueForKey:@"address"]]) //PrimaryAddress
    {
        NSString *errorMessage = [NSString stringWithFormat:@"Error updating %@ from Dictionary! Reason: %@ is missing! (%@)", [[self class] description], @"primaryAddress", uniqueID];
        [[SAGSyncManager sharedClient] addErrorWithMessage:errorMessage andUserInfo:dict];
    }
    
    [customer setAttributesfromDictionary:[dict valueForKey:@"customFieldValues"]]; //CustomFields
    
    customer.transferDate = [newTransferDate fromISO8601FormatedString]; //Timestamp
    customer.documentState = [NSNumber numberWithInt:SAGDocumentStateCommited]; //Datensatz wurde vom mCube bestätigt !!!
    customer.alternationDate = [NSDate date]; //Aktualisierung speichern
    
    return YES;
}

#pragma mark - Webservice Settings

+ (NSString *)localizedClassName
{
    return NSLocalizedString(@"Customers", @"SBCustomer"); //Plural
}

+ (NSString *)webserviceUpdate
{
    return @"V3GetCustomer";
}

+ (NSString *)webserviceDelete
{
    return @"V3GetCustomerDeleted";
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
    return @"customers";
}

+ (NSString *)webserviceDataBlockDeleted
{
    return @"customersDeleted";
}

#pragma mark - reference

- (void)setOwningCustomer:(NSString *)owningCustomer
{
    [self willChangeValueForKey:@"owningCustomer"];
    [self setPrimitiveValue:owningCustomer forKey:@"owningCustomer"];
    [self didChangeValueForKey:@"owningCustomer"];
    
    [self setTopCustomer:[SBCustomer getCustomerWithCustomerNumber:owningCustomer]];
}

- (void)setPriceGroupNumber:(NSString *)priceGroupNumber
{
    [self willChangeValueForKey:@"priceGroupNumber"];
    [self setPrimitiveValue:priceGroupNumber forKey:@"priceGroupNumber"];
    [self didChangeValueForKey:@"priceGroupNumber"];
    
    [self setPriceGroup:[SBPriceGroup getPriceGroupWithPriceGroupNumber:priceGroupNumber]]; //Erstellt automatisch eine PriceGroup!!!
}

+ (void)renewReferences //Nicht referenzierte Objekte zuordnen
{
    NSArray *notReferencedObjects = [SBCustomer MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"topCustomer == nil AND owningCustomer != nil"]];
    
    if (notReferencedObjects)
    {
        [notReferencedObjects enumerateObjectsUsingBlock:^(SBCustomer *subCustomer, NSUInteger idx, BOOL *stop) {
            
            [subCustomer setTopCustomer:[SBCustomer getCustomerWithCustomerNumber:subCustomer.owningCustomer]];
        }];
    }
}

#pragma mark - Addresses

- (SBAddress *)primaryAddress
{
	__block SBAddress *primaryAddress = nil;
    
    [self.addresses enumerateObjectsUsingBlock:^(SBAddress *address, BOOL *stop) {
        
        if (address.addressType.intValue == SAGAddressTypePrimaryAddress)
        {
            primaryAddress = address;
            *stop = YES;
        }
    }];
    
	return primaryAddress;
}

- (NSSet *)getDeliveryAddressesWithFallback:(BOOL)fallback
{
    NSMutableOrderedSet *addresses = [NSMutableOrderedSet new];
    
    if ([[[SAGSettingsManager sharedManager] settingForKey:@"isFindDeliveryAddressesFromSubCustomersEnabled" withDefaultValue:@NO] boolValue])
    {
        for (SBCustomer *subCustomer in self.subCustomers)
        {
            NSArray *subAddresses = [[self.topCustomer getAddressesFilterByType:@[[NSNumber numberWithInt:SAGAddressTypeDeliveryAddress]]] allObjects]; //Hier werden auch die Lieferanschriften von Sub Kunden berücksichtigt!
            
            if (subAddresses.count > 0) [addresses addObjectsFromArray:subAddresses];
        }
    }
    
    NSSet *deliveryAddresses = [self getAddressesFilterByType:@[[NSNumber numberWithInt:SAGAddressTypeDeliveryAddress]]];
    
    if (deliveryAddresses.count > 0) return deliveryAddresses;
    
    if (!fallback) return nil; //Fallback = Es wird die Primäradresse ausgegeben wenn nix vorhanden ist!
    
    return [self getAddressesFilterByType:@[[NSNumber numberWithInt:SAGAddressTypePrimaryAddress]]]; //Fallback auf die Primäradresse
}

- (NSSet *)getInvoiceAddressesWithFallback:(BOOL)fallback
{
    NSMutableOrderedSet *addresses = [NSMutableOrderedSet new];
    
    if ([[[SAGSettingsManager sharedManager] settingForKey:@"isFindInvoiceAddressesFromTopCustomerEnabled" withDefaultValue:@YES] boolValue])
    {
        NSArray *topAddresses = [[self.topCustomer getAddressesFilterByType:@[[NSNumber numberWithInt:SAGAddressTypeInvoiceAddress]]] allObjects]; //Hier werden auch die Rechnungsadressen vom Top Kunden berücksichtigt!
        
        if (topAddresses.count > 0) [addresses addObjectsFromArray:topAddresses];
    }
    
    NSArray *myAddresses = [[self getAddressesFilterByType:@[[NSNumber numberWithInt:SAGAddressTypeInvoiceAddress]]] allObjects]; //Und hier die eigenen!
    
    if (myAddresses.count > 0) [addresses addObjectsFromArray:myAddresses];
    
    if (addresses.count > 0) return addresses.set; //Wenn Adressen gefunden wurden werden diese zurückgegeben
    
    if (!fallback) return nil; //Fallback = Es wird die Primäradresse ausgegeben wenn nix vorhanden ist!
    
    return [self getAddressesFilterByType:@[[NSNumber numberWithInt:SAGAddressTypePrimaryAddress]]]; //Fallback auf die Primäradresse
}

- (NSSet *)getAddressesFilterByType:(NSArray *)allowedAddressTypes
{
    return [self.addresses filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"addressType in %@", allowedAddressTypes]];
}

- (NSUInteger)noOfAdresses
{
    int noOfAdresses = 1;
    
    noOfAdresses += [[self getInvoiceAddressesWithFallback:NO] count];
    noOfAdresses += [[self getDeliveryAddressesWithFallback:NO] count];
    
    return noOfAdresses;
}

@end
