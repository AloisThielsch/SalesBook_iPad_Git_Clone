//
//  SBCustomField+Extensions.h
//  SalesBook
//
//  Created by Andreas Kucher on 28.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBCustomField.h"
#import "SBSelectionOption+Extensions.h"

@interface SBCustomField (Extensions)

+ (SBCustomField *)createNewCustomField;

+ (SBCustomField *)getCustomFieldWithUniqueID:(NSString *)uniqueID;

+ (SBCustomField *)getCustomFieldWithTargetEntity:(NSString *)targetEntity andKey:(NSString *)key;

+ (NSString *)localizedClassName;

+ (NSString *)webserviceUpdate;
+ (NSString *)webserviceDelete;
+ (NSString *)webserviceUniqueID;
+ (NSString *)webserviceActionState;
+ (NSString *)webserviceTransferDate;
+ (NSString *)webserviceBlockSize;
+ (NSString *)webserviceDataBlock;

+ (BOOL)shouldRemoveDataBeforeImport;

+ (BOOL)updateDocumentFromDictionary:(NSDictionary *)dict;

+ (BOOL)setDefaultValuesWithObject:(NSManagedObject *)targetObject;

+ (NSArray *)getVisibleDataWithObject:(NSManagedObject *)targetObject withCustomFieldDetailLevel:(enum SAGCustomFieldDetailLevel)level limitResultsTo:(NSUInteger)maxNumberOfResults;
+ (NSArray *)getEditableDataWithObject:(NSManagedObject *)targetObject;

- (NSString *)getTextFromEntityWithTargetObject:(NSManagedObject *)targetObject withLanguage:(NSString *)language;
- (NSString *)getValueForKey:(NSString *)key withObject:(NSManagedObject *)object andLanguage:(NSString *)language;

- (void)setValue:(id)value withObject:(NSManagedObject *)object andLangauge:(NSString *)language;

- (SBSelectionOption *)defaultOption;
- (SBSelectionOption *)selectionOptionWithOptionCode:(NSString *)optionCode;
- (bool)isValidOptionCode:(NSString *)optionCode;

- (NSArray *)visibleSelectionOptions;

+ (NSArray *)getFilterableKeysForEntity:(NSString *)entityName;
+ (NSArray *)getSearchableKeysForEntity:(NSString *)entityName;

+ (NSString *)stringValueWithObject:(id)obj;

- (NSString *)label;

@end
