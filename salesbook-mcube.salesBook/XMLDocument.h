//
//  XMLDocument.h
//  SalesBook
//
//  Created by Matthias Spohn on 27.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>
@class XMLElement;

@interface XMLDocument : NSObject
{
    XMLElement *_rootElement;
}

@property (strong) XMLElement *rootElement;

+ (id)documentWithXMLString:(NSString*)anXMLString;
- (id)initWithRootElement:(XMLElement*)aRootElement;
- (id)initWithString:(NSString*)anXMLString;
- (NSString*)prettyXML;
- (NSString*)xml;

@end
