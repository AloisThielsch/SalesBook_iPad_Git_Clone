//
//  SAGFilterBuilder.m
//  SalesBook
//
//  Created by Frank Wittmann on 13.05.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SAGFilterBuilder.h"

#import "NSManagedObject+MagicalFinders.h"

@interface SAGFilterBuilder()
@property (nonatomic) Class entityClass;
@property (nonatomic, strong) NSMutableArray *predicates;
@end

@implementation SAGFilterBuilder

+ (SAGFilterBuilder *)filterBuilderWithEntityClass:(Class)entityClass
{
	SAGFilterBuilder *builder = [[SAGFilterBuilder alloc] initWithEntityClass:entityClass];
	return builder;
}

- (id)initWithEntityClass:(Class)entityClass
{
	self = [super init];
	if (self) {
		self.entityClass = entityClass;
		self.predicates = [NSMutableArray array];
	}
	return self;
}

- (void)addPredicate:(NSPredicate *)predicate
{
	[self.predicates addObject:predicate];
}

- (NSArray *)query
{
	NSArray *result;
	NSArray *metaResult = [self preFilterQuery];
	
	if (self.filter) {
		[self.filter setObjectsToFilter:[NSSet setWithArray:metaResult]];
		NSArray *filterResult = [self.filter getResult];
		NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"self in %@", filterResult];
		result = [self findWithPredicates:@[ filterPredicate ]];
	} else {
		result = metaResult;
	}
	
	return result;
}

#pragma mark - internal API

- (NSArray *)preFilterQuery
{
	return [self findWithPredicates:self.predicates];
}

- (NSArray *)findWithPredicates:(NSArray *)predicateArray
{
	return [[((NSManagedObject *)self.entityClass) class] MR_findAllWithPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:predicateArray]];
}


@end
