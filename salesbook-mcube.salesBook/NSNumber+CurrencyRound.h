//
//  NSNumber+CurrencyRound.h
//  SalesBook
//
//  Created by Andreas Kucher on 14.12.12.
//  Copyright (c) 2012 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (CurrencyRound)

- (NSNumber *)currencyRound;

- (NSString *)stringWithCurrencyCode:(NSString *)iso4217Code
                          withLocale:(NSString *)iso3166Code;

- (NSString *)getHumanReadableFileSize;

- (NSString *)stringWithLocalizedNumberStyle;

@end
