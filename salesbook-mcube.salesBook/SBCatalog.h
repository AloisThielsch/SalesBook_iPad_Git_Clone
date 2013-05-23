//
//  SBCatalog.h
//  SalesBook
//
//  Created by Andreas Kucher on 22.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SBAttribute, SBItem, SBItemGroup;

@interface SBCatalog : NSManagedObject

@property (nonatomic, retain) NSNumber * activeState;
@property (nonatomic, retain) NSDate * alternationDate;
@property (nonatomic, retain) NSString * catalogNumber;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSNumber * documentState;
@property (nonatomic, retain) NSDate * transferDate;
@property (nonatomic, retain) NSNumber * transferState;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSSet *attributes;
@property (nonatomic, retain) NSSet *itemGroups;
@property (nonatomic, retain) NSSet *items;
@end

@interface SBCatalog (CoreDataGeneratedAccessors)

- (void)addAttributesObject:(SBAttribute *)value;
- (void)removeAttributesObject:(SBAttribute *)value;
- (void)addAttributes:(NSSet *)values;
- (void)removeAttributes:(NSSet *)values;

- (void)addItemGroupsObject:(SBItemGroup *)value;
- (void)removeItemGroupsObject:(SBItemGroup *)value;
- (void)addItemGroups:(NSSet *)values;
- (void)removeItemGroups:(NSSet *)values;

- (void)addItemsObject:(SBItem *)value;
- (void)removeItemsObject:(SBItem *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

@end
