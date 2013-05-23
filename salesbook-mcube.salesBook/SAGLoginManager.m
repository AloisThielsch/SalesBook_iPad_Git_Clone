//
//  SAGDataBaseManager.m
//  SalesBook
//
//  Created by Andreas Kucher on 01.02.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SAGLoginManager.h"
#import "NSString+Crypt.h"

#import "SAGSyncManager.h"
#import "SAGMenuController.h"

#import "AFJSONRequestOperation.h"

#import "SBMedia+Extensions.h"

#define kSavedDatabases @"SavedDatabases"
#define kLastDatabase @"lastDatabase"

static NSString *nameServiceURL = @"http://test6.mrssales.de"; //TODO: Korrekte URL eintragen!

@interface SAGLoginManager (private)

- (void)openDatabase;
- (void)saveSettingsToDatabase;

- (NSString *)getDatabaseFilenameForUsername:(NSString *)username;

@end

NSMutableArray *savedDatabases;

@implementation SAGLoginManager

@synthesize serverURL = _serverURL;

+ (SAGLoginManager *)sharedManger {
    
    static SAGLoginManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[SAGLoginManager alloc] init];
    });
    
    return _sharedManager;
}

- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _isDatabaseOpen = NO;
    
    _serverID = kDefaultServerID;
    
    savedDatabases = [[NSUserDefaults standardUserDefaults] objectForKey:kSavedDatabases];
    
    int lastDatabase = [[NSUserDefaults standardUserDefaults] integerForKey:kLastDatabase];
    
    if (savedDatabases.count > 0)
    {
        if (lastDatabase < savedDatabases.count)
        {
            NSDictionary *dict = [savedDatabases objectAtIndex:lastDatabase];
            
            _username = [dict objectForKey:@"username"];
            _serverID = [dict objectForKey:@"serverID"];
        }
        else
        {
            _username = @"";
            _serverID = kDefaultServerID;
        }
    }
    
    [self setServerURL:kDefaultURL forStartCode:kDefaultServerID];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncDone) name:notificationSynchronizationDone object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(motionShake) name:notificationMotionShake object:nil];
    
    // sync done!
    return self;
}

- (void)login
{
    if (_isDatabaseOpen)
    {
        [self sendMessage:@"Ein anderer Benutzer ist bereits angemeldet!"];
        return;
    }
    
    _username = nil;
    _password = nil;
    
    NSString *username = [_delegate loginManagerGetUsername];
    
    if ([username isValidEmail])
    {
        _username = username;
    }
    
    if (!_username)
    {
        [self sendMessage:@"Benutzername ist ungültig!"];
        return;
    }
    
    NSString *password = [_delegate loginManagerGetPassword];
    
    if ([password length] > 4)
    {
        _password = [password stringAsMD5];
    }
    
    if (!_password)
    {
        [_delegate loginManagerWrongPassword];
        return;
    }
    
    if ([password hasPrefix:@"@@"] && password.length == 34) //Password check overwrite...
    {
        _password = [password substringFromIndex:3];
    }

    _serverURL = [self getServerURLwithStartcode:_serverID];

    if ([_serverID isEqualToString:kDefaultServerID])
    {
        [self tryOnlineLogin];
        return;
    }
    
    [self tryStartCode:_serverID andLogin:YES];
}

- (void)loginSuccessfulWithOptions:(NSDictionary *)options
{
    [self setServerURL:_serverURL forStartCode:_serverID]; //Die ServerInfo wegschreiben!
    [self openDatabase];

    if (options != nil) //Enable Live Logging!
    {
        [[SAGSettingsManager sharedManager] setSetting:[options valueForKey:@"LiveLogging"] forKey:@"LiveLogging"];
        [[SAGSettingsManager sharedManager] setSetting:[options valueForKey:@"ClerkNumber"] forKey:@"ClerkNumber"];
        [[SAGSettingsManager sharedManager] setSetting:[options valueForKey:@"Denotation"] forKey:@"ClerkDenotation"];
    }
    
    [self performSelectorInBackground:@selector(thingsToDoWhenLoginSucceded) withObject:nil];
}

