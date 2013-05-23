//
//  SBCatalog+Extensions.h
//  SalesBook
//
//  Created by Andreas Kucher on 07.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBCatalog.h"

@interface SBCatalog (Extensions)

+ (SBCatalog *)createNewCatalog;

+ (SBCatalog *)getCatalogWithUniqueID:(NSString *)uniqueID;

+ (NSString *)localizedClassName;

+ (NSString *)webserviceUpdate;
+ (NSString *)webserviceDelete;
+ (NSString *)webserviceUniqueID;
+ (NSString *)webserviceActionState;
+ (NSString *)webserviceTransferDate;
+ (NSString *)webserviceBlockSize;
+ (NSString *)webserviceDataBlock;

+ (BOOL)updateDocumentFromDictionary:(NSDictionary *)dict;

+ (void)renewReferences;

- (NSString *)catalogDenoation;

@end
