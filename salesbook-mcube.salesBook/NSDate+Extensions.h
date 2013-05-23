//
//  NSDate+Extensions.h
//  SalesBook
//
//  Created by Andreas Kucher on 14.12.12.
//  Copyright (c) 2012 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Extensions)

- (NSDate *)midnight;

- (NSDate *)yesterday;
- (NSDate *)today;
- (NSDate *)tomorrow;

- (int)day;
- (int)month;
- (int)year;

- (int)halfOfMonth;

- (NSString *)asISO8601FormattedString;
- (NSString *)asWortmannFormattedString;
- (NSString *)asLocalizedString;
- (NSString *)asCustomFieldDate;

+ (NSDate *)minimumUnixDate;

+ (NSString *)nowAsLocalizedString;

@end
