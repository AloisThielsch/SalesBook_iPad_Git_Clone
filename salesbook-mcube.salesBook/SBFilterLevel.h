//
//  SBFilterLevel.h
//  SalesBook
//
//  Created by Andreas Kucher on 09.05.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SBFilter;

@interface SBFilterLevel : NSManagedObject

@property (nonatomic, retain) NSData * cache;
@property (nonatomic, retain) NSNumber * level;
@property (nonatomic, retain) NSString * relationshipKey;
@property (nonatomic, retain) NSString * targetEntity;
@property (nonatomic, retain) NSString * theKey;
@property (nonatomic, retain) id theValue;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) SBFilter *filter;

@end
