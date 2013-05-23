//
//  SAGSyncManager.m
//  SalesBook
//
//  Created by Andreas Kucher on 14.12.12.
//  Copyright (c) 2012 Siller AG. All rights reserved.
//

#import "SAGSyncManager.h"
#import "AFJSONRequestOperation.h"
#import "AFImageRequestOperation.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "NSNumber+CurrencyRound.h"
#import "NSDate+Extensions.h"
#import "NSString+Crypt.h"

#import "SBWebserviceInfo+Extension.h"
#import "SAGLoginManager.h"

#import "SBGetSettings.h"
#import "SBSalesOrganization+Extensions.h"
#import "SBClerk+Extensions.h"

#import "SBCustomer+Extensions.h"
#import "SBContact+Extensions.h"
#import "SBAddress+Extensions.h"
#import "SBCustomerMedia.h"
#import "SBCustomerMediaText.h"

#import "SBItemGroup+Extensions.h"
#import "SBItemGroupText.h"

#import "SBItem+Extensions.h"
#import "SBItemText.h"

#import "SBVariant+Extensions.h"
#import "SBVariantText.h"
#import "SBVariantMedia.h"

#import "SBPrice+Extensions.h"

#import "SBCustomField+Extensions.h"

#import "SBCatalog+Extensions.h"
#import "SBCatalogText.h"

#import "SBGetItemByCatalog.h"

#import "SBDocumentType+Extensions.h"
#import "SBDocument+Extensions.h"
#import "SBStock+Extensions.h"

#import "SBMedia+Extensions.h"

#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

#import "SBMedia+Extensions.h"

#import "SAGLoginManager.h"

#import "SyncManagerViewController.h"
#import "SAGAppDelegate.h"

#import "WTStatusBar.h"

#import "SBAssortment+Extensions.h"
#import "SBBaseColorMedia.h"

#define kRetryCounter 5 //Wenn die Verbindung abbricht, dann muss man x mal wiederholen bis die Sync beendet wird!

float lifoNumberOfTasks = 0.0f;

int   importNumberOfObjects = 0;
int   continueCounter = kRetryCounter;
bool  withErrors = NO;

NSArray *objectsToSync;

NSDate *syncStart;
NSDate *webserviceStart;
NSDate *newTimeStamp;
NSNumber *newRecordID;

NSString *lastObject;
NSString *lastWebservice;
NSString *lastTimestamp;

int indexPathRow = 0;

@interface SAGSyncManager ()

@property (nonatomic, readwrite) BOOL isSynchronisationRunning;
@property (nonatomic, readwrite) BOOL isSynchronisationPaused;
@property (nonatomic, readwrite) BOOL isSyncManagerUIVisible;
@property (nonatomic, readwrite) BOOL isMediaDownloadActive;

- (void)setIdleTimerDisabled:(BOOL)yesNo;

@end


@implementation SAGSyncManager

+ (SAGSyncManager *)sharedClient
{
    static SAGSyncManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[SAGSyncManager alloc] initWithServer:kDefaultURL];
    });
    
    return _sharedClient;
}

- (id)initWithServer:(NSString *)server
{
    self = [super initWithBaseURL:[NSURL URLWithString:[[SAGLoginManager sharedManger] serverURL]]];
    if (!self) {
        return nil;
    }
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    _connectionState = SAGConnectionStateUnknown;
    
    [self setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationNetworkStateChanged object:[NSNumber numberWithInt:status]];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lifoQueueWakeUpFromNotification:) name:notificationNetworkStateChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideSyncManagerUI) name:notificationSynchronizationDone object:nil];
    
    
    //Warenkörbe sichern
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveShoppingCart:) name:notificationShoppingCartChanged object:nil];
    
    //LIFOQueue initialisieren!
    _lifoQueue = [NSMutableArray new];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	[self setDefaultHeader:@"Accept" value:@"application/json"];
    
    return self;
}

#pragma mark - Class methods

- (void)synchronizeAll
{
    [self getUpdates];
}

- (void)getUpdates //Hier wird gesteuert welche Objekte Synchronisiert werden
{
    NSArray *objects = [NSArray arrayWithObjects:@"SBVariantMedia", @"SBPrice", @"SBStock" ,@"SBGetItemByCatalog", @"SBCatalogText", @"SBCatalog",
                        @"SBVariantText", @"SBVariant", @"SBItemText", @"SBItem", @"SBItemGroupText", @"SBItemGroup",
                        @"SBAddress", @"SBContact", @"SBCustomerMediaText", @"SBCustomerMedia", @"SBCustomer", @"SBAssortment", @"SBBaseColorMedia", @"SBDocumentType", @"SBSalesOrganization", @"SBCustomField", @"SBGetSettings", @"SBClerk", nil];
    
    [self startSyncWithObjects:objects];
}

- (void)cancelSynchronization {
    
    if (self.isSynchronisationRunning == YES)
    {
        [self addErrorWithMessage:NSLocalizedString(@"User requested cancelation!", @"Syncmanager cancel sync") andUserInfo:[NSDictionary dictionaryWithObject:@"W" forKey:@"Errorlevel"]];
        [_delegate performSelectorOnMainThread:@selector(syncManagerSetContinueButtonText:) withObject:NSLocalizedString(@"Continue", @"SyncManger Continuesynchronization") waitUntilDone:YES];
        
        [self lifoQueueAbort];
        
        if (self.isSynchronisationPaused)
        {
            [self continueSynchronization];
        }
        else
        {
            [self lifoQueueNextStep];
        }
    }
}

- (void)continueSynchronization
{
    if (self.isSynchronisationPaused == YES)
    {
        if (continueCounter > 0)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:notificationNetworkStateChanged object:[NSNumber numberWithInt:AFNetworkReachabilityStatusUnknown]];
        }
        else
        {
            [self cancelSynchronization];
        }
    }
}

- (void)addErrorWithMessage:(NSString *)message andUserInfo:(NSDictionary *)userInfo
{
    DDLogError(@"******************************************************************************************");
    DDLogError(@"** SyncManager Log: %@", message);
    DDLogError(@"******************************************************************************************");
    
    if ([_delegate respondsToSelector:@selector(syncManagerLocalizedErrorMessage:)])
    {
        NSAttributedString *date = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@   ", [NSDate nowAsLocalizedString]]];
        
        NSMutableAttributedString *attMessage = [[NSMutableAttributedString alloc] initWithString:message];
        
        if ([[userInfo valueForKey:@"Errorlevel"] isEqualToString:@"E"])
        {
            [attMessage addAttribute:NSForegroundColorAttributeName value:[UIColor redColor]  range:NSMakeRange(0, attMessage.length)];
            
            if (![[SAGSettingsManager sharedManager] isLifeLoggingEnabled]) [SAGHelper sendReportWithMessage:message withDictionary:userInfo andScreenshot:nil includeLog:YES]; //Wenn Live logging enabled ist, wird ohnhin ein Log geschrieben!
            
            withErrors = YES;
        }
        else if ([[userInfo valueForKey:@"Errorlevel"] isEqualToString:@"W"])
        {
            [attMessage addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor]  range:NSMakeRange(0, attMessage.length)];
        }
        
        NSMutableAttributedString *att = [NSMutableAttributedString new];
        
        [att appendAttributedString:date];
        [att appendAttributedString:attMessage];
        
        [att addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica" size:13] range:NSMakeRange(0, att.length)];
        
        [_delegate performSelectorOnMainThread:@selector(syncManagerLocalizedErrorMessage:) withObject:att waitUntilDone:NO];
    }
    
    if ([[SAGSettingsManager sharedManager] isLifeLoggingEnabled]) [self liveLoggingWithMessage:message andUserInfo:userInfo]; //Logeintrag direkt an den Server schicken!
    
    NSArray *sortedKeys = [[userInfo allKeys] sortedArrayUsingSelector: @selector(compare:)];
    
    for (NSString *key in sortedKeys)
    {
        if ([[userInfo objectForKey:key] isKindOfClass:[NSString class]])
        {
            DDLogError(@"** %@: %@", key, [userInfo objectForKey:key]);
        }
    }
    
    if (userInfo)
    {
        DDLogError(@"******************************************************************************************");
    }
}

