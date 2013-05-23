//
//  SBCustomer+Extensions.h
//  SalesBook
//
//  Created by Andreas Kucher on 21.01.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBCustomer.h"

@interface SBCustomer (Extensions)

+ (SBCustomer *)createNewCustomer;

+ (SBCustomer *)getCustomerWithUniqueID:(NSString *)uniqueID;
+ (SBCustomer *)getCustomerWithCustomerNumber:(NSString *)customerNumber;

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

- (SBAddress *)primaryAddress;

- (NSSet *)getDeliveryAddressesWithFallback:(BOOL)fallback; //Fallback = Es wird die Primäradresse ausgegeben wenn nix vorhanden ist!
- (NSSet *)getInvoiceAddressesWithFallback:(BOOL)fallback; //Fallback = Es wird die Primäradresse ausgegeben wenn nix vorhanden ist!

- (NSUInteger)noOfAdresses;

@end