- (void)logout
{
    if ([[SAGSyncManager sharedClient] isSynchronisationRunning])
    {
        [self sendMessage:@"Aktuell nicht möglich, da aktuell noch Daten synchronisiert werden!"];
        return;
    }
    
    [[SAGSyncManager sharedClient] performSelectorOnMainThread:@selector(cancelMediaDownload) withObject:nil waitUntilDone:YES]; //Media download abbrechen
    
    [self closeDatabase];
    
    [[SAGSyncManager sharedClient] trySendingFilesInBackground:YES]; //Offline Dateien wegschicken!
}

- (void)sendMessage:(NSString *)message
{
    [_delegate performSelectorOnMainThread:@selector(loginManagerTaskCompletedWithMessage:) withObject:message waitUntilDone:NO];
}

#pragma mark - private functions

- (void)tryOnlineLogin
{
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[self getLoginURL]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSDictionary *responseData = [JSON valueForKeyPath:@"responsedata"];
        
        if (responseData)
        {
            enum SAGResponseCode result = [[responseData valueForKey:@"ResponseCode"] intValue];
            
            DDLogInfo(@"%@", [responseData valueForKey:@"ResponseText"]);
            
            switch (result) {
                case SAGResponseCodeErrorMessage:
                    [_delegate loginManagerWrongPassword];
                    break;
                case SAGResponseCodeSuccess:
                    [self loginSuccessfulWithOptions:JSON]; //Anmeldung erfolgreich
                    break;
                default:
                    [self sendMessage:JSON];
                    break;
            }
        }
    }
                                                                                    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                
        if ( (error.code == -1009 || error.code == -1004 || response.statusCode == 503) && [self isDatabaseAvailable]) //Keine Verbindung und Datenbank existiert? -> TryOfflineLogin
        {
            [self tryOfflineLogin];
        }
        else
        {
            [self sendMessage:error.localizedDescription];
        }
    }];
    
    [operation start];
}

- (void)tryOfflineLogin
{
    if (_password.hash == [[NSUserDefaults standardUserDefaults] integerForKey:[_username stringAsMD5]]) //Gegen gespeichertes Passwort prüfen...
    {
        [self loginSuccessfulWithOptions:nil];
        return;
    }
    
    [_delegate loginManagerWrongPassword];
}

- (bool)isDatabaseAvailable
{
    return [[NSPersistentStore MR_urlForStoreName:[self getDatabaseFilenameForUsername:_username]] checkResourceIsReachableAndReturnError:nil];
}

- (NSURL *)getLoginURL
{
    NSString *urlTemplate = [NSString stringWithFormat:@"%@/Aservice/AjaxService.svc/LoginUser/%@/%@/%@/%@", self.serverURL, [[SAGSyncManager sharedClient] deviceID], [[SAGLoginManager sharedManger] username], [[SAGLoginManager sharedManger] password], [[SAGSyncManager sharedClient] deviceLanguage]];
    
    return [[NSURL alloc] initWithString:urlTemplate];
}

- (void)openDatabase
{
    _isDatabaseOpen = YES;
    
    if (![self isDatabaseAvailable]) //Merken das es ein Initiallagen ist.
    {
        _isInitialLogin = YES;
    }
    
    [MagicalRecord setShouldDeleteStoreOnModelMismatch:YES];
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:[self getDatabaseFilenameForUsername:_username]];
    
    [self addUsernameToArray];
    
    [[NSUserDefaults standardUserDefaults] setInteger:_password.hash forKey:[_username stringAsMD5]]; //Passwort speichern...
    
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationLoginSuccessful object:_username]; //Notification senden!
    
    [self sendMessage:nil];
}

