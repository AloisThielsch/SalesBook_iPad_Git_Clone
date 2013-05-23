//
//  SBVariant.h
//  SalesBook
//
//  Created by Andreas Kucher on 22.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SBAttribute, SBDocumentPosition, SBItem, SBMedia, SBPrice, SBStock;

@interface SBVariant : NSManagedObject

@property (nonatomic, retain) NSNumber * activeState;
@property (nonatomic, retain) NSString * aggregationDescriptor;
@property (nonatomic, retain) NSDate * alternationDate;
@property (nonatomic, retain) NSString * baseColorNumber;
@property (nonatomic, retain) NSNumber * baseQuantity;
@property (nonatomic, retain) NSString * colorNumber;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSNumber * displayPriority;
@property (nonatomic, retain) NSNumber * documentState;
@property (nonatomic, retain) NSDate * earliestDeliveryDate;
@property (nonatomic, retain) NSString * genericItem;
@property (nonatomic, retain) NSString * gtin1;
@property (nonatomic, retain) NSString * gtin2;
@property (nonatomic, retain) NSString * itemDiscountGroup;
@property (nonatomic, retain) NSDate * latestDeliveryDate;
@property (nonatomic, retain) NSNumber * matrixSortOrderFor1stDimension;
@property (nonatomic, retain) NSNumber * matrixSortOrderFor2ndDimension;
@property (nonatomic, retain) NSNumber * matrixSortOrderFor3rdDimension;
@property (nonatomic, retain) NSNumber * packQuantity;
@property (nonatomic, retain) NSNumber * priceQuantity;
@property (nonatomic, retain) NSString * priceUnitCode;
@property (nonatomic, retain) NSNumber * procurementTime;
@property (nonatomic, retain) NSString * replacementVariant;
@property (nonatomic, retain) NSString * salesUnitCode;
@property (nonatomic, retain) NSDate * transferDate;
@property (nonatomic, retain) NSNumber * transferState;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSString * variantNumber;
@property (nonatomic, retain) NSNumber * weight;
@property (nonatomic, retain) NSSet *attributes;
@property (nonatomic, retain) NSSet *documentPositions;
@property (nonatomic, retain) NSSet *mediaFiles;
@property (nonatomic, retain) SBItem *owningItem;
@property (nonatomic, retain) NSSet *prices;
@property (nonatomic, retain) NSSet *stocks;
@end

@interface SBVariant (CoreDataGeneratedAccessors)

- (void)addAttributesObject:(SBAttribute *)value;
- (void)removeAttributesObject:(SBAttribute *)value;
- (void)addAttributes:(NSSet *)values;
- (void)removeAttributes:(NSSet *)values;

- (void)addDocumentPositionsObject:(SBDocumentPosition *)value;
- (void)removeDocumentPositionsObject:(SBDocumentPosition *)value;
- (void)addDocumentPositions:(NSSet *)values;
- (void)removeDocumentPositions:(NSSet *)values;

- (void)addMediaFilesObject:(SBMedia *)value;
- (void)removeMediaFilesObject:(SBMedia *)value;
- (void)addMediaFiles:(NSSet *)values;
- (void)removeMediaFiles:(NSSet *)values;

- (void)addPricesObject:(SBPrice *)value;
- (void)removePricesObject:(SBPrice *)value;
- (void)addPrices:(NSSet *)values;
- (void)removePrices:(NSSet *)values;

- (void)addStocksObject:(SBStock *)value;
- (void)removeStocksObject:(SBStock *)value;
- (void)addStocks:(NSSet *)values;
- (void)removeStocks:(NSSet *)values;

@end
