//
//  SAGObjectSelectionManager.m
//  SalesBook
//
//  Created by Frank Wittmann on 17.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SAGObjectSelectionManager.h"

@interface SAGObjectSelectionManager()
@property (nonatomic, strong) NSMutableDictionary *entitySubscriptions;
@end

@implementation SAGObjectSelectionManager

+ (SAGObjectSelectionManager *)sharedManager
{
    static SAGObjectSelectionManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[SAGObjectSelectionManager alloc] init];
    });
    
    return _sharedManager;
}

- (id)init
{
	self = [super init];
	if (self) {
		_entitySubscriptions = [NSMutableDictionary dictionary];
	}
	return self;
}

- (void)addSubscriber:(id<ObjectSelectionManagerProtocol>)subscriber forEntity:(NSString *)entityName
{
	NSString *foldedEntityName = [self foldedEntityName:entityName];
	NSMutableArray *subscribers = _entitySubscriptions[foldedEntityName];
	if (subscribers) {
		if (![subscribers containsObject:subscriber]) {
			[subscribers addObject:subscriber];
		}
	} else {
		NSMutableArray *newEntityArray = [NSMutableArray array];
		[newEntityArray addObject:subscriber];
		_entitySubscriptions[foldedEntityName] = newEntityArray;
	}
}

- (void)removeSubscriber:(id<ObjectSelectionManagerProtocol>)subscriber forEntity:(NSString *)entityName
{
	NSString *foldedEntityName = [self foldedEntityName:entityName];
	NSMutableArray *subscribers = _entitySubscriptions[foldedEntityName];
	if (subscribers) {
		if ([subscribers containsObject:subscriber]) {
			[subscribers removeObject:subscriber];
		}
	}
}

- (void)broadcastSelectionOfEntity:(NSString *)entityName withObjectID:(NSManagedObjectID *)objectID
{
	NSString *foldedEntityName = [self foldedEntityName:entityName];
	NSMutableArray *subscribers = _entitySubscriptions[foldedEntityName];
	for (id<ObjectSelectionManagerProtocol> subscriber in subscribers) {
		if (subscriber &&
			[subscriber conformsToProtocol:@protocol(ObjectSelectionManagerProtocol)] &&
			[subscriber respondsToSelector:@selector(didSelectEntity:withObjectID:)]) {
			[subscriber didSelectEntity:entityName withObjectID:objectID];
		}
	}
}

- (void)broadcastDeselectionOfEntity:(NSString *)entityName
{
	NSString *foldedEntityName = [self foldedEntityName:entityName];
	NSMutableArray *subscribers = _entitySubscriptions[foldedEntityName];
	for (id<ObjectSelectionManagerProtocol> subscriber in subscribers) {
		if (subscriber &&
			[subscriber conformsToProtocol:@protocol(ObjectSelectionManagerProtocol)] &&
			[subscriber respondsToSelector:@selector(didDeselectEntity:)]) {
			[subscriber didDeselectEntity:entityName];
		}
	}
}

#pragma mark - Private API

- (NSString *)foldedEntityName:(NSString *)entityName
{
	return [[entityName stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]] lowercaseStringWithLocale:[NSLocale currentLocale]];
}

@end
