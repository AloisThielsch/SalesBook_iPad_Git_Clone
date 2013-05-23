//
//  SBAddress+Extensions.h
//  SalesBook
//
//  Created by Andreas Kucher on 18.01.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBAddress.h"

@interface SBAddress (Extensions)

+ (SBAddress *)createNewAddress;

+ (SBAddress *)getAddressWithUniqueID:(NSString *)uniqueID;

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

- (NSString *)zipCity;

@end
