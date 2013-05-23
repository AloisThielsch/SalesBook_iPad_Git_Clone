//
//  NSManagedObject+CustomFields.h
//  SalesBook
//
//  Created by Andreas Kucher on 14.12.12.
//  Copyright (c) 2012 Siller AG. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (CustomFields)

- (void)setAttribute:(id)value withKey:(NSString *)key andLanguage:(NSString *)language;

- (id)valueForAttribute:(NSString *)key andLanguage:(NSString *)language;

- (NSString *)stringValueForAttribute:(NSString *)key andLanguage:(NSString *)language;

- (void)setAttributesfromDictionary:(NSDictionary *)attributes;
- (void)deleteAttributesWithLanguage:(NSString *)language;

- (bool)setDefaultValues;

- (NSArray *)getVisibleData;
- (NSArray *)getVisibleDataList;
- (NSArray *)getVisibleDataDetail;

- (NSArray *)getEditableData;

- (bool)hasAttributes;
- (bool)entityContainsKey:(NSString *)key;

- (NSString *)findInverseRelationshipWithEntity:(NSString *)entity;
- (bool)hasToManyRelationshipWithEntity:(NSString *)entity;

- (NSData *)getXMLforDelete:(bool)deleteXML;

- (void)saveToMCube;
- (void)saveForBatchTransfer;
- (void)prepareForDelete;

@end
