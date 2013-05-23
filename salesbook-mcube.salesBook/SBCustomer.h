//
//  SBCustomer.h
//  SalesBook
//
//  Created by Andreas Kucher on 22.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SBAddress, SBAttribute, SBContact, SBCustomer, SBDocument, SBMedia, SBPriceGroup;

@interface SBCustomer : NSManagedObject

@property (nonatomic, retain) NSNumber * activeState;
@property (nonatomic, retain) NSDate * alternationDate;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSNumber * creditLimit;
@property (nonatomic, retain) NSString * currency;
@property (nonatomic, retain) NSString * customerNumber;
@property (nonatomic, retain) NSString * customerType;
@property (nonatomic, retain) NSNumber * discountPercentage;
@property (nonatomic, retain) NSNumber * documentState;
@property (nonatomic, retain) NSNumber * inactive;
@property (nonatomic, retain) NSString * matchcode1;
@property (nonatomic, retain) NSString * matchcode2;
@property (nonatomic, retain) NSString * owningCustomer;
@property (nonatomic, retain) NSString * preferedLanguage;
@property (nonatomic, retain) NSString * priceGroupNumber;
@property (nonatomic, retain) NSDate * resubmissionDate;
@property (nonatomic, retain) NSNumber * resubmissionDays;
@property (nonatomic, retain) NSString * sortOrder;
@property (nonatomic, retain) NSDate * transferDate;
@property (nonatomic, retain) NSNumber * transferState;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSString * vatID;
@property (nonatomic, retain) NSSet *addresses;
@property (nonatomic, retain) NSSet *attributes;
@property (nonatomic, retain) NSSet *contacts;
@property (nonatomic, retain) NSSet *documents;
@property (nonatomic, retain) NSSet *mediaFiles;
@property (nonatomic, retain) SBPriceGroup *priceGroup;
@property (nonatomic, retain) NSSet *subCustomers;
@property (nonatomic, retain) SBCustomer *topCustomer;
@end

@interface SBCustomer (CoreDataGeneratedAccessors)

- (void)addAddressesObject:(SBAddress *)value;
- (void)removeAddressesObject:(SBAddress *)value;
- (void)addAddresses:(NSSet *)values;
- (void)removeAddresses:(NSSet *)values;

- (void)addAttributesObject:(SBAttribute *)value;
- (void)removeAttributesObject:(SBAttribute *)value;
- (void)addAttributes:(NSSet *)values;
- (void)removeAttributes:(NSSet *)values;

- (void)addContactsObject:(SBContact *)value;
- (void)removeContactsObject:(SBContact *)value;
- (void)addContacts:(NSSet *)values;
- (void)removeContacts:(NSSet *)values;

- (void)addDocumentsObject:(SBDocument *)value;
- (void)removeDocumentsObject:(SBDocument *)value;
- (void)addDocuments:(NSSet *)values;
- (void)removeDocuments:(NSSet *)values;

- (void)addMediaFilesObject:(SBMedia *)value;
- (void)removeMediaFilesObject:(SBMedia *)value;
- (void)addMediaFiles:(NSSet *)values;
- (void)removeMediaFiles:(NSSet *)values;

- (void)addSubCustomersObject:(SBCustomer *)value;
- (void)removeSubCustomersObject:(SBCustomer *)value;
- (void)addSubCustomers:(NSSet *)values;
- (void)removeSubCustomers:(NSSet *)values;

@end
