//
//  SBFilter.h
//  SalesBook
//
//  Created by Andreas Kucher on 09.05.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SBFilterLevel;

@interface SBFilter : NSManagedObject

@property (nonatomic, retain) NSNumber * active;
@property (nonatomic, retain) NSData * cache;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * targetEntity;
@property (nonatomic, retain) NSNumber * activeState;
@property (nonatomic, retain) NSDate * alternationDate;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSNumber * documentState;
@property (nonatomic, retain) NSDate * transferDate;
@property (nonatomic, retain) NSNumber * transferState;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSOrderedSet *levels;
@end

@interface SBFilter (CoreDataGeneratedAccessors)

- (void)insertObject:(SBFilterLevel *)value inLevelsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromLevelsAtIndex:(NSUInteger)idx;
- (void)insertLevels:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeLevelsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInLevelsAtIndex:(NSUInteger)idx withObject:(SBFilterLevel *)value;
- (void)replaceLevelsAtIndexes:(NSIndexSet *)indexes withLevels:(NSArray *)values;
- (void)addLevelsObject:(SBFilterLevel *)value;
- (void)removeLevelsObject:(SBFilterLevel *)value;
- (void)addLevels:(NSOrderedSet *)values;
- (void)removeLevels:(NSOrderedSet *)values;
@end
