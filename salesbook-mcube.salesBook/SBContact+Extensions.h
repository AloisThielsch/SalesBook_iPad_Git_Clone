//
//  SBContact+Extensions.h
//  SalesBook
//
//  Created by Andreas Kucher on 21.01.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBContact.h"

@interface SBContact (Extensions)

+ (SBContact *)createNewContact;

+ (SBContact *)getContactWithUniqueID:(NSString *)uniqueID;

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