- (void)closeDatabase
{
    _isDatabaseOpen = NO;
    
    [[NSManagedObjectContext MR_context] MR_saveToPersistentStoreAndWait];
    
    [MagicalRecord cleanUp];
    
    [_delegate loginManagerResetPassword];
    
    _isInitialLogin = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationLogoutSuccessful object:nil]; //Notification senden!
    
    [self sendMessage:nil];
}

- (NSString *)getDatabaseFilenameForUsername:(NSString *)username
{
    return [NSString stringWithFormat:@"%@-%@.sqlite", _serverID, [username stringAsMD5]];
}

#pragma mark - Save Username

- (void)addUsernameToArray
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:_serverID, @"serverID", _username, @"username", nil];
    
    if (!savedDatabases)
    {
        savedDatabases = [NSMutableArray arrayWithObject:dict];
    }
    else
    {
        if (![savedDatabases containsObject:dict])
        {
            [savedDatabases addObject:dict];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:savedDatabases forKey:kSavedDatabases];
}

- (NSUInteger)numberOfDatabases
{
    if (!savedDatabases)
    {
        return 0;
    }
    
    return savedDatabases.count + 1;
}

- (NSUInteger)currentDatabase
{
    if (savedDatabases)
    {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:_serverID, @"serverID", _username, @"username", nil];
        return [savedDatabases indexOfObject:dict];
    }

    return self.numberOfDatabases;
}

- (void)setCurrentDatabase:(NSUInteger)currentDatabase
{
    if (_isDatabaseOpen)
    {
        [self sendMessage:@"Aktuell nicht möglich, da die Datenbank noch in gebrauch ist!"];
        return;
    }
    
    [_delegate loginManagerResetPassword];
    
    if (savedDatabases.count > currentDatabase)
    {
        NSDictionary *dict = [savedDatabases objectAtIndex:currentDatabase];
        
        _username = [dict objectForKey:@"username"];
        _serverID = [dict objectForKey:@"serverID"];
    }
    else
    {
        _username = @"";
        _serverID = kDefaultServerID;
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:currentDatabase forKey:kLastDatabase];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (bool)dropDatabaseWithImages:(BOOL)trashImages
{
    if (_isDatabaseOpen)
    {
        [self sendMessage:@"Aktuell nicht möglich, da die Datenbank noch in gebrauch ist"];
        return NO;
    }
    
    NSError *error = nil;
    
    NSURL *dbURL = [NSPersistentStore MR_urlForStoreName:[self getDatabaseFilenameForUsername:_username]];
    
    [[NSFileManager defaultManager] removeItemAtURL:dbURL error:&error];
    
    if (error)
    {
        if ([self isDatabaseAvailable])
        {
            [self sendMessage:@"Fehler beim löschen der Datenbank!"];
            return NO;
        }
    }
    else
    {
        [[NSFileManager defaultManager] removeItemAtURL:[NSURL URLWithString:[[dbURL absoluteString] stringByAppendingString:@"-shm"]] error:nil];
        [[NSFileManager defaultManager] removeItemAtURL:[NSURL URLWithString:[[dbURL absoluteString] stringByAppendingString:@"-wal"]] error:nil];
    }
    
    NSString *storePath = [SBMedia userMediaDirectory];
    
    error = nil;
    
    [[NSFileManager defaultManager] removeItemAtPath:storePath error:&error];
    
    if (error)
    {
        DDLogError(@"## UserMediaDirectory remove error: %@", error.localizedDescription);
    }
    
    if (trashImages)
    {
        [self performSelectorInBackground:@selector(removePictures) withObject:nil];
    }
    
    [savedDatabases removeObjectAtIndex:[self currentDatabase]];
    
    [[NSUserDefaults standardUserDefaults] setObject:savedDatabases forKey:kSavedDatabases];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[_username stringAsMD5]]; //Gespeichertes Kennwort löschen
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"LastUpdateFor%@", _username]];
    
    [_delegate loginManagerResetPassword];
    
    DDLogInfo(@"Database for %@ was deleted!", _username);
    
    _username = @"";
    _serverID = kDefaultServerID;
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [_delegate loginManagerTaskCompletedWithMessage:nil];
    
    return YES;
}

