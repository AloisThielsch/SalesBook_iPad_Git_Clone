//
//  XMLHelper.h
//  SalesBook
//
//  Created by Andreas Kucher on 08.05.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XMLDocument.h"
#import "XMLElement.h"
#import "XMLAttribute.h"

@interface XMLHelper : NSObject

+ (XMLDocument*) xmlHeader;

+ (NSString *)getXMLValue:(id)value;
+ (NSString *)replaceUnwantedCharacters:(NSString *)string;

@end
