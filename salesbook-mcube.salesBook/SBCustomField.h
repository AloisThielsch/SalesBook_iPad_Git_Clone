//
//  SBCustomField.h
//  SalesBook
//
//  Created by Andreas Kucher on 22.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SBAttribute, SBSelectionOption;

@interface SBCustomField : NSManagedObject

@property (nonatomic, retain) NSNumber * actionState;
@property (nonatomic, retain) NSDate * alternationDate;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSNumber * customFieldType;
@property (nonatomic, retain) NSNumber * documentState;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * interfaceTableColumnType;
@property (nonatomic, retain) NSNumber * isEditable;
@property (nonatomic, retain) NSNumber * isFilterable;
@property (nonatomic, retain) NSNumber * isMandatory;
@property (nonatomic, retain) NSNumber * isMultiLanguage;
@property (nonatomic, retain) NSNumber * isMultiRow;
@property (nonatomic, retain) NSNumber * isSearchable;
@property (nonatomic, retain) NSNumber * isVisibleInDetails;
@property (nonatomic, retain) NSNumber * isVisibleInList;
@property (nonatomic, retain) NSString * layoutGroup;
@property (nonatomic, retain) NSString * regExRule;
@property (nonatomic, retain) NSNumber * sortOrder;
@property (nonatomic, retain) NSString * targetEntity;
@property (nonatomic, retain) NSString * targetField;
@property (nonatomic, retain) NSString * textFromEntity;
@property (nonatomic, retain) NSString * textFromKey;
@property (nonatomic, retain) NSDate * transferDate;
@property (nonatomic, retain) NSNumber * transferState;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSSet *attributes;
@property (nonatomic, retain) NSSet *seletionOptions;
@end

@interface SBCustomField (CoreDataGeneratedAccessors)

- (void)addAttributesObject:(SBAttribute *)value;
- (void)removeAttributesObject:(SBAttribute *)value;
- (void)addAttributes:(NSSet *)values;
- (void)removeAttributes:(NSSet *)values;

- (void)addSeletionOptionsObject:(SBSelectionOption *)value;
- (void)removeSeletionOptionsObject:(SBSelectionOption *)value;
- (void)addSeletionOptions:(NSSet *)values;
- (void)removeSeletionOptions:(NSSet *)values;

@end
