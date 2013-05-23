//
//  SBDocument.m
//  SalesBook
//
//  Created by Julian Knab on 07.05.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBDocument.h"
#import "SBAddress.h"
#import "SBAttribute.h"
#import "SBCustomer.h"
#import "SBDocumentPosition.h"
#import "SBRebate.h"


@implementation SBDocument

@dynamic activeState;
@dynamic alternationDate;
@dynamic creationDate;
@dynamic currencyCode;
@dynamic customerNumber;
@dynamic documentNumber;
@dynamic documentState;
@dynamic documentType;
@dynamic earliestDeliveryDate;
@dynamic externalReference;
@dynamic futureType;
@dynamic humanReadableName;
@dynamic latestDeliveryDate;
@dynamic referenceNumber;
@dynamic transferDate;
@dynamic transferState;
@dynamic uniqueID;
@dynamic text;
@dynamic attributes;
@dynamic customer;
@dynamic deliveryAddress;
@dynamic invoiceAddress;
@dynamic positions;
@dynamic rebate;

@end
