//
//  XMLDocument.m
//  SalesBook
//
//  Created by Matthias Spohn on 27.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "XMLDocument.h"
#import "XMLElement.h"

@interface SAGXMLBuilder : NSObject <NSXMLParserDelegate>
{
	XMLElement *rootElement;
	XMLElement *openElement;
	XMLElement *parentElement;
}

- (XMLElement*)rootElement;

@end

@implementation SAGXMLBuilder

- (id)init
{
	if (self = [super init])
	{
		rootElement = nil;
		openElement = nil;
		parentElement = nil;
	}
    
	return self;
}

- (XMLElement*)rootElement
{
	return rootElement;
}

@end

@implementation XMLDocument

@synthesize rootElement;

+ (id)documentWithXMLString:(NSString*)anXMLString
{
	return [[XMLDocument alloc] initWithString:anXMLString];
}

- (id)initWithRootElement:(XMLElement*)aRootElement
{
	if (self = [super init])
	{
		rootElement = aRootElement;
	}
    
	return self;
}

- (id)initWithString:(NSString*)anXMLString
{
	if (self = [super init])
	{
		SAGXMLBuilder *builder = [[SAGXMLBuilder alloc] init];
		NSXMLParser *parser = [[NSXMLParser alloc] initWithData:[anXMLString dataUsingEncoding:NSUTF8StringEncoding]];
		[parser setDelegate:builder];
		[parser parse];
        
		rootElement = [builder rootElement];
	}   
	return self;
}

- (NSString*)prettyXML
{
	if (rootElement != nil)
	{
		NSMutableString *result = [[NSMutableString alloc] init];
		[result appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n"];
		[result appendString:[rootElement prettyXML:0]];
		return result;
	}
	else
		return nil;
}

- (NSString*)xml
{
	if (rootElement != nil)
	{
		NSMutableString *result = [[NSMutableString alloc] init];
		[result appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n"];
		[result appendString:[rootElement xml]];
		return result;
	}
	else
		return nil;
}

@end
