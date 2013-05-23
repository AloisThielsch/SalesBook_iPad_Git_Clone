//
//  SBAddress.h
//  SalesBook
//
//  Created by Andreas Kucher on 22.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SBAttribute, SBClerk, SBContact, SBCustomer, SBDocument;

@interface SBAddress : NSManagedObject

@property (nonatomic, retain) NSNumber * activeState;
@property (nonatomic, retain) NSString * addressNumber;
@property (nonatomic, retain) NSNumber * addressType;
@property (nonatomic, retain) NSDate * alternationDate;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSString * customerNumber;
@property (nonatomic, retain) NSNumber * documentState;
@property (nonatomic, retain) NSString * fax;
@property (nonatomic, retain) NSString * gln;
@property (nonatomic, retain) NSString * homepage;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * mail;
@property (nonatomic, retain) NSString * mobile;
@property (nonatomic, retain) NSString * name1;
@property (nonatomic, retain) NSString * name2;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * postalCode;
@property (nonatomic, retain) NSString * postBox;
@property (nonatomic, retain) NSString * postBoxCity;
@property (nonatomic, retain) NSString * postBoxPostalCode;
@property (nonatomic, retain) NSString * street;
@property (nonatomic, retain) NSDate * transferDate;
@property (nonatomic, retain) NSNumber * transferState;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSSet *attributes;
@property (nonatomic, retain) SBClerk *clerk;
@property (nonatomic, retain) NSSet *contacts;
@property (nonatomic, retain) SBCustomer *customer;
@property (nonatomic, retain) NSSet *deliveryAddresses;
@property (nonatomic, retain) NSSet *invoiceAddresses;
@end

@interface SBAddress (CoreDataGeneratedAccessors)

- (void)addAttributesObject:(SBAttribute *)value;
- (void)removeAttributesObject:(SBAttribute *)value;
- (void)addAttributes:(NSSet *)values;
- (void)removeAttributes:(NSSet *)values;

- (void)addContactsObject:(SBContact *)value;
- (void)removeContactsObject:(SBContact *)value;
- (void)addContacts:(NSSet *)values;
- (void)removeContacts:(NSSet *)values;

- (void)addDeliveryAddressesObject:(SBDocument *)value;
- (void)removeDeliveryAddressesObject:(SBDocument *)value;
- (void)addDeliveryAddresses:(NSSet *)values;
- (void)removeDeliveryAddresses:(NSSet *)values;

- (void)addInvoiceAddressesObject:(SBDocument *)value;
- (void)removeInvoiceAddressesObject:(SBDocument *)value;
- (void)addInvoiceAddresses:(NSSet *)values;
- (void)removeInvoiceAddresses:(NSSet *)values;

@end
