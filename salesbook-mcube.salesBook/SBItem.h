//
//  SBItem.h
//  SalesBook
//
//  Created by Andreas Kucher on 22.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SBAttribute, SBCatalog, SBItemGroup, SBVariant;

@interface SBItem : NSManagedObject

@property (nonatomic, retain) NSNumber * activeState;
@property (nonatomic, retain) NSDate * alternationDate;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSString * dimensionKeyForDisplayUse;
@property (nonatomic, retain) NSNumber * documentState;
@property (nonatomic, retain) NSString * itemGroupNumber;
@property (nonatomic, retain) NSNumber * itemKind;
@property (nonatomic, retain) NSString * itemNumber;
@property (nonatomic, retain) NSNumber * itemType;
@property (nonatomic, retain) NSString * matrixKeyFor1stDimension;
@property (nonatomic, retain) NSString * matrixKeyFor2ndDimension;
@property (nonatomic, retain) NSString * matrixKeyFor3rdDimension;
@property (nonatomic, retain) NSDate * transferDate;
@property (nonatomic, retain) NSNumber * transferState;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSSet *attributes;
@property (nonatomic, retain) NSSet *catalogs;
@property (nonatomic, retain) SBItemGroup *itemGroup;
@property (nonatomic, retain) NSSet *variants;
@end

@interface SBItem (CoreDataGeneratedAccessors)

- (void)addAttributesObject:(SBAttribute *)value;
- (void)removeAttributesObject:(SBAttribute *)value;
- (void)addAttributes:(NSSet *)values;
- (void)removeAttributes:(NSSet *)values;

- (void)addCatalogsObject:(SBCatalog *)value;
- (void)removeCatalogsObject:(SBCatalog *)value;
- (void)addCatalogs:(NSSet *)values;
- (void)removeCatalogs:(NSSet *)values;

- (void)addVariantsObject:(SBVariant *)value;
- (void)removeVariantsObject:(SBVariant *)value;
- (void)addVariants:(NSSet *)values;
- (void)removeVariants:(NSSet *)values;

@end
