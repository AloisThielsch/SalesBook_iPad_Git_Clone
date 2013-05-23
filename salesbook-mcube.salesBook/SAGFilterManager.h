//
//  SAGFilterManager.h
//  SalesBook
//
//  Created by Frank Wittmann on 07.05.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SBFilter+Extensions.h"

#define notificationFilterChanged @"SAGFilterManagerFilterChanged"
#define notificationFilterAdded @"SAGFilterManagerFilterAdded"
#define notificationFilterEdited @"SAGFilterManagerFilterEdited"

@protocol FilterManagerDelegate<NSObject>
- (void)didSelectFilter:(SBFilter *)filter forEntityName:(NSString *)entityName;
@end

@interface SAGFilterManager : NSObject

@property (nonatomic) id<FilterManagerDelegate> delegate;

+ (SAGFilterManager *)sharedManager;

#pragma mark - filter management

- (BOOL)hasFilterForEntity:(NSString *)entityName;
- (SBFilter *)filterForEntity:(NSString *)entityName;
- (void)setFilter:(SBFilter *)filter forEntity:(NSString *)entityName;

- (void)activateFilterForEntity:(NSString *)entityName;
- (BOOL)isActiveFilter:(SBFilter *)filter forEntity:(NSString *)entityName;

#pragma mark - filter selection popover

- (void)toggleFilterPopoverForEntityName:(NSString *)entityName
					   fromBarButtonItem:(UIBarButtonItem *)item;
@end
