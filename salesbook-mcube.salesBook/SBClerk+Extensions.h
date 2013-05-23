//
//  SBClerk+Extensions.h
//  SalesBook
//
//  Created by Andreas Kucher on 13.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBClerk.h"

@interface SBClerk (Extensions)

+ (SBClerk *)createNewClerk;
+ (SBClerk *)getClerkWithUniqueID:(NSString *)uniqueID;

+ (NSString *)localizedClassName;

+ (NSString *)webserviceUpdate;
+ (NSString *)webserviceDelete;
+ (NSString *)webserviceUniqueID;
+ (NSString *)webserviceActionState;
+ (NSString *)webserviceTransferDate;
+ (NSString *)webserviceBlockSize;
+ (NSString *)webserviceDataBlock;

+ (BOOL)shouldRemoveDataBeforeImport;

+ (BOOL)updateDocumentFromDictionary:(NSDictionary *)dict;

- (SBLanguage *)getDefaultLanguage;

@end
