//
//  SyncManager.h
//  SalesBook
//
//  Created by Andreas Kucher on 14.12.12.
//  Copyright (c) 2012 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"

#import "SBMedia+Extensions.h"

#import "NSManagedObject+CustomFields.h"

@protocol SAGSyncManagerDelegate <NSObject>

- (void)syncManagerIsSynchronisationRunning:(NSNumber *)isRunnung;
- (void)syncManagerIsSynchronisationPaused:(NSNumber *)isRunnung;
- (void)syncManagerSetContinueButtonText:(NSString *)text;

@optional

- (void)syncManagerUpdateProgressValue:(NSNumber *)progress;
- (void)syncManagerLocalizedTaskNameChanged:(NSString *)text;
- (void)syncManagerLocalizedTaskStatusChanged:(NSString *)text;
- (void)syncManagerLocalizedErrorMessage:(NSAttributedString *)text;

@end

@interface SAGSyncManager : AFHTTPClient 

@property (nonatomic, weak) id  delegate;

@property (nonatomic, readonly) BOOL isSynchronisationRunning;
@property (nonatomic, readonly) BOOL isSynchronisationPaused;
@property (nonatomic, readonly) BOOL isSyncManagerUIVisible;
@property (nonatomic, readonly) BOOL isMediaDownloadActive;
@property (nonatomic, readwrite) BOOL isMediaDownloadPaused;

@property (nonatomic, readonly) int connectionState; //enum SAGConnectionState

@property (nonatomic, readonly) NSMutableArray *lifoQueue;

@property (nonatomic, readonly) NSString *deviceID;
@property (nonatomic, readonly) NSString *deviceLanguage;
@property (nonatomic, readonly) NSString *versionString;

@property (nonatomic, readonly) NSDictionary *sysInfo;

@property (nonatomic, readonly) NSFetchedResultsController *mediaFrc;

+ (SAGSyncManager *)sharedClient;

- (void)synchronizeAll;
- (void)continueSynchronization;
- (void)cancelSynchronization;

- (void)addErrorWithMessage:(NSString *)message andUserInfo:(NSDictionary *)userInfo;

- (void)getAllMedia;
- (void)cancelMediaDownload;

- (void)push:(NSManagedObject *)object;
- (void)saveForTransfer:(NSManagedObject *)object;
- (void)prepareForDelete:(NSManagedObject *)object;

- (void)trySendingFilesInBackground:(bool)inBackground;

@end