- (void)liveLoggingWithMessage:(NSString *)message andUserInfo:(NSDictionary *)userInfo
{
    [SAGHelper sendReportWithMessage:message withDictionary:userInfo andScreenshot:nil includeLog:NO];
}

#pragma mark - Synchronization

- (void)startSyncWithObjects:(NSArray *)objects
{
    if (objects == nil)
    {
        DDLogInfo(@"Nothing to do!");
        return;
    }
    
    if (![[SAGLoginManager sharedManger] isDatabaseOpen]) //Prüfen ob die Datenbank offen ist...
    {
        DDLogInfo(@"Synchronization not possible, please login first!");
        return;
    }
    
    if (self.isSynchronisationRunning) //Verhindern das die Synchronisation mehrfach läuft...
    {
        DDLogInfo(@"Synchronization already running...");
        return;
    }
    
    if (self.isSyncManagerUIVisible)
    {
        DDLogInfo(@"SyncManagerUI is still visible, please try again when it´s gone!");
        return;
    }
    else
    {
        [self performSelectorOnMainThread:@selector(showSyncManagerUI) withObject:nil waitUntilDone:YES];
    }
    
    self.isSynchronisationRunning = YES;
    
    syncStart = [NSDate date]; //Zeit festhalten....
    
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    [userInfo setValue:[SAGHelper getAppVersion] forKey:@"appVersion"];
    [userInfo setValue:[[SAGLoginManager sharedManger] username] forKey:@"userName"];
    [userInfo setValue:[[SAGLoginManager sharedManger] serverID] forKey:@"serverID"];
    [userInfo setValue:[[SAGLoginManager sharedManger] serverURL] forKey:@"serverURL"];
    [userInfo setValue:[[SAGSettingsManager sharedManager] clerkNumber] forKey:@"clerkNumber"];
    [userInfo setValue:[[SAGSettingsManager sharedManager] clerkDenotation] forKey:@"clerkDenotation"];
    [userInfo setValue:self.deviceID forKey:@"deviceID"];
    [userInfo setValue:[self platform] forKey:@"devicePlatform"];
    [userInfo setValue:[self hwmodel] forKey:@"deviceModel"];
    [userInfo setValue:[[UIDevice currentDevice] systemVersion] forKey:@"deviceOSVersion"];
    [userInfo setValue:[[self freeDiskSpace] getHumanReadableFileSize] forKey:@"deviceFreeDiskSpace"];
    [userInfo setValue:[[SAGLoginManager sharedManger] lastUpdate] forKey:@"lastUpdate"];
    [userInfo setValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:@"appBuildNumber"];
    
    continueCounter = kRetryCounter; //Wenn die Verbindung abbricht, dann muss man x mal wiederholen bis die Sync beendet wird!
    
    [self cancelMediaDownload]; //Medien download anhalten...
    
    [self addErrorWithMessage:@"Synchronization started..." andUserInfo:userInfo];
    
    objectsToSync = objects;
    
    withErrors = NO;
    
    [self lifoQueueLoadObjectsFromArray:objectsToSync andStart:YES];
}

- (void)SynchronizationDone //Wird aufgerufen wenn die Synchronisation vollständig abgeschlossen wurde
{
    [self save]; //Speichern was wir biher geholt haben...; //Hier wird (sicherheitshalber) auch gespeichert...
    
    if ([_delegate respondsToSelector:@selector(syncManagerLocalizedTaskStatusChanged:)])
    {
        [_delegate performSelectorOnMainThread:@selector(syncManagerLocalizedTaskStatusChanged:) withObject:[NSString stringAsTimeSinceDate:syncStart] waitUntilDone:YES ];
    }
    
    NSString *message = NSLocalizedString(@"Synchronization done!", @"Synchronization done");
    
    if (withErrors == YES)
    {
        message = NSLocalizedString(@"Synchronization done with errors!", @"Synchronization done with errors");
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringAsTimeSinceDate:syncStart], @"duration", nil];
    
    if ([_delegate respondsToSelector:@selector(syncManagerLocalizedTaskNameChanged:)])
    {
        [_delegate performSelectorOnMainThread:@selector(syncManagerLocalizedTaskNameChanged:) withObject:message waitUntilDone:YES];
    }
    
    [self addErrorWithMessage:message andUserInfo:userInfo];  //Die Synchronisation ist abgeschlossen!
    
    [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:[NSString stringWithFormat:@"LastUpdateFor%@", [[SAGLoginManager sharedManger] username]]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [_delegate performSelectorOnMainThread:@selector(syncManagerIsSynchronisationPaused:) withObject:[NSNumber numberWithBool:NO] waitUntilDone:YES];
    
    [SAGHelper playSound:@"ding" withExtension:@"wav"]; //Fertig!
    
    self.isSynchronisationRunning = NO;
    
#if TARGET_IPHONE_SIMULATOR
    for (SBWebserviceInfo *info in [SBWebserviceInfo MR_findAll]) //Ausgabe für Tests
    {
        DDLogInfo(@"Webservice:%@ -> ts:%@ -> recordID:%@", info.webservice, info.timestamp.asISO8601FormattedString, info.recordID);
    }
#endif
    
    [self performSelectorInBackground:@selector(getAllMedia) withObject:nil];
}

#pragma mark - Medien

- (void)getAllMedia
{
    NSPredicate *predicate;
    
    if (self.connectionState == SAGConnectionStateMobile) //Prüfen welche Dateien geladen werden sollen...
    {
        predicate = [NSPredicate predicateWithFormat:@"(downloadPriority = %@ OR downloadPriority = nil) AND loadIfMobile = %@", @"A", @YES]; //Es werden nur Dateien geladen für die das Mobile laden erlaubt ist.
        DDLogInfo(@"## Media download -> mobile only!");
    }
    else if (self.connectionState == SAGConnectionStateWLAN)
    {
        predicate = [NSPredicate predicateWithFormat:@"(downloadPriority = %@ OR downloadPriority = nil)", @"A"]; //Alle Dateien laden...
        DDLogInfo(@"## Media download -> download all!");
    }
    else
    {
        DDLogInfo(@"## Media download -> canceled, not connected!");
        return;
    }
    
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"SBMedia"];
    fetch.predicate = predicate;
    fetch.fetchBatchSize = 200;
    
    fetch.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"isDownloaded" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"fileName" ascending:YES]];
    
    NSError *error;
    
    _mediaFrc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetch managedObjectContext:[NSManagedObjectContext MR_contextForCurrentThread] sectionNameKeyPath:nil cacheName:nil];
    
    [_mediaFrc performFetch:&error];
    
    if (error) DDLogError(@"## %@", error.localizedDescription);
    
    DDLogInfo(@"## %d media infos in database", _mediaFrc.fetchedObjects.count);
    
    if (_mediaFrc.fetchedObjects.count == 0)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
        
            [WTStatusBar setStatusText:NSLocalizedString(@"no media files to download", @"") timeout:5 animated:YES];
        });
            
        return;
    }
    
    [[self operationQueue] setMaxConcurrentOperationCount:10];
    
    indexPathRow = 0;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [WTStatusBar setStatusText:NSLocalizedString(@"checking references and downloading media files...", @"") animated:YES];
        [WTStatusBar setProgressBarColor:[UIColor orangeColor]];
    });

    self.isMediaDownloadActive = YES;
    
    [self enqueueOperations];
}

- (void)cancelMediaDownload
{
    [[self operationQueue] cancelAllOperations];

    if (!self.isSynchronisationRunning) //Es kann zu abstürzen kommen wenn ein Import läuft und der Context dabei gespeichert wird.
    {
        [self save];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [WTStatusBar clearStatusAnimated:YES];
    });
    
    self.isMediaDownloadActive = NO;
}

