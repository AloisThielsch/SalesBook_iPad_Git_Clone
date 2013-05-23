//
//  SBSelectionOption+Extensions.m
//  SalesBook
//
//  Created by Andreas Kucher on 28.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBSelectionOption+Extensions.h"
#import "NSManagedObject+CustomFields.h"

@implementation SBSelectionOption (Extensions)

+ (bool)setAttributesfromDictionary:(NSDictionary *)dict forCustomField:(SBCustomField *)customField
{
    if ([dict isEqual:[NSNull null]])
    {
        return NO;
    }
    
    for (NSDictionary *selectBox in dict) //TODO: Remove DICT in DICT! 
    {
        for (NSDictionary *option in [dict valueForKey:@"options"])
        {
            NSString *optionCode = [option valueForKey:@"optionCode"];
            
            if (optionCode.length == 0)
            {
                continue;
            }
            
            SBSelectionOption *selectOption = [customField selectionOptionWithOptionCode:optionCode];
            
            if (!selectOption)
            {
                selectOption = [SBSelectionOption MR_createEntity]; //Neue Option anlegen
                selectOption.optionCode = optionCode;
                selectOption.customField = customField;
            }
            
            [selectOption MR_importValuesForKeysWithObject:option];
            
            for (NSDictionary *denotation in [option valueForKey:@"denotations"])
            {
                [selectOption setAttribute:[denotation objectForKey:@"denotation"] withKey:@"denotation" andLanguage:[denotation objectForKey:@"language"]];
            }
        }
    }
    
    return YES;
}

- (NSString *)denotationWithLanguage:(NSString *)language
{
    return [self stringValueForAttribute:@"denotation" andLanguage:language];
}

@end
