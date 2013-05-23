//
//  NSNumber+CurrencyRound.m
//  SalesBook
//
//  Created by Andreas Kucher on 14.12.12.
//  Copyright (c) 2012 Siller AG. All rights reserved.
//

#import "NSNumber+CurrencyRound.h"

@implementation NSNumber (CurrencyRound)

- (NSNumber *)currencyRound
{
	NSNumberFormatter *formatter = [NSNumberFormatter new];
	[formatter setMaximumFractionDigits:2];
	[formatter setRoundingMode: NSNumberFormatterRoundHalfUp];
    
	return [NSNumber numberWithFloat:[[formatter stringFromNumber:[NSNumber numberWithFloat:[self floatValue]]] floatValue]];
}

- (NSString *)stringWithCurrencyCode:(NSString *)iso4217Code
                          withLocale:(NSString *)iso3166Code
{
    NSLocale *locale;
    
    if ([iso3166Code isValidISO3166])
    {
        locale = [[NSLocale alloc] initWithLocaleIdentifier:iso3166Code];
    }
    else
    {
        locale = [NSLocale currentLocale];
    }
    
    if (!iso4217Code)
    {
        iso4217Code = @"EUR";
    }
    
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setLocale:locale];
    [formatter setCurrencyCode:iso4217Code];
    
    return [formatter stringFromNumber:self];
}

- (NSString *)getHumanReadableFileSize;
{
    double convertedValue = [self doubleValue];
    int multiplyFactor = 0;
    
    NSArray *tokens = [NSArray arrayWithObjects:@"B",@"KB",@"MB",@"GB",@"TB",nil];
    
    while (convertedValue > 1024) {
        convertedValue /= 1024;
        multiplyFactor++;
    }
    
    return [NSString stringWithFormat:@"%4.2f %@", convertedValue, [tokens objectAtIndex:multiplyFactor]];
}

- (NSString *)stringWithLocalizedNumberStyle {
    
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    return [formatter stringFromNumber:self];
}

@end
