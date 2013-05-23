//
//  SAGAttribute.h
//  SalesBook
//
//  Created by Matthias Spohn on 27.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMLAttribute : NSObject
{
    NSString *name;
    NSString *value;
}

+ (id)attributeWithName:(NSString*)aName value:(NSString*)aValue;
- (id)initWithName:(NSString*)aName value:(NSString*)aValue;

@property (readonly) NSString *name;
@property (readonly) NSString *value;

@end