- (void)enqueueOperations
{
    int maxOperations = [[self operationQueue] maxConcurrentOperationCount];
    
    while ([[self operationQueue] operationCount] < maxOperations && indexPathRow < _mediaFrc.fetchedObjects.count)
    {
        AFImageRequestOperation *operation = [self getNextMediaWithIndex:indexPathRow];
        
        if (operation)
        {
            [[SAGSyncManager sharedClient] enqueueBatchOfHTTPRequestOperations:@[operation] progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
                
            } completionBlock:^(NSArray *operations) {
            
                [self enqueueOperations];
            }];
        }
        
        CGFloat progress = (float)indexPathRow / (float)_mediaFrc.fetchedObjects.count;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [WTStatusBar setProgress:progress animated:YES];
        });
        
        
        NSError *error;
        
        [_mediaFrc.managedObjectContext save:&error];
        
        if (error) DDLogError(@"%@", error.localizedDescription);
        
        indexPathRow++;
    }
    
    if (indexPathRow == _mediaFrc.fetchedObjects.count)
    {
        NSError *error;
        
        [_mediaFrc.managedObjectContext save:&error];
        
        if (error) DDLogError(@"%@", error.localizedDescription);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [WTStatusBar setStatusText:NSLocalizedString(@"media download complete", @"") timeout:5 animated:YES];
        });
        
        [self save]; //Speichern was wir geholt haben...
        
        self.isMediaDownloadActive = NO;
        
        DDLogInfo(@"## media download complete");
        
        _mediaFrc = nil;
    }
}

- (AFImageRequestOperation *)getNextMediaWithIndex:(NSUInteger)index
{
     NSString *mediaDownloadPath = [[SAGSettingsManager sharedManager] mediaDownloadPath];

    if (index < _mediaFrc.fetchedObjects.count)
    {
        SBMedia *media = [_mediaFrc objectAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        
        media.isDownloaded = [NSNumber numberWithBool:[media isAlreadyDownloaded]];
        
        if (!media.isDownloaded.boolValue)
        {
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"%@/%@", mediaDownloadPath, [media.fullFilename stringByAddingPercentEscapesUsingEncoding:NSISOLatin1StringEncoding]]]];
            
            [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
            
            return [self downloadMediaWithRequest:request outputURL:[media mediaBaseURLWithFullFilename] andManagedObjectID:media.objectID];
        }
        else
        {
            NSError *error;
            
            [_mediaFrc.managedObjectContext save:&error];
            
            if (error) DDLogError(@"%@", error.localizedDescription);
        }
    }
    
    return nil;
}

- (AFImageRequestOperation *)downloadMediaWithRequest:(NSURLRequest *)request outputURL:(NSURL *)fileURL andManagedObjectID:(NSManagedObjectID *)objectID;
{
    AFImageRequestOperation *imageRequestOperation = [AFImageRequestOperation imageRequestOperationWithRequest:request
                                                                                          imageProcessingBlock:^UIImage *(UIImage *image)
                                                      {
                                                          return image; //Hier können wir keine und mittlere Bilder ableiten!
                                                      }
                                                                                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
                                                      {
                                                          if (![[SAGLoginManager sharedManger] isDatabaseOpen]) return;
                                                          
                                                          SBMedia *media = (SBMedia *)[_mediaFrc.managedObjectContext objectWithID:objectID];

                                                          media.isDownloaded = [NSNumber numberWithBool:[media isMediaValid]];
                                                        
                                                          if (media.isDownloaded.boolValue) [media copyToUserMedia];
                                                      }
                                                                                                       failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
                                                      {
                                                          if (![error code] == NSURLErrorCancelled)
                                                          {
                                                              DDLogError(@"%@", [NSString stringWithFormat:@"BAD MEDIA REQUEST: %@ WITH ERROR: %@", [fileURL lastPathComponent], error.localizedDescription]);
                                                              [SBMedia deleteMediaFile:[fileURL path]]; // Bei Fehlversuchen die fehlerhaften Daten löschen
                                                          }
                                                      }];
    
    [imageRequestOperation setOutputStream:[NSOutputStream outputStreamWithURL:fileURL append:NO]];
    
    return imageRequestOperation;
}

#pragma mark - Webservice Verarbeiten

- (void)getUpdatesFromClass:(NSString *)className withTimeStamp:(NSString *)timestamp andRecordID:(NSString *)recordID andBlockSize:(NSString *)blockSize andDataBlock:(NSString *)dataBlock forWebservice:(NSString *)webservice //Die Daten herunterladen und ErrorHandling
{
    //Requeststring erzeugen
    NSString *requestString = [self getURLTemplateForWebservice:webservice
                                                   withTimeStamp:timestamp
                                                    andRecordID:recordID
                                                   andBlocksize:blockSize];
    
    if ([_delegate respondsToSelector:@selector(syncManagerLocalizedTaskNameChanged:)])
    {
        [_delegate performSelectorOnMainThread:@selector(syncManagerLocalizedTaskNameChanged:)
                                    withObject:[NSString stringWithFormat:@"%@ %@...", NSLocalizedString(@"Synchronizing", @"Synchronizing"),[NSClassFromString(className) performSelector:@selector(localizedClassName)]] waitUntilDone:YES]; //Delegte informieren
    }
    
#if TARGET_IPHONE_SIMULATOR 
    NSLog(@"=> %@", requestString); //Im Simulator wird immer die URL ausgegeben...
#endif
    
 NSDate *startFetch = [NSDate date];
    
    NSURL *url = [NSURL URLWithString:requestString];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];

    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                         
      success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        if ([self isResponseSuccessful:[JSON valueForKeyPath:@"ResponseData"]]) //Prüfen ob das Ergebnis verwendet werden darf.
        {
            DDLogInfo(@"Data recived in %@", [NSString stringAsDetailedTimeSinceDate:startFetch]);
            NSDate *startInit = [NSDate date];

            NSArray *response = [JSON valueForKeyPath:dataBlock]; //Datenbereich aus der Response weiterverarbeiten

            int errorCount = 0;

            if (!response)
            {
                 [self addErrorWithMessage:[NSString stringWithFormat:@"DataBlock %@ in %@ is missing!", dataBlock, className] andUserInfo:[NSDictionary dictionaryWithObject:@"E" forKey:@"Errorlevel"]];
            }
            
            if ([NSClassFromString(className) respondsToSelector:NSSelectorFromString(@"shouldRemoveDataBeforeImport")]) //Gemacht für Webservices die immer alles Daten liefern! Erst hier kann man sicher sein, das auch Daten gekommen sind und die alten Daten wegwerfen!
            {
                BOOL delete = [NSClassFromString(className) performSelector:@selector(shouldRemoveDataBeforeImport) withObject:nil];
                
                if (delete && [NSClassFromString(className) isSubclassOfClass:[NSManagedObject class]])
                {
                    [NSClassFromString(className) MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"uniqueID != nil"]];
                }
            }
            
            
#if TARGET_IPHONE_SIMULATOR //USE GDC TO SPEED UP TEST -> NOTICE: SOME ERROR HANDLING FUNCTIONS MAY NOT WORK PROPERLY!
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                
                @autoreleasepool
                {
                    for (NSDictionary *data in response)
                    {
                        if ([data isEqual:[NSNull null]]) //Dieser Fehler ist bei einem Webservice aufgetreten und wird daher als potenzieller Fehler überall abgefangen!
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                [self addErrorWithMessage:[NSString stringWithFormat:@"Response contains NULL object!"] andUserInfo:[NSDictionary dictionaryWithObject:@"E" forKey:@"Errorlevel"]];
                            });
                        }
                        else //Update durchführen
                        {
                            [NSClassFromString(className) performSelector:@selector(updateDocumentFromDictionary:) withObject:data];
                        }
                    }
                }
                
                [self save];
            });
            
