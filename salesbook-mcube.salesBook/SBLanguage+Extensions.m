//
//  SBlanguageuage+Extensions.m
//  SalesBook
//
//  Created by Andreas Kucher on 13.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBLanguage+Extensions.h"

#import "SAGSyncManager.h"

@implementation SBLanguage (Extensions)

+ (SBLanguage *)getlanguageuageWithlanguageNumber:(NSString *)languageNumber
{
    return [SBLanguage MR_findFirstByAttribute:@"languageNumber" withValue:languageNumber];
}

+ (BOOL)updateDocumentFromDictionary:(NSDictionary *)dict
{
    NSString *uniqueID = [dict valueForKey:[self webserviceUniqueID]];
    
    if (uniqueID.length == 0)
    {
        NSString *errorMessage = [NSString stringWithFormat:@"Can´t update %@ from Dictionary! Reason: %@ is missing!", [[self class] description], [self webserviceUniqueID]];
        
        [[SAGSyncManager sharedClient] addErrorWithMessage:errorMessage andUserInfo:dict];
        
        return NO;
    }
    
    SBLanguage *language = [self getlanguageuageWithlanguageNumber:uniqueID];
    
    if (!language)
    {
        language = [SBLanguage MR_createEntity];
        language.languageNumber = uniqueID;
    }
    
    [language MR_importValuesForKeysWithObject:dict];
    
    return YES;
}

+ (NSString *)webserviceUniqueID
{
    return @"language";
}

@end
