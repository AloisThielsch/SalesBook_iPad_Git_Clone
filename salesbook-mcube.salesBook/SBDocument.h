//
//  SBDocument.h
//  SalesBook
//
//  Created by Julian Knab on 07.05.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SBAddress, SBAttribute, SBCustomer, SBDocumentPosition, SBRebate;

@interface SBDocument : NSManagedObject

@property (nonatomic, retain) NSNumber * activeState;
@property (nonatomic, retain) NSDate * alternationDate;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSString * currencyCode;
@property (nonatomic, retain) NSString * customerNumber;
@property (nonatomic, retain) NSString * documentNumber;
@property (nonatomic, retain) NSNumber * documentState;
@property (nonatomic, retain) NSNumber * documentType;
@property (nonatomic, retain) NSDate * earliestDeliveryDate;
@property (nonatomic, retain) NSString * externalReference;
@property (nonatomic, retain) NSNumber * futureType;
@property (nonatomic, retain) NSString * humanReadableName;
@property (nonatomic, retain) NSDate * latestDeliveryDate;
@property (nonatomic, retain) NSString * referenceNumber;
@property (nonatomic, retain) NSDate * transferDate;
@property (nonatomic, retain) NSNumber * transferState;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSSet *attributes;
@property (nonatomic, retain) SBCustomer *customer;
@property (nonatomic, retain) SBAddress *deliveryAddress;
@property (nonatomic, retain) SBAddress *invoiceAddress;
@property (nonatomic, retain) NSSet *positions;
@property (nonatomic, retain) SBRebate *rebate;
@end

@interface SBDocument (CoreDataGeneratedAccessors)

- (void)addAttributesObject:(SBAttribute *)value;
- (void)removeAttributesObject:(SBAttribute *)value;
- (void)addAttributes:(NSSet *)values;
- (void)removeAttributes:(NSSet *)values;

- (void)addPositionsObject:(SBDocumentPosition *)value;
- (void)removePositionsObject:(SBDocumentPosition *)value;
- (void)addPositions:(NSSet *)values;
- (void)removePositions:(NSSet *)values;

@end
