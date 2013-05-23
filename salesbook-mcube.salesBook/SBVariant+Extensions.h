//
//  SBVariant+Extensions.h
//  SalesBook
//
//  Created by Andreas Kucher on 18.01.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBVariant.h"

@class SBCustomer;

@interface SBVariant (Extensions)

+ (SBVariant *)createNewVariant;

+ (SBVariant *)getVariantWithUniqueID:(NSString *)uniqueID;
+ (SBVariant *)getVariantWithVariantNumber:(NSString *)variantNumber;

+ (NSString *)localizedClassName;

+ (void)renewReferences;

+ (NSString *)webserviceUpdate;
+ (NSString *)webserviceDelete;
+ (NSString *)webserviceUniqueID;
+ (NSString *)webserviceActionState;
+ (NSString *)webserviceTransferDate;
+ (NSString *)webserviceBlockSize;
+ (NSString *)webserviceDataBlock;

+ (BOOL)updateDocumentFromDictionary:(NSDictionary *)dict;

- (NSString *)matrixValueFor1stDimension;
- (NSString *)matrixValueFor2ndDimension;
- (NSString *)matrixValueFor3rdDimension;

- (UIImage *)defaultImageWithImageMediaType:(enum SAGMediaType)mediaType;
- (NSArray *)getDownloadedMediaFilesWithImageMediaType:(enum SAGMediaType)mediaType;

- (SBPrice *)getPriceForCustomerOrNil:(SBCustomer *)customer;
- (NSString *)getPriceAsStringForCustomerOrNil:(SBCustomer *)customer;
- (NSString *)getPrice2AsStringForCustomerOrNil:(SBCustomer *)customer;
- (NSString *)getRecommendedPriceAsStringForCustomerOrNil:(SBCustomer *)customer;

- (UIImage *)baseColorImage;

- (NSString *)assortment;
- (NSString *)season;

- (SBStock *)getStock;

- (UIImage *)getSignalLightImage;

- (NSString *)recommendedPrice;
- (NSString *)price;
- (NSString *)price2;


- (NSString *)wmFruehesterLiefertermin;
- (NSString *)wmSpaetesterLiefertermin;

@end