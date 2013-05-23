//
//  SAGSettings.h
//  SalesBook
//
//  Created by Andreas Kucher on 14.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SAGSettingsManager : NSObject

@property (nonatomic) NSString *mandator;
@property (nonatomic) NSString *mediaDownloadPath;

@property (nonatomic, readonly) NSString *clerkNumber;
@property (nonatomic, readonly) NSString *clerkDenotation;

@property (nonatomic) NSString *itemDisplayLanguage;
@property (nonatomic) NSString *stockType;
@property (nonatomic) NSString *currency;

@property (nonatomic, strong) NSMutableDictionary *inMemoryStore;

+ (SAGSettingsManager *)sharedManager;

- (id)settingForKey:(NSString *)key withDefaultValue:(id)defaultValue;
- (id)settingForKey:(NSString *)key;

- (void)setSetting:(id)value forKey:(NSString *)key;

- (void)deleteSettingForKey:(NSString *)key;

- (void)showAllSettings;

- (bool)isLifeLoggingEnabled;

@end
