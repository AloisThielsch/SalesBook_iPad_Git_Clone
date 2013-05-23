//
//  SBFilterLevel+Extensions.m
//  SalesBook
//
//  Created by Andreas Kucher on 09.05.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBFilterLevel+Extensions.h"

@implementation SBFilterLevel (Extensions)

- (NSArray *)theValues
{
    NSMutableArray *theValues = [NSMutableArray new];
    
    for (NSDictionary *dict in self.theValue)
    {
        [theValues addObject:[dict valueForKey:@"value"]];
    }
 
    return theValues;
}

- (NSArray *)theLabels
{
    NSMutableArray *theLabels = [NSMutableArray new];
    
    for (NSDictionary *dict in self.theValue)
    {
        [theLabels addObject:[dict valueForKey:@"label"]];
    }
    
    return theLabels;
}

@end