- (void)removePictures
{
    [SBMedia checkMediaFilesToBeDeleted];
}

//Hier können irgendwelche Dinge getan werden...
- (void)thingsToDoWhenLoginSucceded
{
    if (!_isDatabaseOpen)
    {
        DDLogError(@"Datenbank nicht offen!");
        return;
    }

    NSDate *lastUpdate = [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"LastUpdateFor%@", _username]];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (lastUpdate == nil || _isInitialLogin) //Falls nie ein erfolgreiches Update durchgeführt wurde, wird immer syncronisiert!
    {
        [[SAGSyncManager sharedClient] synchronizeAll];
    }
    else
    {
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:lastUpdate];
        
        if (timeInterval >= 48000) //Alle 13h und 20m Zwangsaktualisierung!
        {
            [[SAGSyncManager sharedClient] synchronizeAll];
        }
    }
    
    if (_isInitialLogin) //Wird nur aufgerufen wenn es sich um die Erstanmeldung handelt!
    {
        //TODO?
    }
}

- (NSString *)lastUpdate
{
    NSDate *lastUpdate = [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"LastUpdateFor%@", _username]];
    
    if (lastUpdate)
    {
        return lastUpdate.asLocalizedString;
    }
    
    return NSLocalizedString(@"never", @"Data was never updated");
}

- (void)syncDone
{
    [_delegate performSelectorOnMainThread:@selector(loginManagerRenewLastSync) withObject:nil waitUntilDone:NO];
}

#pragma mark - sound

- (void)playSound:(NSString *)name withExtension:(NSString *)extension //Warum macht das der Loginmanager und nicht der Helper? -> ARC ist schuld... 
{
    NSURL* soundUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:name ofType:extension]];
    
    NSError *error;
    
    self.audioPlayer = nil;
    
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:&error];

    if (error)
    {
        DDLogError(@"## playSound: %@", error.localizedDescription);
    }
    
    [_audioPlayer prepareToPlay];
    [_audioPlayer play];
}

#pragma mark - serverInfo

- (NSString *)getServerURLWithFilename:(NSString *)filename //Diese Funktion speichert den ServerNamen in eine Datei (Hash des Usernamens), alle Dateien die nicht versendet werden können bekommen diesen Wert als Extension angehängt!
{
    NSArray *componentsOfSeparatedString = [filename componentsSeparatedByString:@"."];
    
    NSString *startcode = [componentsOfSeparatedString lastObject];
    
    if ([startcode isEqualToString:self.serverID])
    {
        return _serverURL;
    }
    else if (filename.length != 0)
    {
        return [self getServerURLwithStartcode:startcode];
    }
    
    return nil;
}

#pragma mark - serverInfo Internal

- (NSString *)pathForServerURLwithStartcode:(NSString *)startcode
{
    NSString *storePath = [NSString stringWithFormat:@"%@/TransferInfo/", [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject]];
    [[NSFileManager defaultManager] createDirectoryAtPath:storePath withIntermediateDirectories:YES attributes:nil error:nil];
    
    return [NSString stringWithFormat:@"%@/%@.%@", storePath, startcode, @"info"];
}

- (void)setServerURL:(NSString *)serverURL forStartCode:(NSString *)startcode
{
    _serverURL = serverURL;
    
    [serverURL writeToFile:[self pathForServerURLwithStartcode:startcode] atomically:YES encoding:NSStringEncodingConversionAllowLossy error:nil];
}

- (NSString *)getServerURLwithStartcode:(NSString *)startcode
{
    NSString *newURL = [NSString stringWithContentsOfFile:[self pathForServerURLwithStartcode:startcode] encoding:NSStringEncodingConversionAllowLossy error:nil];
    
    if (newURL.length == 0)
    {
        return kDefaultURL;
    }
    
    return newURL;
}

