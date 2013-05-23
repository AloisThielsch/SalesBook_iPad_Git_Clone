//
//  SBSelectionOption+Extensions.h
//  SalesBook
//
//  Created by Andreas Kucher on 28.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBSelectionOption.h"
#import "SBCustomField+Extensions.h"

@interface SBSelectionOption (Extensions)

+ (bool)setAttributesfromDictionary:(NSDictionary *)dict forCustomField:(SBCustomField *)customField;

- (NSString *)denotationWithLanguage:(NSString *)language;

@end
