//
//  NSNumber+PercentValue.m
//  SalesBook
//
//  Created by Andreas Kucher on 14.12.12.
//  Copyright (c) 2012 Siller AG. All rights reserved.
//

#import "NSNumber+PercentValue.h"

@implementation NSNumber (PercentValue)

- (NSString *)percentValue
{
    if ([self floatValue] == 0.0f)
    {
        return @"";
    }
    
    NSNumberFormatter *currencyFormatter = [NSNumberFormatter new];
    [currencyFormatter setNumberStyle:NSNumberFormatterPercentStyle];
	[currencyFormatter setPositiveFormat:@"0.00%;0.00%;-0.00%"];
    
    return [currencyFormatter stringFromNumber:[NSNumber numberWithFloat:[self floatValue] / 100]];
}


@end
