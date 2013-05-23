//
//  SAGFilterBuilder.h
//  SalesBook
//
//  Created by Frank Wittmann on 13.05.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SBFilter+Extensions.h"

@interface SAGFilterBuilder : NSObject

@property (nonatomic, strong) SBFilter *filter;

+ (SAGFilterBuilder *)filterBuilderWithEntityClass:(Class)entityClass;
- (id)initWithEntityClass:(Class)entityClass;

- (void)addPredicate:(NSPredicate *)predicate;

- (NSArray *)query;

@end
