//
//  SAGObjectSelectionManager.h
//  SalesBook
//
//  Created by Frank Wittmann on 17.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ObjectSelectionManagerProtocol<NSObject>
@optional
- (void)didSelectEntity:(NSString *)entityName withObjectID:(NSManagedObjectID *)objectID;
- (void)didDeselectEntity:(NSString *)entityName;
@end

@interface SAGObjectSelectionManager : NSObject

+ (SAGObjectSelectionManager *)sharedManager;

- (void)addSubscriber:(id<ObjectSelectionManagerProtocol>)subscriber forEntity:(NSString *)entityName;
- (void)removeSubscriber:(id<ObjectSelectionManagerProtocol>)subscriber forEntity:(NSString *)entityName;

- (void)broadcastSelectionOfEntity:(NSString *)entityName withObjectID:(NSManagedObjectID *)objectID;
- (void)broadcastDeselectionOfEntity:(NSString *)entityName;

@end
