//
//  SAGAttribute.m
//  SalesBook
//
//  Created by Matthias Spohn on 27.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "XMLAttribute.h"

@implementation XMLAttribute

@synthesize name;
@synthesize value;

+(id)attributeWithName:(NSString*)aName value:(NSString*)aValue {
	return [[XMLAttribute alloc] initWithName:aName value:aValue];
}

-(id)initWithName:(NSString*)aName value:(NSString*)aValue
{
	if (self = [super init])
	{
		name = [[NSString alloc] initWithString:aName];
		value = [[NSString alloc] initWithString:aValue];
	}
    
	return self;
}

@end
