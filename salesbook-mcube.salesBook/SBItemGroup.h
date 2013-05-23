//
//  SBItemGroup.h
//  SalesBook
//
//  Created by Andreas Kucher on 22.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SBAttribute, SBCatalog, SBItem, SBItemGroup;

@interface SBItemGroup : NSManagedObject

@property (nonatomic, retain) NSNumber * activeState;
@property (nonatomic, retain) NSDate * alternationDate;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSNumber * documentState;
@property (nonatomic, retain) NSString * itemGroupNumber;
@property (nonatomic, retain) NSNumber * level;
@property (nonatomic, retain) NSString * parentGroup;
@property (nonatomic, retain) NSDate * transferDate;
@property (nonatomic, retain) NSNumber * transferState;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSSet *attributes;
@property (nonatomic, retain) NSSet *catalogs;
@property (nonatomic, retain) NSSet *items;
@property (nonatomic, retain) NSSet *subGroups;
@property (nonatomic, retain) SBItemGroup *topGroup;
@end

@interface SBItemGroup (CoreDataGeneratedAccessors)

- (void)addAttributesObject:(SBAttribute *)value;
- (void)removeAttributesObject:(SBAttribute *)value;
- (void)addAttributes:(NSSet *)values;
- (void)removeAttributes:(NSSet *)values;

- (void)addCatalogsObject:(SBCatalog *)value;
- (void)removeCatalogsObject:(SBCatalog *)value;
- (void)addCatalogs:(NSSet *)values;
- (void)removeCatalogs:(NSSet *)values;

- (void)addItemsObject:(SBItem *)value;
- (void)removeItemsObject:(SBItem *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

- (void)addSubGroupsObject:(SBItemGroup *)value;
- (void)removeSubGroupsObject:(SBItemGroup *)value;
- (void)addSubGroups:(NSSet *)values;
- (void)removeSubGroups:(NSSet *)values;

@end
