//
//  NSString+Extensions.h
//  SalesBook
//
//  Created by Andreas Kucher on 14.12.12.
//  Copyright (c) 2012 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extensions)

- (NSString *)upperBoundSearchString;
- (NSString *)normalizedString;

+ (NSString *)generateUniqueID;

- (BOOL)isValidURL;
- (BOOL)isValidEmail;
- (BOOL)isValidISO3166;

- (BOOL)isValidUsingRegEx:(NSString *)regEx;

- (NSDate *)fromISO8601FormatedString;

+ (NSString *)stringAsTimeSinceDate:(NSDate *)date;
+ (NSString *)stringAsDetailedTimeSinceDate:(NSDate *)date;
+ (NSString *)base64StringFromData:(NSData *)data length:(int)length;

- (NSDate *)fromShortDate;

@end
