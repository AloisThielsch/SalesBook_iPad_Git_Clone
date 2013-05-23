//
//  SBDocumentPosition.h
//  SalesBook
//
//  Created by Julian Knab on 07.05.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SBAttribute, SBDocument, SBRebate, SBVariant;

@interface SBDocumentPosition : NSManagedObject

@property (nonatomic, retain) NSDate * adjustedDeliveryDate;
@property (nonatomic, retain) NSNumber * amount;
@property (nonatomic, retain) NSDate * calculatedDeliveryDate;
@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSSet *attributes;
@property (nonatomic, retain) SBDocument *document;
@property (nonatomic, retain) SBRebate *rebate;
@property (nonatomic, retain) SBVariant *referencedVariant;
@end

@interface SBDocumentPosition (CoreDataGeneratedAccessors)

- (void)addAttributesObject:(SBAttribute *)value;
- (void)removeAttributesObject:(SBAttribute *)value;
- (void)addAttributes:(NSSet *)values;
- (void)removeAttributes:(NSSet *)values;

@end
