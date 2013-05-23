//
//  SBSizeIndex.h
//  SalesBook
//
//  Created by Andreas Kucher on 17.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SBAssortment;

@interface SBSizeIndex : NSManagedObject

@property (nonatomic, retain) NSString * size;
@property (nonatomic, retain) NSNumber * sortOrder;
@property (nonatomic, retain) NSString * quantity;
@property (nonatomic, retain) SBAssortment *assortment;

@end
