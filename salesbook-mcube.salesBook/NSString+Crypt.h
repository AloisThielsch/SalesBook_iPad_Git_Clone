//
//  NSString+Crypt.h
//  SalesBook
//
//  Created by Andreas Kucher on 14.12.12.
//  Copyright (c) 2012 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Crypt)

- (NSString *)stringAsMD5;
- (NSString *)stringAsSHA256;

@end
