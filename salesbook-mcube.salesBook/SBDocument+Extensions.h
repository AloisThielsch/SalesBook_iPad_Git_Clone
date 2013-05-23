//
//  SBDocument+Extensions.h
//  SalesBook
//
//  Created by Andreas Kucher on 14.12.12.
//  Copyright (c) 2012 Siller AG. All rights reserved.
//

#import "SBDocument.h"

@interface SBDocument (Extensions)

+ (SBDocument *)createNewDocument;

+ (SBDocument *)getDocumentWithUniqueID:(NSString *)uniqueID;

+ (void)renewReferences;

+ (NSString *)localizedClassName;

+ (NSString *)webserviceUpdate;
+ (NSString *)webserviceDelete;
+ (NSString *)webserviceUniqueID;
+ (NSString *)webserviceActionState;
+ (NSString *)webserviceTransferDate;
+ (NSString *)webserviceBlockSize;
+ (NSString *)webserviceDataBlock;

+ (BOOL)updateDocumentFromDictionary:(NSDictionary *)dict;

+ (NSArray *)numberOfDocumentsGroupByDocumentTypeWithCustomer:(SBCustomer *)customer;
+ (NSArray *)getDocumentsOfDocumentType:(NSInteger)documentType withCustomer:(SBCustomer *)customer;

@end