#else
            
            @autoreleasepool
            {
                for (NSDictionary *data in response)
                {
                    if ([data isEqual:[NSNull null]]) //Dieser Fehler ist bei einem Webservice aufgetreten und wird daher als potenzieller Fehler überall abgefangen!
                    {
                        [self addErrorWithMessage:[NSString stringWithFormat:@"Response contains NULL object!"] andUserInfo:[NSDictionary dictionaryWithObject:@"E" forKey:@"Errorlevel"]];
                        errorCount++;
                    }
                    else if (![NSClassFromString(className) performSelector:@selector(updateDocumentFromDictionary:) withObject:data]) //Update durchführen
                    {
                        errorCount ++;
                    }
                }
            }
            
#endif
            
             NSDictionary *lastObject = [response lastObject];

             if (lastObject) //Timestamp und RecordID sichern
             {
                 newTimeStamp = [[lastObject valueForKey:[NSClassFromString(className) performSelector:@selector(webserviceTransferDate)]] fromISO8601FormatedString];
                 newRecordID = [lastObject valueForKey:@"recordID"];
             }

             DDLogInfo(@"Data processed in %@", [NSString stringAsDetailedTimeSinceDate:startInit]);

             if ([newTimeStamp.asISO8601FormattedString isEqualToString:timestamp] && [newRecordID.stringValue isEqualToString:recordID] && blockSize.intValue == response.count) //Loop detector
             {
                 NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:recordID, @"recordID", timestamp, @"timeStamp", webservice, @"webservice", @"E", @"Errorlevel", nil];
                 [self addErrorWithMessage:[NSString stringWithFormat:@"%@ (%@)", NSLocalizedString(@"Loop detected! Continue with next step!", @"SAGSyncManager loop detector!"), recordID] andUserInfo:dict];
             }
             else //Kein Loop...
             {
                 importNumberOfObjects = importNumberOfObjects + response.count;

                 [SBWebserviceInfo setTimestamp:newTimeStamp andRecordID:newRecordID forWebservice:webservice];

                 if (response.count == 0 && importNumberOfObjects == 0)
                 {
                     [self addErrorWithMessage:NSLocalizedString(@"...already up-to-date!", @"") andUserInfo:nil]; //Wenn kein einziger Datensatz empfangen wurde....
                 }
                 else if (errorCount == response.count && errorCount) //Wenn kein einziger Datensatz erfolgreicht upgedatet wurde....
                 {
                     [self addErrorWithMessage:NSLocalizedString(@"...any update failed!", @"") andUserInfo:[NSDictionary dictionaryWithObject:@"E" forKey:@"Errorlevel"]];
                 }
                 else if (response.count == [blockSize intValue]) //Prüfen ob wiederholt gefetched werden muss...
                 {
                     [self lifoQueueAddStepWithClass:className andTimeStamp:[newTimeStamp asISO8601FormattedString] andRecordID:[newRecordID stringValue] andBlockSize:blockSize andDataBlock:dataBlock forWebservice:webservice]; //Es muss ein weiterer Fetch durchgeführt werden...
                 }
                 else
                 {
                     [self webserviceDone]; //Sichern und weiter....
                 }
             }
         }
         else
         {
             [self addErrorWithMessage:NSLocalizedString(@"...response not successful!", @"") andUserInfo:[JSON valueForKeyPath:@"ResponseData"]]; //Wenn kein einziger Datensatz empfangen wurde....
         }
         
         continueCounter = kRetryCounter; //Wenn die Verbindung abbricht, dann muss man x mal wiederholen bis die Sync beendet wird!
         
         [self lifoQueueNextStep]; //Weiter gehts....
          
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        
        //Es trat ein Verbindungs Problem auf...
         NSMutableDictionary *userInfo = [NSMutableDictionary new]; //Alle diese Werte werden an den mCube übermittelt, aber nur Strings rein machen!
         [userInfo setValue:webservice forKey:@"webservice"];
         [userInfo setValue:className forKey:@"className"];
         [userInfo setValue:timestamp forKey:@"timeStamp"];
         [userInfo setValue:recordID forKey:@"recordID"];
         [userInfo setValue:blockSize forKey:@"blockSize"];
         [userInfo setValue:[[SAGLoginManager sharedManger] username] forKey:@"username"];
         [userInfo setValue:self.deviceID forKey:@"deviceID"];
         [userInfo setValue:[[SAGLoginManager sharedManger] serverURL] forKey:@"mCube"];
        [userInfo setValue:[[NSNumber numberWithInt:response.statusCode] stringValue] forKey:@"HTTP-StatusCode"];
         [userInfo setValue:[[NSNumber numberWithInt:error.code] stringValue] forKey:@"ErrorCode"];
         [userInfo setValue:error.domain forKey:@"ErrorDomain"];
         [userInfo setValue:[error.userInfo valueForKey:@"NSLocalizedDescription"] forKey:@"LocalizedDescription"];
         [userInfo setValue:@"E" forKey:@"Errorlevel"];

         if (response.statusCode == 0) //Inteligentes Error Handling (naja fast) -> Muss noch vieles gemacht werden
         {
             switch (error.code)
             {
                 case -1001:
                 case -1103:
                 {
                     [self lifoQueueAddStepWithClass:className andTimeStamp:timestamp andRecordID:recordID andBlockSize:[self getReducedBlocksize:blockSize] andDataBlock:dataBlock forWebservice:webservice]; //Es muss ein weiterer Fetch durchgeführt werden...
                 }
                     break;
                 case -1004:
                 case -1005:
                 case -1009:
                 {
                     [self addErrorWithMessage:NSLocalizedString(@"No InternetConnection => Synchronisation paused!", @"") andUserInfo:userInfo];
                     [self lifoQueueAddStepWithClass:className andTimeStamp:timestamp andRecordID:recordID andBlockSize:blockSize andDataBlock:dataBlock forWebservice:webservice]; //Es muss ein weiterer Fetch durchgeführt werden...
                     [self lifoQueuePause];
                 }
                     break;

                 default:
                     [self addErrorWithMessage:[NSString stringWithFormat:@"No possible recovery known for %d %@!", error.code, error.localizedDescription] andUserInfo:userInfo];
                     break;
             }
         }
         else
         {
             switch (response.statusCode)
             {
                 case 200: //Verbindungsabbruch
                 {
                     [self addErrorWithMessage:NSLocalizedString(@"InternetConnection lost => Synchronisation paused!", @"") andUserInfo:userInfo];
                     [self lifoQueueAddStepWithClass:className andTimeStamp:timestamp andRecordID:recordID andBlockSize:blockSize andDataBlock:dataBlock forWebservice:webservice]; //Es muss ein weiterer Fetch durchgeführt werden...
                     [self lifoQueuePause];
                 }
                     break;
                 case 408: //Timeout...
                     [self lifoQueueAddStepWithClass:className andTimeStamp:timestamp andRecordID:recordID andBlockSize:[self getReducedBlocksize:blockSize] andDataBlock:dataBlock forWebservice:webservice]; //Es muss ein weiterer Fetch durchgeführt werden...
                     break;
                 case 500: //Internal Server Error
                 case 501: //Not Implemented
                 case 502: //Bad Gateway
                 case 503: //Service Unavailable
                 case 504: //Gateway Timeout
                 case 505: //HTTP Version Not Supported
                 case 506: //Variant Also Negotiates
                 case 507: //Insufficent Storage
                 case 509: //Bandwidth Limit Exceeded
                 case 510: //Not Extended
                 {
                     [self addErrorWithMessage:[NSString stringWithFormat:@"%d %@", response.statusCode, NSLocalizedString(@" - Error occured => Synchronisation aborted!", @"")] andUserInfo:userInfo];
                     [self lifoQueueAbort];
                 }
                     break;
                 default:
                     [self addErrorWithMessage:[NSString stringWithFormat:@"%@ %d", NSLocalizedString(@"No possible recovery known!", @""), response.statusCode] andUserInfo:userInfo];
                     break;
             }
         }
         
         if (self.isSynchronisationPaused == NO)
         {
             [self lifoQueueNextStep]; //Weiter gehts....
         }
    }];
    
    [operation start];
}