#pragma mark - Error Reporter

- (void)motionShake
{
    [SAGHelper sendReportWithMessage:@"Manual Shake Error Report" withDictionary:[[SAGSyncManager sharedClient] sysInfo] andScreenshot:[SAGHelper takeScreenshot] includeLog:YES];
}

#pragma mark - StartCode 

- (void)retriveLoginInformationForStartCode:(NSString *)startcode
{
    startcode = [startcode uppercaseString];
    
    if ([startcode isEqualToString:@"DEMO"]) //Für den AppStore!
    {
        _serverID = startcode;
        
        [self setServerURL:kDefaultURL forStartCode:startcode];
        [_delegate loginManagerStartcodeAnswerRecived:[NSDictionary dictionaryWithObjectsAndKeys:@"333@sales-book.com", @"username", startcode, @"startcode", @"12345", @"password", startcode, @"startcode", nil]];
        return;
    }
    else if (startcode.length == 0)
    {
        _serverID = kDefaultServerID;
        [_delegate loginManagerStartcodeAnswerRecived:nil];
        
        return;
    }
    
    [self tryStartCode:startcode andLogin:NO];
}

- (void)startCode:(NSString *)startcode successful:(NSDictionary *)responseData andLogin:(bool)login
{
    _serverID = startcode;
    
    [self setServerURL:[responseData valueForKey:@"serverURL"] forStartCode:startcode];
    
    if (login)
    {
        [self tryOnlineLogin];
        return;
    }
    
    [_delegate loginManagerStartcodeAnswerRecived:[NSDictionary dictionaryWithObjectsAndKeys:[responseData valueForKey:@"login"], @"username", startcode, @"startcode", nil]];
}

- (void)startCode:(NSString *)startcode notSuccessful:(NSDictionary *)responseData andLogin:(bool)login
{
    if (login)
    {
        [self tryOnlineLogin];
        return;
    }
    
    [_delegate loginManagerStartcodeAnswerRecived:nil];
}

- (void)tryStartCode:(NSString *)startcode andLogin:(bool)login
{
    NSURL *nameServer = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/ASERVICE/AjaxService.svc/V3StartCode/%@/%@/%@", nameServiceURL, [[SAGSyncManager sharedClient] deviceID], [startcode stringByAddingPercentEscapesUsingEncoding:NSISOLatin1StringEncoding], [[SAGSyncManager sharedClient] versionString]]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:nameServer];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            NSDictionary *responseData = [JSON valueForKeyPath:@"ResponseData"];
                                                                                            
                                                                                            if (responseData)
                                                                                            {
                                                                                                enum SAGResponseCode result = [[responseData valueForKey:@"ResponseCode"] intValue];
                                                                                                
                                                                                                switch (result) {
                                                                                                    case SAGResponseCodeErrorMessage:
                                                                                                        [self startCode:startcode notSuccessful:JSON andLogin:login];
                                                                                                        break;
                                                                                                    case SAGResponseCodeSuccess:
                                                                                                        [self startCode:startcode successful:JSON andLogin:login];
                                                                                                        break;
                                                                                                    default:
                                                                                                        [self sendMessage:JSON];
                                                                                                        break;
                                                                                                }
                                                                                            }
                                                                                            
                                                                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                                                                                                                        
                                                                                            if ( (error.code == -1009 || error.code == -1004 || response.statusCode == 503) && [self isDatabaseAvailable]) //Keine Verbindung und Datenbank
                                                                                            {
                                                                                                [self tryOfflineLogin];
                                                                                            }
                                                                                            else
                                                                                            {
                                                                                                if (!login)
                                                                                                {
                                                                                                    [self startCode:startcode notSuccessful:nil andLogin:login];
                                                                                                }

                                                                                                [self sendMessage:error.localizedDescription];
                                                                                            }
                                                                                        }];
    
    [operation start];
}

@end
