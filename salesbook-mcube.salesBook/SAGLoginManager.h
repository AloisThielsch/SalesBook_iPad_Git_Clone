//
//  SAGDataBaseManager.h
//  SalesBook
//
//  Created by Andreas Kucher on 01.02.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#define kDefaultURL @"http://test6.mrssales.de"
#define kDefaultServerID @"default"

@protocol SAGLoginManagerDelegate <NSObject>

- (NSString *)loginManagerGetUsername;
- (NSString *)loginManagerGetPassword;

- (void)loginManagerResetPassword;
- (void)loginManagerTaskCompletedWithMessage:(NSString *)message;
- (void)loginManagerWrongPassword;

- (void)loginManagerStartcodeAnswerRecived:(NSDictionary *)answer;

- (void)loginManagerInitiateSyncronization;
- (void)loginManagerRenewLastSync;

@end

@interface SAGLoginManager : NSObject

@property (nonatomic, weak) id  delegate;
@property (nonatomic, readonly) bool isDatabaseOpen;

@property (nonatomic, readonly) NSString *username;
@property (nonatomic, readonly) NSString *password;

@property (nonatomic, readonly) NSString *serverURL;
@property (nonatomic, readonly) NSString *serverID;

@property (readonly, assign) NSUInteger numberOfDatabases;
@property (readwrite, assign) NSUInteger currentDatabase;

@property (nonatomic, readonly) BOOL isInitialLogin;

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

+ (SAGLoginManager *)sharedManger;

- (void)login;

- (void)logout;

- (bool)dropDatabaseWithImages:(BOOL)trashImages;

- (void)retriveLoginInformationForStartCode:(NSString *)startcode;

- (NSString *)lastUpdate;

- (void)playSound:(NSString *)name withExtension:(NSString *)extension;

- (NSString *)getServerURLWithFilename:(NSString *)filename;

@end