- (void)webserviceDone
{    
    if (importNumberOfObjects > 0)
    {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:lastObject, @"className", lastWebservice, @"webservice", [newTimeStamp asISO8601FormattedString], @"newTimestamp", [newRecordID stringValue], @"newRecordID", [NSString stringAsTimeSinceDate:webserviceStart], @"duration", nil];
        
        if ([lastTimestamp isEqualToString:[[NSDate minimumUnixDate] asISO8601FormattedString]]) //Timestamp beim initalen laden auch für den deleteWebservice sichern...
        {
            NSString *deleteWebservice = [NSClassFromString(lastObject) performSelector:@selector(webserviceDelete)];
            
            if (deleteWebservice != nil)
            {
                if (![deleteWebservice isEqualToString:lastWebservice])
                {
                    DDLogInfo(@"%@", [NSString stringWithFormat:@"Initial timestamp of %@ was set to %@", deleteWebservice, newTimeStamp]);
                    [SBWebserviceInfo setTimestamp:newTimeStamp andRecordID:[NSNumber numberWithInt:0] forWebservice:deleteWebservice];
                }
            }
        }
        
        id obj = NSClassFromString(lastObject);
        
        if ([obj respondsToSelector:@selector(renewReferences)]) //Referenzen erneuern
        {
            [obj performSelector:@selector(renewReferences)];
            
            [self addErrorWithMessage:[NSString stringWithFormat:@"...renew references..."] andUserInfo:nil];
        }
        
        [self addErrorWithMessage:[NSString stringWithFormat:@"...finished with %d changes!", importNumberOfObjects] andUserInfo:userInfo];
    }
    
    [self save]; //Speichern was wir bisher geholt haben...
}

#pragma mark - LIFOQueue

- (void)lifoQueueLoadObjectsFromArray:(NSArray *)objectsArray andStart:(BOOL)boolValue //Die LIFO Queue mit Objekten befüllen
{
    [_lifoQueue removeAllObjects]; //Die aktuelle Queue leeren
    
    for (NSString *className in objectsArray)
    {
        if ([self isClassCompatible:className]) //Objekte in Queue stecken
        {
            NSString *updateWebservice = [NSClassFromString(className) performSelector:@selector(webserviceUpdate)];
            NSString *deleteWebservice = [NSClassFromString(className) performSelector:@selector(webserviceDelete)];
            
            NSString *lastTimeStamp = [SBWebserviceInfo getTimestampForWebservice:updateWebservice];
            
            NSString *blockSize = [NSClassFromString(className) performSelector:@selector(webserviceBlockSize)];
            
            if (![lastTimeStamp isEqualToString:[[NSDate minimumUnixDate] asISO8601FormattedString]] && deleteWebservice) //Wenn bereits Daten in der DB vorhanden sind und es einen Löschwebservcie gibt!
            {
                [self lifoQueueAddStepWithClass:className //Auch den Löschwebservice aufgerufen!
                                   andTimeStamp:[SBWebserviceInfo getTimestampForWebservice:deleteWebservice]
                                    andRecordID:[SBWebserviceInfo getRecordIDForWebservice:deleteWebservice]
                                   andBlockSize:blockSize
                                   andDataBlock:[NSClassFromString(className) performSelector:@selector(webserviceDataBlockDeleted)]
                                  forWebservice:deleteWebservice];
            }
            
            [self lifoQueueAddStepWithClass:className //Aktuell aktive Daten vom mCube holen!
                               andTimeStamp:lastTimeStamp
                                andRecordID:[SBWebserviceInfo getRecordIDForWebservice:updateWebservice]
                               andBlockSize:blockSize
                               andDataBlock:[NSClassFromString(className) performSelector:@selector(webserviceDataBlock)]
                              forWebservice:updateWebservice];
        }
    }
    
    lifoNumberOfTasks = _lifoQueue.count;
    
    if (boolValue)
    {
        [self lifoQueueNextStep]; //Los gehts....
    }
}

- (void)lifoQueueAddStepWithClass:(NSString *)className andTimeStamp:(NSString *)timeStamp andRecordID:(NSString *)recordID andBlockSize:(NSString *)blockSize andDataBlock:(NSString *)dataBlock forWebservice:(NSString *)webservice //Eine neue Aufgabe für die Verarbeitung vorbereiten
{
    if (!webservice) //Ohne Webservice kein Eintrag in der Queue
    {
        DDLogWarn(@"** SyncManager: Webservice for Class %@ is missing!", className);
        return;
    }
    
    if (!blockSize) //Ohne Blocksize kein Eintrag in der Queue
    {
        DDLogWarn(@"** SyncManager: Blocksize for Class %@ is missing!", className);
        return;
    }
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:className, @"className", timeStamp, @"timeStamp", recordID, @"recordID", webservice, @"webservice", blockSize, @"blockSize", dataBlock, @"dataBlock", nil]; //Ein Objekt der Queue hinzufügen
    
    [_lifoQueue insertObject:dict atIndex:0];
}

- (void)lifoQueueNextStep //Nächste Anweisung ausführen
{
    float progress = 1 - _lifoQueue.count / lifoNumberOfTasks;
    
    [_delegate performSelectorOnMainThread:@selector(syncManagerUpdateProgressValue:) withObject:[NSNumber numberWithFloat:progress] waitUntilDone:YES]; //Status Aktualisieren
    
    if ([_delegate respondsToSelector:@selector(syncManagerLocalizedTaskStatusChanged:)])
    {
        if (importNumberOfObjects == 0)
        {
            [_delegate performSelectorOnMainThread:@selector(syncManagerLocalizedTaskStatusChanged:) withObject:@"" waitUntilDone:YES]; //Status Aktualisieren
        }
        else
        {
            [_delegate performSelectorOnMainThread:@selector(syncManagerLocalizedTaskStatusChanged:) withObject:[[NSNumber numberWithInt:importNumberOfObjects] stringWithLocalizedNumberStyle] waitUntilDone:YES]; //Status Aktualisieren
        }
    }
    
    if (_lifoQueue.count == 0)
    {
        [self SynchronizationDone]; //Wenn nichts mehr in der Queue steht ist die Synchronisation zu Ende
        return;
    }
    
    NSDictionary *dict = [_lifoQueue objectAtIndex:0]; //Objekt für den nächsten Schritt....
    
    [_lifoQueue removeObjectAtIndex:0];
    
    if (importNumberOfObjects != 0) //Zwischendurch immer wieder speichern was wir geholt haben!
    {
        [self save];
    }
    
    if (![lastWebservice isEqualToString:[dict valueForKey:@"webservice"]])
    {
        webserviceStart = [NSDate date]; //Zeit festhalten....
        
        lastObject = [dict valueForKey:@"className"];
        lastWebservice = [dict valueForKey:@"webservice"];
        lastTimestamp = [dict valueForKey:@"timeStamp"];
        
        importNumberOfObjects = 0;
        
        newTimeStamp = nil;
        newRecordID = nil;
        
        if ([_delegate respondsToSelector:@selector(syncManagerLocalizedTaskStatusChanged:)])
        {
            [_delegate performSelectorOnMainThread:@selector(syncManagerLocalizedTaskStatusChanged:) withObject:@"" waitUntilDone:YES]; //Status Aktualisieren
        }
        
        NSString *info = NSLocalizedString(@"Updating", @"synchronizingWebservice");
        
        if ([lastWebservice isEqualToString:[NSClassFromString([dict valueForKey:@"className"]) webserviceDelete]])
        {
            info = NSLocalizedString(@"Removing", @"DeleteWebservice");
        }
        
        [self addErrorWithMessage:[NSString stringWithFormat:@"%@ %@...", info, [NSClassFromString([dict valueForKey:@"className"]) localizedClassName]] andUserInfo:dict];
    }
    else
    {
        DDLogInfo(@"** SyncManager: Fetch next %d %@s... (%@)", [[dict valueForKey:@"blockSize"] intValue], [dict valueForKey:@"className"], [dict valueForKey:@"recordID"]);
    }
    
    @autoreleasepool
    {
        [self getUpdatesFromClass:[dict valueForKey:@"className"]
                    withTimeStamp:[dict valueForKey:@"timeStamp"]
                      andRecordID:[dict valueForKey:@"recordID"]
                     andBlockSize:[dict valueForKey:@"blockSize"]
                     andDataBlock:[dict valueForKey:@"dataBlock"]
                    forWebservice:[dict valueForKey:@"webservice"]];
    }
}

