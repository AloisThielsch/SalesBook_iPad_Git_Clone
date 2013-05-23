//
//  SBStock+Extensions.h
//  SalesBook
//
//  Created by Andreas Kucher on 18.01.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBStock.h"

@interface SBStock (Extensions)

+ (SBStock *)createNewStock;

+ (SBStock *)getStockWithUniqueID:(NSString *)uniqueID;

+ (NSString *)localizedClassName;

+ (NSString *)webserviceUpdate;
+ (NSString *)webserviceDelete;
+ (NSString *)webserviceUniqueID;
+ (NSString *)webserviceActionState;
+ (NSString *)webserviceTransferDate;
+ (NSString *)webserviceBlockSize;
+ (NSString *)webserviceDataBlock;

+ (BOOL)updateDocumentFromDictionary:(NSDictionary *)dict;

+ (void)renewReferences; //Nicht referenzierte Objekte zuordnen

- (UIImage *)getSignalLightImage;

@end
