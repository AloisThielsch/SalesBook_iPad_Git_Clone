//
//  XMLElement.m
//  SalesBook
//
//  Created by Matthias Spohn on 27.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "XMLElement.h"
#import "XMLAttribute.h"

@implementation XMLElement

@synthesize name;
@synthesize parent;

/*
 Neues XML-Element mit Tag-Name
*/
+ (id)elementWithName:(NSString*)aName
{
	return [[XMLElement alloc] initWithName:aName];
}

/*
 Neues XML-Element mit Tag-Name und Attribut(e)
*/
+ (id)elementWithName:(NSString*)aName attributes:(NSDictionary*)someAttributes
{
	XMLElement *anElement = [[XMLElement alloc] initWithName:aName];
	[anElement addAttributes:someAttributes];
    
	return anElement;
}

/*
 Init des XML-Element mit Tag-Name
*/
- (id)initWithName:(NSString*)aName
{
	if (self = [super init])
	{
		name = [[NSString alloc] initWithString:aName];
		_parent  = nil;
		attributes = [[NSMutableDictionary alloc] init];
		childElements = [[NSMutableArray alloc] init];
	}
    
	return self;
}

/*
 Fügt dem Element ein Attribut hinzu
*/
- (void)addAttribute:(XMLAttribute*)anAttribute
{
	[attributes setObject:anAttribute.value forKey:anAttribute.name];
}

/*
 Fügt dem Element ein Attribut mit Name und Wert hinzu
*/
- (void)addAttributeNamed:(NSString*)aName withValue:(NSString*)aValue
{
	[attributes setObject:aValue forKey:aName];
}

/*
 Fügt ein Dictionary mit name/values dem Element hinzu.
*/
- (void)addAttributes:(NSDictionary*)someAttributes
{
	if (someAttributes != nil)
	{
		[attributes addEntriesFromDictionary:someAttributes];
	}
}

/*
 Fügt Kind-Element dem Element hinzu.
*/
- (void)addChild:(XMLElement*)anElement
{
	[childElements addObject:anElement];
}

/*
 String-Value an Element hängen
*/
- (void)appendValue:(NSString*)aValue
{
	if (value == nil)
		value = [[NSMutableString alloc] init];
    
    if (aValue == nil) aValue = @"";
    
	[value appendString:aValue];
}

/*
 XML-Element mit Attributen und Kindern, schön formatiert. Tab-Argument = 0.
*/
- (NSString*)prettyXML:(int)tabs
{
	NSMutableString *xmlResult = [[NSMutableString alloc] init];
	//  
	for (int i=0; i<tabs; i++)
		[xmlResult appendFormat:@"\t"];
	[xmlResult appendFormat:@"<%@", name];
    
	for (NSString *key in attributes)
	{
		[xmlResult appendFormat:@" %@=\"%@\"", key, [attributes objectForKey:key]];
	}
    
	int numChildren = [childElements count];
	if (numChildren == 0 && value == nil)
	{
		[xmlResult appendFormat:@" />\n"];
		return xmlResult;
	}
    
	if (numChildren != 0)
	{
		[xmlResult appendString:@">\n"];
		for (int i=0; i<numChildren; i++)
			[xmlResult appendString:[[childElements objectAtIndex:i] prettyXML:(tabs+1)]];
		for (int i=0; i<tabs; i++)
			[xmlResult appendFormat:@"\t"];
		[xmlResult appendFormat:@"</%@>\n", name];
        
		return xmlResult;
	}
	else	// there must be a value
	{
		[xmlResult appendFormat:@">%@</%@>\n", [self encodeEntities:value], name];
		return xmlResult;
	}
}


/* 
 XML-Element mit Attributen und Kindern, kompakt
*/
- (NSString*)xml
{
	NSMutableString *xmlResult = [[NSMutableString alloc] init];
	// append open bracket and element name
	[xmlResult appendFormat:@"<%@", name];
    
	for (NSString *key in attributes)
	{
		[xmlResult appendFormat:@" %@=\"%@\"", key, [attributes objectForKey:key]];
	}
    
	// append closing bracket and value
	int numChildren = [childElements count];
	if (numChildren == 0 && value == nil)
	{
		[xmlResult appendFormat:@"/>"];
		return xmlResult;
	}
    
	if (numChildren != 0)
	{
		[xmlResult appendString:@">"];
		for (int i=0; i<numChildren; i++)
			[xmlResult appendString:[[childElements objectAtIndex:i] xml]];
		[xmlResult appendFormat:@"</%@>", name];
        
		return xmlResult;
	}
	else	// there must be a value
	{
		[xmlResult appendFormat:@"><![CDATA[%@]]></%@>", value, name];
        //[xmlResult appendFormat:@">%@</%@>", [self encodeEntities:value], name];
		return xmlResult;
	}
}

/*
 XML-Steuerzeichen korrigieren
*/
- (NSString*)encodeEntities:(NSMutableString*)aString
{
	if (aString == nil || [aString length] == 0)
		return @"";
    
	NSMutableString *result = [[NSMutableString alloc] init];
	[result appendString:aString];
	[result replaceOccurrencesOfString:@"&"
							withString:@"&amp;"
							   options:0
								 range:NSMakeRange(0, [result length])];
	[result replaceOccurrencesOfString:@"<"
							withString:@"&lt;"
							   options:0
								 range:NSMakeRange(0, [result length])];
	[result replaceOccurrencesOfString:@">"
							withString:@"&gt;"
							   options:0
								 range:NSMakeRange(0, [result length])];
	[result replaceOccurrencesOfString:@"'"
							withString:@"&apos;"
							   options:0
								 range:NSMakeRange(0, [result length])];
	[result replaceOccurrencesOfString:@"\""
							withString:@"&quot;"
							   options:0
								 range:NSMakeRange(0, [result length])];
    
	return result;
}

@end
