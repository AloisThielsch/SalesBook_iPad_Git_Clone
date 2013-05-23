//
//  SBItem+Extensions.h
//  SalesBook
//
//  Created by Andreas Kucher on 28.02.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBItem.h"

@interface SBItem (Extensions)

+ (SBItem *)createNewItem;

+ (SBItem *)getItemWithUniqueID:(NSString *)uniqueID;
+ (SBItem *)getItemWithItemNumber:(NSString *)itemNumber;

+ (NSString *)localizedClassName;

+ (NSString *)webserviceUpdate;
+ (NSString *)webserviceDelete;
+ (NSString *)webserviceUniqueID;
+ (NSString *)webserviceActionState;
+ (NSString *)webserviceTransferDate;
+ (NSString *)webserviceBlockSize;
+ (NSString *)webserviceDataBlock;

+ (BOOL)updateDocumentFromDictionary:(NSDictionary *)dict;

- (SBVariant *)getVariantWithMatrixKey1:(NSString *)key1 andMatrixKey2:(NSString *)key2;
- (SBVariant *)getVariantWithMatrixKey1:(NSString *)key1 andMatrixKey2:(NSString *)key2 andMatrixKey3:(NSString *)key3;

- (NSArray *)getMatrixItemsFor2ndDimension;

- (NSArray *)getMatrixKey1Values;
- (NSArray *)getMatrixKey2Values;
- (NSArray *)getMatrixKey3Values;

- (NSDate *)earliestDeliveryDateWithMatrix2Value:(NSString *)value;
- (NSDate *)latestDeliveryDateWithMatrix2Value:(NSString *)value;

- (SBVariant *)getDefaultVariant;

- (NSArray *)baseColorImages;

- (UIImage *)getSignalLightImage;

- (UIImage *)renderBaseColorImagesWithMaximumWidthOf:(NSUInteger)totalWidth;

@end