- (void)lifoQueueWakeUpFromNotification:(NSNotification *)notification //Nach Verbindungsverlust die Synchronisation fortsetzen
{
    
    AFNetworkReachabilityStatus status = [notification.object intValue];
    
    switch (status) {
        case AFNetworkReachabilityStatusReachableViaWiFi:
            _connectionState = SAGConnectionStateWLAN;
            break;
        case AFNetworkReachabilityStatusReachableViaWWAN:
            _connectionState = SAGConnectionStateMobile;
            break;
        default:
            _connectionState = SAGConnectionStateNotConnected;
            break;
    }
    
    if (status == AFNetworkReachabilityStatusReachableViaWiFi || status == AFNetworkReachabilityStatusReachableViaWWAN || [notification.object intValue] == AFNetworkReachabilityStatusUnknown)
    {
        if (self.isSynchronisationRunning && self.isSynchronisationPaused)
        {
            if ([notification.object intValue] != AFNetworkReachabilityStatusUnknown)
            {
                [self addErrorWithMessage:NSLocalizedString(@"Network appears to be back again! Try to continue sync...", @"") andUserInfo:nil];
            }
            else
            {
                [self addErrorWithMessage:NSLocalizedString(@"Try to continue sync...", @"") andUserInfo:[NSDictionary dictionaryWithObject:@"W" forKey:@"Errorlevel"]];
            }
            
            self.isSynchronisationPaused = NO;
            
            [self lifoQueueNextStep]; //Weiter gehts...
        }
    }
}

- (void)lifoQueuePause
{
    if ([_delegate respondsToSelector:@selector(syncManagerLocalizedTaskNameChanged:)])
    {
        [_delegate performSelectorOnMainThread:@selector(syncManagerLocalizedTaskNameChanged:) withObject:NSLocalizedString(@"Synchronization paused!", @"Synchronization paused") waitUntilDone:YES]; //Delegte informieren
    }
    
    self.isSynchronisationPaused = YES; //Synchronisation pausieren
    
    continueCounter--;
    
    if (continueCounter == 0)
    {
        [_delegate performSelectorOnMainThread:@selector(syncManagerSetContinueButtonText:) withObject:NSLocalizedString(@"Cancel", @"SyncManger Cancelsynchronization") waitUntilDone:YES];
    }
    
    [self save]; //Speichern was wir biher geholt haben...
}

- (void)lifoQueueAbort
{
    if ([_delegate respondsToSelector:@selector(syncManagerLocalizedTaskNameChanged:)])
    {
        [_delegate performSelectorOnMainThread:@selector(syncManagerLocalizedTaskNameChanged:) withObject:NSLocalizedString(@"Synchronization aborted!", @"Synchronization aborted") waitUntilDone:YES]; //Delegte informieren
    }
    
    [_lifoQueue removeAllObjects]; //Synchronisation abbrechen
    
    _mediaFrc = nil;
    
    self.isSynchronisationRunning = NO;
}

#pragma mark - UIStuff

- (void)showSyncManagerUI
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
    SyncManagerViewController *syncManagerVC = [storyboard instantiateViewControllerWithIdentifier:@"SyncManagerUI"];
    syncManagerVC.modalPresentationStyle = UIModalPresentationFormSheet;
    syncManagerVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    [[[UIApplication sharedApplication] delegate].window.rootViewController presentViewController:syncManagerVC animated:YES completion:^{
        
        self.isSyncManagerUIVisible = YES;
        DDLogInfo(@"Present SyncManagerUI!");
    }];
}

- (void)hideSyncManagerUI
{
    self.isSyncManagerUIVisible = NO;
    
    int maxConncurrentOperations = [[[SAGSettingsManager sharedManager] settingForKey:@"MaxNoOfConcurrentImageDownloadOperations" withDefaultValue:[NSNumber numberWithInt:1]] intValue];
    
    [[self operationQueue] setMaxConcurrentOperationCount:maxConncurrentOperations];
}

#pragma mark - Internal Stuff

- (void)setIsMediaDownloadPaused:(BOOL)isMediaDownloadPaused
{
    if (!self.isMediaDownloadActive) isMediaDownloadPaused = NO;
    
    if (self.isMediaDownloadActive)
    {
        if (self.isMediaDownloadPaused)
        {
            dispatch_async(dispatch_get_main_queue(), ^{

                [WTStatusBar clearStatusAnimated:YES];
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{

                [WTStatusBar setStatusText:NSLocalizedString(@"loading media files...", @"loading media") animated:YES];
            });
        }
    }
    
    _isMediaDownloadPaused = isMediaDownloadPaused;
    
    [[self operationQueue] setSuspended:_isMediaDownloadPaused];
    
    if (self.isMediaDownloadPaused)
    {
        NSError *error;
        
        [_mediaFrc.managedObjectContext save:&error];
        
        if (error) DDLogError(@"%@", error.localizedDescription);
        
        [self save]; //Speichern was wir biher geholt haben...
    }
}

- (void)setIdleTimerDisabled:(BOOL)yesNo
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:yesNo]; //Standby umschalten
}

- (void)setIsSynchronisationRunning:(BOOL)isSynchronisationRunning //Den SyncStatus ändern
{
    _isSynchronisationRunning = isSynchronisationRunning;
    
    if (self.isMediaDownloadActive) [self cancelMediaDownload];
    
    [_delegate performSelectorOnMainThread:@selector(syncManagerIsSynchronisationRunning:)
                                withObject:[NSNumber numberWithBool:_isSynchronisationRunning]
                             waitUntilDone:YES];
    
    [self setIdleTimerDisabled:_isSynchronisationRunning]; //Standby umschalten
}

- (void)setIsSynchronisationPaused:(BOOL)isSynchronisationPaused //Den SyncStatus ändern
{
    _isSynchronisationPaused = isSynchronisationPaused;
    
    [_delegate performSelectorOnMainThread:@selector(syncManagerIsSynchronisationPaused:)
                                withObject:[NSNumber numberWithBool:_isSynchronisationPaused]
                             waitUntilDone:YES];
}

- (void)setIsMediaDownloadActive:(BOOL)isMediaDownloadActive
{
    _isMediaDownloadActive = isMediaDownloadActive;
    
    if (isMediaDownloadActive == NO) _isMediaDownloadPaused = NO; //Pause aufheben...
    
    if (!self.isSynchronisationRunning)
    {
        [self setIdleTimerDisabled:_isMediaDownloadActive]; //Standby umschalten
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationMediaDownloadStateChanged object:[NSNumber numberWithBool:_isMediaDownloadActive]];
    });
}

#pragma mark - Internal Webservice Stuff

- (NSString *)getURLTemplateForWebservice:(NSString *)webserviceName withTimeStamp:(NSString *)timeStamp andRecordID:(NSString *)recordID andBlocksize:(NSString *)blocksize; //Webservice URL Template zusammensetzen
{
    NSString *urlTemplate = [NSString stringWithFormat:@"%@/Aservice/AjaxService.svc/%@/%@/%@/%@/%@/%@/%@/%@/%@", [[SAGLoginManager sharedManger] serverURL], webserviceName, self.deviceID, [[SAGLoginManager sharedManger] username], [[SAGLoginManager sharedManger] password], self.deviceLanguage, self.versionString, timeStamp, recordID, blocksize];
    
    return urlTemplate;
}

