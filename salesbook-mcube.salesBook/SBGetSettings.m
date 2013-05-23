//
//  SBGetSettings.m
//  SalesBook
//
//  Created by Andreas Kucher on 19.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBGetSettings.h"

#import "SAGSettingsManager.h"
#import "SAGSyncManager.h"

@implementation SBGetSettings

+ (BOOL)updateDocumentFromDictionary:(NSDictionary *)dict
{
    NSString *uniqueID = [dict valueForKey:[self webserviceUniqueID]];
    
    if (uniqueID.length == 0)
    {
        NSString *errorMessage = [NSString stringWithFormat:@"Can´t update %@ from Dictionary! Reason: %@ is missing!", [[self class] description], [self webserviceUniqueID]];
        
        [[SAGSyncManager sharedClient] addErrorWithMessage:errorMessage andUserInfo:dict];
        
        return NO;
    }
    
    NSString *newTransferDate = [dict valueForKey:[self webserviceTransferDate]];
    
    if (newTransferDate.length == 0)
    {
        NSString *errorMessage = [NSString stringWithFormat:@"Can´t update %@ from Dictionary! Reason: %@ is missing!", [[self class] description],[self webserviceTransferDate]];
        
        [[SAGSyncManager sharedClient] addErrorWithMessage:errorMessage andUserInfo:dict];
        
        return NO;
    }
    
    if ([[dict valueForKey:[self webserviceActionState]] intValue] == SAGActiveStateDeleted) //Wenn das Document gelöscht werden soll...
    {
        [[SAGSettingsManager sharedManager] deleteSettingForKey:uniqueID];
        
        return YES; //Fertig!
    }
    
    if ([[self initialSettings] containsObject:uniqueID])  //Prüfen ob die Setting eine initialSetting ist!
    {
        [[SAGSettingsManager sharedManager] settingForKey:uniqueID withDefaultValue:[dict valueForKey:@"value"]]; //Wird nur initial gesetzt, da der User diese Einstellung verändern kann!
        
        return YES;
    }
    
    [[SAGSettingsManager sharedManager] setSetting:[dict valueForKey:@"value"] forKey:uniqueID];
    
    return YES;
}

#pragma mark - Webservice Settings

+ (NSString *)localizedClassName
{
    return NSLocalizedString(@"Application Settings", @"SBGetSettings"); //Plural
}

+ (NSString *)webserviceUpdate
{
    return @"V3GetSettings";
}

+ (NSString *)webserviceDelete
{
    return nil;
}

+ (NSString *)webserviceActionState
{
    return @"actionFlag";
}

+ (NSString *)webserviceUniqueID
{
    return @"key";
}

+ (NSString *)webserviceTransferDate
{
    return @"ts";
}

+ (NSString *)webserviceBlockSize
{
    return @"0";
}

+ (NSString *)webserviceDataBlock
{
    return @"settings";
}

+ (NSString *)webserviceDataBlockDeleted
{
    return @"settingsDeleted";
}

+ (NSArray *)initialSettings  //Alle Objekte die in dem Array defniert wurden, werden nur beim ersten mal vom Server gesetzt!
{
    return [NSArray array]; //TODO: Remove wenn Einstellungen verfügbar!
    
    static NSArray *initialSettings;
    if (!initialSettings)
        initialSettings = @[@"itemDisplayLanguage", @"stockType"];
    return initialSettings;
}

@end
