//
//  CustomFieldData.h
//  SalesBook
//
//  Created by Frank Wittmann on 16.05.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomFieldData : NSObject

@property (nonatomic) NSInteger fieldType;
@property (nonatomic, getter = isMandatory) BOOL mandatory;
@property (nonatomic, getter = isMultiSelect) BOOL multiSelect;
@property (nonatomic, strong) NSString *label;
@property (nonatomic, strong) NSString *regularExpression;
@property (nonatomic, strong) NSString *uniqueID;
@property (nonatomic, strong) id value;
@property (nonatomic, getter = isValid) BOOL valid;

+ (CustomFieldData *)customFieldDataWithDictionary:(NSDictionary *)dictionary;
- (id)initWithDictionary:(NSDictionary *)dictionary;

- (BOOL)validateWithCurrentValue;
- (BOOL)validateWithValue:(NSString *)value;

- (NSString *)displayValue;

@end
