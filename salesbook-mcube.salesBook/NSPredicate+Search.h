//
//  NSPredicate+Search.h
//  SalesBook
//
//  Created by Andreas Kucher on 04.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSPredicate (Search)

+ (NSPredicate *)prediacteForNormalizedValue:(NSString *)searchString andKey:(NSString *)key;

@end
