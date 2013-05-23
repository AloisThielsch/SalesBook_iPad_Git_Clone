//
//  SBSelectionOption.h
//  SalesBook
//
//  Created by Andreas Kucher on 22.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SBAttribute, SBCustomField;

@interface SBSelectionOption : NSManagedObject

@property (nonatomic, retain) NSNumber * isDefault;
@property (nonatomic, retain) NSNumber * isVisible;
@property (nonatomic, retain) NSString * optionCode;
@property (nonatomic, retain) NSNumber * sortOrder;
@property (nonatomic, retain) NSSet *attributes;
@property (nonatomic, retain) SBCustomField *customField;
@end

@interface SBSelectionOption (CoreDataGeneratedAccessors)

- (void)addAttributesObject:(SBAttribute *)value;
- (void)removeAttributesObject:(SBAttribute *)value;
- (void)addAttributes:(NSSet *)values;
- (void)removeAttributes:(NSSet *)values;

@end
