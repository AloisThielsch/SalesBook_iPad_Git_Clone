//
//  SBKeyValueStore.h
//  SalesBook
//
//  Created by Andreas Kucher on 22.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SBKeyValueStore : NSManagedObject

@property (nonatomic, retain) NSString * theKey;
@property (nonatomic, retain) id theValue;

@end
