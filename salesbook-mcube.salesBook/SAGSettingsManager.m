//
//  SAGSettings.m
//  SalesBook
//
//  Created by Andreas Kucher on 14.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SAGSettingsManager.h"

#import "SBKeyValueStore.h"

@implementation SAGSettingsManager

+ (SAGSettingsManager *)sharedManager
{
    static SAGSettingsManager *_currentSettings = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _currentSettings = [[SAGSettingsManager alloc] init];
    });
    
    return _currentSettings;
}

- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }

    [self defaultSettings]; //Initialisiert default settings....
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetCache) name:notificationLogoutSuccessful object:nil];
    
    return self;
}

#pragma mark - defaultSettings

- (void)defaultSettings //Hier kann man Settings mit Voreinstellung definieren! Falls der Wert bereits geändert wurde, passiert nix!
{
    [self settingForKey:@"currency" withDefaultValue:@"EUR"];
    [self settingForKey:@"stockType" withDefaultValue:@"1-  1"];
}

#pragma mark - helper

- (void)setMandator:(NSString *)mandator
{
    [self setSetting:mandator forKey:@"mandator"];
}

- (NSString *)mandator
{
    return [self settingForKey:@"mandator"];
}

- (void)setMediaDownloadPath:(NSString *)mediaDownloadPath
{
    [self setSetting:mediaDownloadPath forKey:@"mediaDownloadPath"];
}

- (NSString *)mediaDownloadPath
{
    return [self settingForKey:@"mediaDownloadPath"];
}

- (void)setItemDisplayLanguage:(NSString *)itemDisplayLanguage
{
    [self setSetting:itemDisplayLanguage forKey:@"itemDisplayLanguage"];
}

- (NSString *)itemDisplayLanguage
{
    return [self settingForKey:@"itemDisplayLanguage"];
}

- (void)setCurrency:(NSString *)currency
{
    [self setSetting:currency forKey:@"currency"];
}

- (NSString *)currency
{
    return [self settingForKey:@"currency"];
}

- (NSString *)clerkDenotation
{
    return [self settingForKey:@"clerkDenotation"];
}

- (NSString *)clerkNumber
{
    return [self settingForKey:@"clerkNumber"];
}

- (bool)isLifeLoggingEnabled
{
    return [[self settingForKey:@"LiveLogging" withDefaultValue:[NSNumber numberWithBool:NO]] boolValue];
}

- (void)setStockType:(NSString *)stockType
{
    [self setSetting:stockType forKey:@"stockType"];
}

- (NSString *)stockType
{

// TODO: change back to "return ret;"

//    id ret = [self settingForKey:@"stockType"];
//    
//    return ret;
    
    return @"1-  1";
}

#pragma mark - speichern

- (id)settingForKey:(NSString *)key withDefaultValue:(id)defaultValue
{
    key = [key uppercaseString];
    
    id value = [self settingForKey:key];
    
    if (value)
    {
        return value;
    }
   
    if (defaultValue == nil) //Ist keine defaultValue definiert muss man auch nix speichern.
    {
        return nil;
    }
    
    [self setSetting:defaultValue forKey:key];
    
    return defaultValue;
}

- (id)settingForKey:(NSString *)key
{
    key = [key uppercaseString];
    
    id value = [_inMemoryStore valueForKey:key];
    
    if (value)
    {
        return value;
    }
    
    SBKeyValueStore *store = [SBKeyValueStore MR_findFirstByAttribute:@"theKey" withValue:key];
    
    if (store)
    {
        if (_inMemoryStore == nil)
        {
            _inMemoryStore = [NSMutableDictionary new];
        }
        
        [_inMemoryStore setValue:store.theValue forKey:key];
        
        return [store theValue];
    }
    
    return nil;
}

- (void)setSetting:(id)value forKey:(NSString *)key
{
    key = [key uppercaseString];
    
    SBKeyValueStore *store = [SBKeyValueStore MR_findFirstByAttribute:@"theKey" withValue:key];
    
    if (!store)
    {
        store = [SBKeyValueStore MR_createEntity];
        store.theKey = key;
    }
    
    if (![store.theValue isEqual:value])
    {
        store.theValue = value;
        [store.managedObjectContext MR_saveToPersistentStoreAndWait];
    }
    
    [_inMemoryStore setValue:value forKey:key];
}

- (void)deleteSettingForKey:(NSString *)key
{
    key = [key uppercaseString];
    
    SBKeyValueStore *store = [SBKeyValueStore MR_findFirstByAttribute:@"theKey" withValue:key];
    
    if (store)
    {
        [_inMemoryStore removeObjectForKey:key];
        
        [store MR_deleteEntity];
    }
}


#pragma mark - KeyValue Magic

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    [self setSetting:value forKey:key];
}

- (id)valueForUndefinedKey:(NSString *)key
{
    return [self settingForKey:key];
}

#pragma  mark - Cache reset beim logout, sonst bekommt der nächste User die Settings :-)

- (void)resetCache
{
    [_inMemoryStore removeAllObjects];
}

- (void)showAllSettings
{
    for (SBKeyValueStore *kvStore in [SBKeyValueStore MR_findAll])
    {
        id value =  [_inMemoryStore valueForKey:kvStore.theKey];
        
        DDLogInfo(@"%@ (%d) -> %@", kvStore.theKey, [value isEqual:kvStore.theValue], kvStore.theValue);
    }
}

@end
