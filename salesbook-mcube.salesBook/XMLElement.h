//
//  XMLElement.h
//  SalesBook
//
//  Created by Matthias Spohn on 27.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>
@class XMLAttribute;

@interface XMLElement : NSObject
{
    NSString *name;
	NSMutableString *value;
	XMLElement *_parent;
    
	NSMutableDictionary *attributes;
	NSMutableArray *childElements;
}

@property (readonly) NSString *name;
@property (weak) XMLElement *parent;

+ (id)elementWithName:(NSString*)aName;
+ (id)elementWithName:(NSString*)aName attributes:(NSDictionary*)someAttributes;
- (id)initWithName:(NSString*)aName;
- (void)addAttribute:(XMLAttribute*)anAttribute;
- (void)addAttributeNamed:(NSString*)aName withValue:(NSString*)aValue;
- (void)addAttributes:(NSDictionary*)someAttributes;
- (void)addChild:(XMLElement*)anElement;
- (void)appendValue:(NSString*)aValue;
- (NSString*)encodeEntities:(NSMutableString*)aString;
- (NSString*)prettyXML:(int)tabs;
- (NSString*)xml;

@end
