//
//  NSPredicate+Search.m
//  SalesBook
//
//  Created by Andreas Kucher on 04.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "NSPredicate+Search.h"
#import "NSString+Extensions.h"

@implementation NSPredicate (Search)

+ (NSPredicate *)prediacteForNormalizedValue:(NSString *)searchString andKey:(NSString *)key
{
    if (!searchString) return nil;
    
    NSString *lowBound = nil;
    NSString *highBound = nil;
    
    lowBound = [searchString normalizedString];
    highBound = [lowBound upperBoundSearchString];
    
    return [NSPredicate predicateWithFormat:@"%K >= %@ and %K < %@", key, lowBound, key, highBound];
}

@end
