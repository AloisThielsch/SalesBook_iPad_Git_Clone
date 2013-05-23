//
//  SBCustomer.m
//  SalesBook
//
//  Created by Andreas Kucher on 22.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBCustomer.h"
#import "SBAddress.h"
#import "SBAttribute.h"
#import "SBContact.h"
#import "SBCustomer.h"
#import "SBDocument.h"
#import "SBMedia.h"
#import "SBPriceGroup.h"


@implementation SBCustomer

@dynamic activeState;
@dynamic alternationDate;
@dynamic creationDate;
@dynamic creditLimit;
@dynamic currency;
@dynamic customerNumber;
@dynamic customerType;
@dynamic discountPercentage;
@dynamic documentState;
@dynamic inactive;
@dynamic matchcode1;
@dynamic matchcode2;
@dynamic owningCustomer;
@dynamic preferedLanguage;
@dynamic priceGroupNumber;
@dynamic resubmissionDate;
@dynamic resubmissionDays;
@dynamic sortOrder;
@dynamic transferDate;
@dynamic transferState;
@dynamic uniqueID;
@dynamic vatID;
@dynamic addresses;
@dynamic attributes;
@dynamic contacts;
@dynamic documents;
@dynamic mediaFiles;
@dynamic priceGroup;
@dynamic subCustomers;
@dynamic topCustomer;

@end
