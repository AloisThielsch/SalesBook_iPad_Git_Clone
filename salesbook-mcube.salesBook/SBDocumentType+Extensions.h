//
//  SBDocumentType+Extensions.h
//  SalesBook
//
//  Created by Andreas Kucher on 16.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBDocumentType.h"

@interface SBDocumentType (Extensions)

+ (SBDocumentType *)createNewDocumentType;

+ (SBDocumentType *)getDocumentTypeWithUniqueID:(NSString *)uniqueID;

+ (NSString *)localizedClassName;

+ (NSString *)webserviceUpdate;
+ (NSString *)webserviceDelete;
+ (NSString *)webserviceUniqueID;
+ (NSString *)webserviceActionState;
+ (NSString *)webserviceTransferDate;
+ (NSString *)webserviceBlockSize;
+ (NSString *)webserviceDataBlock;

+ (BOOL)updateDocumentFromDictionary:(NSDictionary *)dict;

+ (NSString *)getDenoationWith:(enum SAGDocumentType)documentType andLangauge:(NSString *)language;

@end
