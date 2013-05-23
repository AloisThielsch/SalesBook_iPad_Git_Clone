//
//  SAGAppDelegate.m
//  SalesBook
//
//  Created by Andreas Kucher on 13.12.12.
//  Copyright (c) 2012 Siller AG. All rights reserved.
//

#import "SAGAppDelegate.h"

#import "SAGLoginManager.h"
#import "SAGSyncManager.h"

#import "DDASLLogger.h"
#import "DDTTYLogger.h"
#import "DDFileLogger.h"

@implementation SAGAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Logging
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    //FileLogger
    _fileLogger  = [DDFileLogger new];
    [DDLog addLogger:_fileLogger];

#if defined (CONFIGURATION_Release)
    [[BITHockeyManager sharedHockeyManager] configureWithBetaIdentifier:@"16fb26634ae7a114ef472083adaab8db" liveIdentifier:@"16fb26634ae7a114ef472083adaab8db" delegate:self];
    [[BITHockeyManager sharedHockeyManager] startManager];
#endif
	
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    if ([[SAGLoginManager sharedManger] isDatabaseOpen]) [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    if ([[UIDevice currentDevice] isMultitaskingSupported])
    {        
        UIApplication *application = [UIApplication sharedApplication];
        
        __block UIBackgroundTaskIdentifier background_task;
        
        background_task = [application beginBackgroundTaskWithExpirationHandler: ^{
            
            [application endBackgroundTask: background_task];
            background_task = UIBackgroundTaskInvalid;
        }];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            //DO STUFF IN BACKGROUND HERE
            [[SAGSyncManager sharedClient] trySendingFilesInBackground:NO]; //Das muss in dem Fall "Syncron" erfolgen!
            
            if (![[SAGLoginManager sharedManger] isDatabaseOpen]) [SBMedia checkMediaFilesToBeDeleted]; //Wenn kein Benutzer angemeldet ist, werden alle noch mehr benötigten Medien gelöscht!
            
            [application endBackgroundTask: background_task];
            background_task = UIBackgroundTaskInvalid;
        });
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    if ([[SAGLoginManager sharedManger] isDatabaseOpen])
    {
        if ([[SAGSyncManager sharedClient] isSynchronisationRunning]) return;
        
        NSDate *lastUpdate = [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"LastUpdateFor%@", [[SAGLoginManager sharedManger] username]]];
        
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:lastUpdate];
        
        if (timeInterval >= 48000) //Alle 13h und 20m Zwangsaktualisierung!
        {
            PSPDFAlertView *alertView = [[PSPDFAlertView alloc] initWithTitle:NSLocalizedString(@"You have not updated since", @"SyncManager not updated message") message:[lastUpdate asLocalizedString]];
            
            [alertView addButtonWithTitle:NSLocalizedString(@"update now", @"SyncManager update now - update warning") block:^{
                
                [[SAGSyncManager sharedClient] synchronizeAll];
            }];
            
            [alertView  setCancelButtonWithTitle:NSLocalizedString(@"later", @"SyncManager later - update warning") block:^{
                
                DDLogWarn(@"*** User %@ skiped update warning!", [[SAGLoginManager sharedManger] username]);
            }];
            
            [alertView show];
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - BITUpdateManagerDelegate

- (NSString *)customDeviceIdentifierForUpdateManager:(BITUpdateManager *)updateManager
{
    return [[SAGSyncManager sharedClient] deviceID];
}

#pragma mark - BITHockeyManagerDelegate

- (BOOL)shouldUseLiveIdentifierForHockeyManager:(BITHockeyManager *)hockeyManager
{
#if defined (CONFIGURATION_Release)
    return YES;
#endif
    return NO;
}

- (NSString *)userNameForHockeyManager:(BITHockeyManager *)hockeyManager componentManager:(BITHockeyBaseManager *)componentManager
{
    return [[SAGLoginManager sharedManger] username];
}

#pragma mark - BITCrashManagerDelegate

- (NSString *)applicationLogForCrashManager:(BITCrashManager *)crashManager
{
    NSString *description = [self getLogFilesContentWithMaxSize:5000]; // 5000 bytes should be enough!
    
    if ([description length] == 0)
    {
        return nil;
    }
    else
    {
        return description;
    }
}

#pragma mark - internal

// get the log content with a maximum byte size
- (NSString *)getLogFilesContentWithMaxSize:(NSInteger)maxSize
{
    NSMutableString *description = [NSMutableString string];
    
    NSArray *sortedLogFileInfos = [[_fileLogger logFileManager] sortedLogFileInfos];
    NSInteger count = [sortedLogFileInfos count];
    
    // we start from the last one
    for (NSInteger index = count - 1; index >= 0; index--)
    {
        DDLogFileInfo *logFileInfo = [sortedLogFileInfos objectAtIndex:index];
        
        NSData *logData = [[NSFileManager defaultManager] contentsAtPath:[logFileInfo filePath]];
        if ([logData length] > 0)
        {
            NSString *result = [[NSString alloc] initWithBytes:[logData bytes]
                                                        length:[logData length]
                                                      encoding: NSUTF8StringEncoding];
            
            [description appendString:result];
        }
    }
    
    if ([description length] > maxSize)
    {
        description = (NSMutableString *)[description substringWithRange:NSMakeRange([description length]-maxSize-1, maxSize)];
    }
    
    return description;
}

@end
