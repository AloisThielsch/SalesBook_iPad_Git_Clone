//
//  SBPrice+Extensions.h
//  SalesBook
//
//  Created by Andreas Kucher on 20.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBPrice.h"

@interface SBPrice (Extensions)

+ (SBPrice *)createNewPrice;

+ (SBPrice *)getPriceWithUniqueID:(NSString *)uniqueID;

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
