//
//  XMLHelper.m
//  SalesBook
//
//  Created by Andreas Kucher on 08.05.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "XMLHelper.h"

#import "SAGSyncManager.h"
#import "SAGLoginManager.h"

@implementation XMLHelper

+ (XMLDocument*) xmlHeader
{
    XMLDocument *doc = [[XMLDocument alloc] initWithRootElement:[XMLElement elementWithName:@"data"]];
    
    XMLElement *rootElement = [doc rootElement];
    
    XMLElement *udid = [XMLElement elementWithName:@"UDID"];
    [udid appendValue:[[SAGSyncManager sharedClient] deviceID]];
    [rootElement addChild:udid];
    
    XMLElement *email = [XMLElement elementWithName:@"email"];
    [email appendValue:[[SAGLoginManager sharedManger] username]];
    [rootElement addChild:email];
    
    XMLElement *password = [XMLElement elementWithName:@"password"];
    [password appendValue:[[SAGLoginManager sharedManger] password]];
    [rootElement addChild:password];
    
    XMLElement *language = [XMLElement elementWithName:@"language"];
    [language appendValue:[[NSLocale preferredLanguages] objectAtIndex:0]];
    [rootElement addChild:language];
    
    XMLElement *appVersion = [XMLElement elementWithName:@"appVersion"];
    [appVersion  appendValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    [rootElement addChild:appVersion];
    
    if ([[SAGLoginManager sharedManger] isDatabaseOpen])
    {
        XMLElement *clerkNumber = [XMLElement elementWithName:@"clerkNumber"];
        [clerkNumber appendValue:[[SAGSettingsManager sharedManager] clerkNumber]];
        [rootElement addChild:clerkNumber];
    }
    
    XMLElement *timestamp = [XMLElement elementWithName:@"timestamp"];
    [timestamp appendValue:[[NSDate date] asISO8601FormattedString]];
    [rootElement addChild:timestamp];
    
    return doc;
}

+ (NSString *)getXMLValue:(id)value
{
    if (value == nil) return @"";
    
    NSString *xmlValue;
    
    if ([value isKindOfClass:[NSString class]])
    {
        xmlValue = [XMLHelper replaceUnwantedCharacters:value];
    }
    else if ([value isKindOfClass:[NSNumber class]])
    {
        xmlValue = [value stringValue];
    }
    else if ([value isKindOfClass:[NSDate class]])
    {
        xmlValue = [value asISO8601FormattedString];
    }
    else if ([value isKindOfClass:[NSData class]])
    {
        xmlValue = [NSString base64StringFromData:value length:[value length]];
    }
    else
    {
        xmlValue = @"";
    }
    
    return xmlValue;
}

+ (NSString *)replaceUnwantedCharacters:(NSString *)string
{
    
    return [[[[[string stringByReplacingOccurrencesOfString: @"&" withString: @"&amp;amp;"]
               stringByReplacingOccurrencesOfString: @"\"" withString: @"&amp;quot;"]
              stringByReplacingOccurrencesOfString: @"'" withString: @"&amp;#39;"]
             stringByReplacingOccurrencesOfString: @">" withString: @"&amp;gt;"]
            stringByReplacingOccurrencesOfString: @"<" withString: @"&amp;lt;"];
}

@end
