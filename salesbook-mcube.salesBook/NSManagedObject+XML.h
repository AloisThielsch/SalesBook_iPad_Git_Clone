//
//  NSManagedObject+XML.h
//  SalesBook
//
//  Created by Matthias Spohn on 27.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (XML)

- (NSString *)toXMLforDelete:(BOOL)deleteXML;

@end
