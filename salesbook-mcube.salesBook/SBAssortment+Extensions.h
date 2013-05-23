//
//  SBAssortment+Extensions.h
//  SalesBook
//
//  Created by Andreas Kucher on 17.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBAssortment.h"

@interface SBAssortment (Extensions)

+ (SBAssortment *)createNewAssortment;

+ (SBAssortment *)getAssortmentWithUniqueID:(NSString *)uniqueID;

+ (NSString *)localizedClassName;

+ (NSString *)webserviceUpdate;
+ (NSString *)webserviceDelete;
+ (NSString *)webserviceUniqueID;
+ (NSString *)webserviceActionState;
+ (NSString *)webserviceTransferDate;
+ (NSString *)webserviceBlockSize;
+ (NSString *)webserviceDataBlock;

+ (BOOL)updateDocumentFromDictionary:(NSDictionary *)dict;

+ (NSDictionary *)sizeIndexWithAssortment:(NSString *)assortment andSeason:(NSString *)season;

@end
