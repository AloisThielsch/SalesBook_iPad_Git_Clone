//
//  SBAttribute+Extensions.h
//  SalesBook
//
//  Created by Julian Knab on 13.02.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBAttribute.h"

@interface SBAttribute (Extensions)

- (SBAttribute *)cloneAttribute;
+ (SBAttribute *)cloneAttribute:(SBAttribute *)attributeToClone;

@end