//
//  SBItemGroup+Extensions.h
//  SalesBook
//
//  Created by Andreas Kucher on 08.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBItemGroup.h"

@interface SBItemGroup (Extensions)

+ (SBItemGroup *)createNewItemGroup;

+ (SBItemGroup *)getItemGroupWithUniqueID:(NSString *)uniqueID;

+ (SBItemGroup *)getItemGroupWithItemGroupNumber:(NSString *)itemGroupNumber;

+ (NSString *)localizedClassName;

+ (NSString *)webserviceUpdate;
+ (NSString *)webserviceDelete;
+ (NSString *)webserviceUniqueID;
+ (NSString *)webserviceActionState;
+ (NSString *)webserviceTransferDate;
+ (NSString *)webserviceBlockSize;
+ (NSString *)webserviceDataBlock;

+ (BOOL)updateDocumentFromDictionary:(NSDictionary *)dict;

- (NSString *)itemGroupDenoation;

@end