- (NSString *)getLastTimeStampForClass:(NSString *)className //Letzten TimeStamp ermitteln (wird nicht verwendet)!
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:className];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"documentState == %@", [NSNumber numberWithInt:SAGDocumentStateCommited]]];
    [request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"transferDate" ascending:NO]]];
    [request setFetchLimit:1];
    
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    
    __block NSArray *results = nil;
    [context performBlockAndWait:^{
        
        NSError *error = nil;
        
        results = [context executeFetchRequest:request error:&error];
        
        if (results == nil)
        {
            [MagicalRecord handleErrors:error];
        }
        
    }];

    if ([results count] == 0)
	{
		return [[NSDate minimumUnixDate] asISO8601FormattedString]; //Initiales Datum zurückgeben
	}
    
	return [[[results objectAtIndex:0] performSelector:@selector(transferDate)] asISO8601FormattedString]; //Ermittelten Timestamp zurückgeben
}

- (BOOL)isResponseSuccessful:(NSDictionary *)dict //MCube Meldungen ausgeben
{
    if ([[dict valueForKeyPath:@"ResponseErrorLevel"] isEqualToString:@"E"])
    {
        [self addErrorWithMessage:[NSString stringWithFormat:@"Errormessage from mCube: %@", [dict valueForKeyPath:@"ResponseText"]] andUserInfo:[NSDictionary dictionaryWithObject:@"E" forKey:@"Errorlevel"]];
    }
    else if ([[dict valueForKeyPath:@"ResponseErrorLevel"] isEqualToString:@"W"])
    {
        [self addErrorWithMessage:[NSString stringWithFormat:@"Warning from mCube: %@", [dict valueForKeyPath:@"ResponseText"]] andUserInfo:[NSDictionary dictionaryWithObject:@"W" forKey:@"Errorlevel"]];
    }
    else
    {
        DDLogInfo(@"** SyncManager: Info from mCube: %@", [dict valueForKeyPath:@"ResponseText"]);
    }
    
    if ([[dict valueForKeyPath:@"ResponseCode"] intValue] == SAGResponseCodeSuccess)
    {
        return YES;
    }
    
    return NO;
}

- (BOOL)isClassCompatible:(NSString *)className //Prüfen ob zu Synchronisierende Klasse alle notwendigen Methoden hat
{
    //Prüfen ob alle im SynManager verwendeten Funktionen von der Klasse unterstützt werden
    NSArray *nececarySelectors = [NSArray arrayWithObjects:@"webserviceUpdate", @"webserviceDelete", @"webserviceUniqueID", @"webserviceTransferDate", @"webserviceBlockSize", @"webserviceDataBlock", @"webserviceDataBlockDeleted", @"updateDocumentFromDictionary:", @"webserviceActionState", @"localizedClassName", nil];
    
    bool returnValue = YES;
    
    for (NSString *aSelector in nececarySelectors)
    {
        if (![NSClassFromString(className) respondsToSelector:NSSelectorFromString(aSelector)])
        {
            [self addErrorWithMessage:[NSString stringWithFormat:@"%@ does not respond to obligatory selector %@!", className, aSelector] andUserInfo:nil];
            returnValue = NO;
        }
    }
    
    return returnValue;
}

- (NSString *)getReducedBlocksize:(NSString *)currentBlocksize //Blockgröße bei Timeout anpassen
{
    //Hier wird bei Timeouts versucht einfach weniger Daten auzufordern
    NSArray *possibleBlockSizes = [NSArray arrayWithObjects:@"20000", @"10000", @"5000", @"2500", @"1000", @"500", @"250", @"100", @"50", nil]; //Mögliche Blocksizes
    
    for (NSString *possibleNewSize in possibleBlockSizes)
    {
        if ([currentBlocksize intValue] > [possibleNewSize intValue])
        {
            DDLogInfo(@"** SyncManager: Timeout? => Try to reduce Blocksize to %@", possibleNewSize);
            return possibleNewSize; //Neu Blocksize
            break;
        }
    }
    
    DDLogInfo(@"** SyncManager: Timeout? => giving up");
    
    return nil;
}

- (NSString *)getSysInfoByName:(char *)typeSpecifier
{
    size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    
    char *answer = malloc(size);
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
    
    NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
    
    free(answer);
    return results;
}

- (NSString *)platform
{
    return [self getSysInfoByName:"hw.machine"];
}


- (NSString *)hwmodel
{
    return [self getSysInfoByName:"hw.model"];
}

- (NSNumber *)freeDiskSpace
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [fattributes objectForKey:NSFileSystemFreeSize];
}

- (NSString *)deviceLanguage //Sprache ermitteln
{
    return [[NSLocale preferredLanguages] objectAtIndex:0];
}

- (NSString *)deviceID //MAC Adresse der WLAN Karte als UUID benutzen (MD5 Verschlüsselt)
{
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Error: Memory allocation error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2\n");
        free(buf); // Thanks, Remy "Psy" Demerest
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    
    free(buf);
    return [outstring stringAsMD5];
}

- (NSString *)versionString
{
    NSString *originalString = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    NSMutableString *strippedString = [NSMutableString
                                       stringWithCapacity:originalString.length];
    
    NSScanner *scanner = [NSScanner scannerWithString:originalString];
    NSCharacterSet *numbers = [NSCharacterSet
                               characterSetWithCharactersInString:@"0123456789"];
    
    while ([scanner isAtEnd] == NO)
    {
        NSString *buffer;
     
        if ([scanner scanCharactersFromSet:numbers intoString:&buffer])
        {
            [strippedString appendString:buffer];
            
        }
        else
        {
            [scanner setScanLocation:([scanner scanLocation] + 1)];
        }
    }
        
    return strippedString;
}

#pragma mark - automatisch speichern

- (void)saveShoppingCart:(NSNotification *)notification
{
    if (notification.object)
    {
        [self saveForTransfer:notification.object];
    }
    else
    {
        DDLogError(@"### TQ: SAVE SHOPPING CART TO TRANSFERQUEUE ERROR!");
    }
}

#pragma mark - Online export

- (void)push:(NSManagedObject *)object
{
    NSData *xmlData = [object getXMLforDelete:NO];
    
    if (xmlData == nil)
    {
        DDLogError(@"### TQ: ERROR: Can´t push object %@", object.objectID);
        return;
    }
    
    NSURLRequest *request = [self getPOSTWithServer:[[SAGLoginManager sharedManger] serverURL] andData:xmlData];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess: ^(AFHTTPRequestOperation *operation, id responseObject) {
    
        DDLogInfo(@"### TQ: PUSH SUCCESS: %@", object.objectID);
        
        [SAGHelper playSound:@"ka-ching" withExtension:@"wav"]; //SalesBook Sound
    
        [self updateTransferState:SAGTransferStateDelivered withObject:object];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DDLogError(@"### TQ: PUSH ERROR: %@", error.localizedDescription);
        
        [self writeXMLData:xmlData withFileName:[object valueForKey:@"uniqueID"]]; //Save for batch processing...
        
        [self updateTransferState:SAGTransferStateQueued withObject:object];
    }];
    
    [operation start];
}

- (void)prepareForDelete:(NSManagedObject *)object
{
    NSData *xmlData = [object getXMLforDelete:YES];
    
    if (xmlData == nil)
    {
        DDLogError(@"### TQ: ERROR: Can´t delete object %@", object.objectID);
        return;
    }
    
    [self writeXMLData:xmlData withFileName:[object valueForKey:@"uniqueID"]];
    
    [object MR_deleteEntity];
    [self save];
}

