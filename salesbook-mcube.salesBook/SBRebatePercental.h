//
//  SBRebatePercental.h
//  SalesBook
//
//  Created by Andreas Kucher on 22.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SBRebate.h"


@interface SBRebatePercental : SBRebate

@property (nonatomic, retain) NSNumber * percentage;

@end
