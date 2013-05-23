//
//  SBSalesOrganization+Extensions.h
//  SalesBook
//
//  Created by Andreas Kucher on 13.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBSalesOrganization.h"

@interface SBSalesOrganization (Extensions)

+ (SBSalesOrganization *)createNewSalesOrganization;

+ (SBSalesOrganization *)getSalesOrganizationWithUniqueID:(NSString *)uniqueID;

+ (NSString *)localizedClassName;

+ (NSString *)webserviceUpdate;
+ (NSString *)webserviceDelete;
+ (NSString *)webserviceUniqueID;
+ (NSString *)webserviceActionState;
+ (NSString *)webserviceTransferDate;
+ (NSString *)webserviceBlockSize;
+ (NSString *)webserviceDataBlock;

+ (BOOL)updateDocumentFromDictionary:(NSDictionary *)dict;

@end
