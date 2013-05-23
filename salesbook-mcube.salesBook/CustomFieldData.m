//
//  CustomFieldData.m
//  SalesBook
//
//  Created by Frank Wittmann on 16.05.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "CustomFieldData.h"

#import "SBCustomField+Extensions.h"

@interface CustomFieldData()
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end

@implementation CustomFieldData

+ (CustomFieldData *)customFieldDataWithDictionary:(NSDictionary *)dictionary
{
	return [[CustomFieldData alloc] initWithDictionary:dictionary];
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if (self) {
		self.fieldType = [dictionary[@"SAGCustomFieldType"] integerValue];
		self.mandatory = [dictionary[@"isMandatory"] boolValue];
		self.multiSelect = [dictionary[@"isMultiSelect"] boolValue];
		self.label = dictionary[@"label"];
		self.regularExpression = dictionary[@"regExRule"];
		self.uniqueID = dictionary[@"uniqueID"];
		self.value = dictionary[@"value"];
		
		if ([self.regularExpression isEqualToString:@""]) {
			self.regularExpression = nil;
		}
		
		self.valid = YES;
	}
	return self;
}

- (id)value
{
	if (!_value) {
		if (_fieldType == SAGCustomFieldTypeSelect) {
			SBCustomField *customField = [SBCustomField getCustomFieldWithUniqueID:_uniqueID];
			NSMutableArray *optionArray = [NSMutableArray array];
			for (SBSelectionOption *option in [customField visibleSelectionOptions]) {
				[optionArray addObject:@{ @"value":option.optionCode, @"label":[option denotationWithLanguage:[[SAGSettingsManager sharedManager] itemDisplayLanguage]] }];
				_value = optionArray;
			}
		}
	}
	return _value;
}

- (BOOL)isValid
{
	_valid = [self validateWithCurrentValue];
	return _valid;
}

- (BOOL)validateWithCurrentValue
{
	NSString *value;
	if ([self.value respondsToSelector:@selector(stringValue)]) {
		value = [self.value stringValue];
	} else {
		value = [self.value description];
	}
	return [self validateWithValue:value];
}

- (BOOL)validateWithValue:(NSString *)value
{
	if (self.mandatory) {
		if (!value || [value isEqualToString:@""]) {
			return NO;
		}
	}
	
	if (value) {
		if (self.regularExpression) {
			NSRegularExpression *expression = [[NSRegularExpression alloc] initWithPattern:self.regularExpression
																				   options:NSRegularExpressionCaseInsensitive
																					 error:nil];
			if (0 == [expression numberOfMatchesInString:value
												 options:0
												   range:NSMakeRange(0, [value length])]) {
				return NO;
			}
		}
	}
	
	return YES;
}

- (NSString *)displayValue
{
	if (_fieldType == SAGCustomFieldTypeText) {
		return self.value;
	} else if (_fieldType == SAGCustomFieldTypeDate) {
		return [self.dateFormatter stringFromDate:self.value];
	} else {
		return @"";
	}
}

- (NSDateFormatter *)dateFormatter
{
	static dispatch_once_t onceToken;
	static NSDateFormatter *_formatter = nil;
	dispatch_once(&onceToken, ^{
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateStyle:NSDateFormatterLongStyle];
        [_formatter setTimeStyle:NSDateFormatterNoStyle];
		_dateFormatter = _formatter;
	});
	
	return _dateFormatter;
}

@end