- (void)saveForTransfer:(NSManagedObject *)object
{
    NSData *xmlData = [object getXMLforDelete:NO];
    
    if (xmlData == nil)
    {
        DDLogError(@"### TQ: ERROR: Can´t save object %@", object.objectID);
        return;
    }
    
    [self writeXMLData:xmlData withFileName:[object valueForKey:@"uniqueID"]]; //Save for batch processing...
    
    [self updateTransferState:SAGTransferStateQueued withObject:object];
}

- (void)updateTransferState:(enum SAGTransferState)transferState withObject:(NSManagedObject *)object
{
    if ([object respondsToSelector:@selector(transferState)])
    {
        [object setValue:[NSNumber numberWithInt:transferState] forKey:@"transferState"];
    }
}

#pragma mark - Offline Export

- (void)refreshApplicationBadge
{
    __block int noOfItems = 0;
    
    [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:[SAGHelper applicationDocumentsDirectory] error:nil] enumerateObjectsUsingBlock:^(NSString *fileName, NSUInteger idx, BOOL *stop) {
        
        if (![fileName isEqualToString:@".DS_Store"] && ![fileName isEqualToString:@"Logs"]) //Ausnahmeliste
        {
            noOfItems++;
        }
    }];
    
    int bageItemsBefore = [[UIApplication sharedApplication] applicationIconBadgeNumber];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:noOfItems];

    if (bageItemsBefore != noOfItems)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationOfflineFilesChanged object:nil];
    }
}

- (void)trySendingFilesInBackground:(bool)inBackground
{
    if (self.isMediaDownloadActive) return;
    if (self.isSynchronisationRunning) return;
    
    NSMutableArray *operations = [NSMutableArray new];
    
    if (!inBackground)
    {
        DDLogInfo(@"### TQ: START FILETRANSFER!");
    }
    
    [self refreshApplicationBadge];
    
    __block int noOfFiles = [[UIApplication sharedApplication] applicationIconBadgeNumber];
    
    for (NSString *fileName in [[NSFileManager defaultManager] enumeratorAtPath:[SAGHelper applicationDocumentsDirectory]])
    {
        NSString *sourceFile = [NSString stringWithFormat:@"%@/%@", [SAGHelper applicationDocumentsDirectory], fileName];
        
        NSData *xmlData = [[NSData alloc] initWithContentsOfFile:sourceFile];
        
        if (xmlData == nil || [fileName isEqualToString:@".DS_Store"])
        {
            continue;
        }
        
        NSString *serverURL = [[SAGLoginManager sharedManger] getServerURLWithFilename:fileName]; //ServerURL aus der FilenameExtension abfragen.
        
        if (serverURL == nil)
        {
            DDLogError(@"### TQ: %@ stays in export folder!\n### Error: %@", fileName, @"ServerURL.info not found!");
            continue;
        }
        
        NSURLRequest *request = [self getPOSTWithServer:serverURL andData:xmlData];
        
        if (inBackground)
        {
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            [operation setCompletionBlockWithSuccess: ^(AFHTTPRequestOperation *operation, id responseObject) {
                
                DDLogInfo(@"### TQ: %@ was succesfully transfered!", fileName);
                
                [[UIApplication sharedApplication] setApplicationIconBadgeNumber:noOfFiles--];
                
                NSError *error;
                
                [[NSFileManager defaultManager] removeItemAtPath:sourceFile error:&error];
                
                if (error)
                {
                    DDLogInfo(@"### TQ: Error: could not remove %@!", fileName);
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                DDLogError(@"### TQ: %@ stays in export folder!\n### Error: %@", fileName, error.localizedDescription);
            }];
            
            [operations addObject:operation];
        }
        else
        {
            NSError *error;
            NSHTTPURLResponse *response;
            
            [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            
            if (error)
            {
                DDLogError(@"### TQ: %@ stays in export folder!\n### Error: %@", fileName, error.localizedDescription);
            }
            else if (response.statusCode == 200)
            {
                DDLogInfo(@"### TQ: %@ was succesfully transfered!", fileName);
                
                [[UIApplication sharedApplication] setApplicationIconBadgeNumber:noOfFiles--];
                
                [[NSFileManager defaultManager] removeItemAtPath:sourceFile error:&error];
            }
        }
    }
    
    if (!inBackground)
    {
        [self refreshApplicationBadge];
        
        DDLogInfo(@"### TQ: SUCCESS DONE!");
        return;
    }
    
    if (operations.count == 0)
    {
        DDLogInfo(@"### TQ: NOTHING TO DO!");
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        
        [WTStatusBar setStatusText:NSLocalizedString(@"uploading files...", @"uploading files") animated:YES];
    });
    
    DDLogInfo(@"### TQ: START FILETRANSFER!");
    
    [self enqueueBatchOfHTTPRequestOperations:operations
                                progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
                                    
                                    CGFloat progress = (float)numberOfFinishedOperations / (float)totalNumberOfOperations;
                                    
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                    
                                        [WTStatusBar setProgress:progress animated:YES];
                                        [WTStatusBar setProgressBarColor:[UIColor orangeColor]];
                                    });
                                    
                                    DDLogInfo(@"### TQ: PROGRESS: %d/%d", numberOfFinishedOperations, totalNumberOfOperations);
                                    
                                } completionBlock:^(NSArray *operations) {
                                  
                                  [self refreshApplicationBadge];
                                  
                                  DDLogInfo(@"### TQ: SUCCESS DONE!");
                                  
                                  [SAGHelper playSound:@"ka-ching" withExtension:@"wav"]; //SalesBook Sound
                                  
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        
                                        [WTStatusBar setStatusText:NSLocalizedString(@"file upload done!", @"file upload done") timeout:3 animated:YES];
                                    });
                              }];
}

- (void)writeXMLData:(NSData *)xmlData withFileName:(NSString *)filename
{
    NSError *fileError;
    
    filename = [NSString stringWithFormat:@"%@.%@", filename, [[SAGLoginManager sharedManger] serverID]];
    
    [xmlData writeToFile:[NSString stringWithFormat:@"%@/%@", [SAGHelper applicationDocumentsDirectory], filename] options:NSDataWritingAtomic error:&fileError]; //Wir schreiben ins Document Directory anders als bei V2!
    
    if (fileError)
    {
        DDLogError(@"### TQ: ERROR: CAN`T WRITE TO FILE: %@", fileError.localizedDescription);
    }
    else
    {
        DDLogInfo(@"### TQ: SUCCESFULL WRITTEN TO FILE: %@", filename);
    }
    
    [self refreshApplicationBadge];
}

- (NSURLRequest *)getPOSTWithServer:(NSString *)serverURL andData:(NSData *)xml
{
    NSString *strURL = [NSString stringWithFormat:@"%@/aservice/SetDataByMobileDevice.aspx", serverURL];
    
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:strURL]];
	[request setHTTPMethod: @"POST"];
    [request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:xml];
    
    return request;
}

- (void)save
{
    __block NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    
    [context MR_saveToPersistentStoreAndWait];
    [context performBlockAndWait:^{
        
        for (NSManagedObject *obj in context.registeredObjects) //Damit beim import nicht ein riessen Memory Overhead anfällt, nach dem Speichern die Objekte refreshen! -> Turn objects into FAULT!
        {
            [context refreshObject:obj mergeChanges:NO];
        }
    }];
}

- (NSDictionary *)sysInfo
{
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    
    [userInfo setValue:[[SAGLoginManager sharedManger] serverURL] forKey:@"serverURL"];
    [userInfo setValue:[self platform] forKey:@"devicePlatform"];
    [userInfo setValue:[self hwmodel] forKey:@"deviceModel"];
    [userInfo setValue:[[UIDevice currentDevice] systemVersion] forKey:@"deviceOSVersion"];
    [userInfo setValue:[[self freeDiskSpace] getHumanReadableFileSize] forKey:@"deviceFreeDiskSpace"];
    
    return userInfo;
}

@end
