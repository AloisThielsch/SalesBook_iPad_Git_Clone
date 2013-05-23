//
//  SBAttribute+Extensions.m
//  SalesBook
//
//  Created by Julian Knab on 13.02.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBAttribute+Extensions.h"

@implementation SBAttribute (Extensions)

- (SBAttribute *)cloneAttribute
{
    SBAttribute *newAttribute = [SBAttribute MR_createEntity];

    NSDictionary *memberVariables = [[NSEntityDescription entityForName:@"SBAttribute" inManagedObjectContext:self.managedObjectContext] attributesByName];
    
    for (NSString *mv in memberVariables)
    {
        [newAttribute setValue:[self valueForKey:mv] forKey:mv];
    }

    return newAttribute;
}

+ (SBAttribute *)cloneAttribute:(SBAttribute *)attributeToClone
{
    return [attributeToClone cloneAttribute];
}

@end