//
//  SAGHelper.h
//  SalesBook
//
//  Created by Andreas Kucher on 14.12.12.
//  Copyright (c) 2012 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CoreData+MagicalRecord.h"

#import "SAGSettingsManager.h"
#import "SBFilter+Extensions.h"

#import "NSNumber+CurrencyRound.h"
#import "NSNumber+PercentValue.h"
#import "NSString+Extensions.h"
#import "NSDate+Extensions.h"
#import "NSString+Crypt.h"

#import "SAGAppDelegate.h"

enum SAGAddressType {
    SAGAddressTypePrimaryAddress = 0,
    SAGAddressTypeDeliveryAddress = 1,
    SAGAddressTypeInvoiceAddress = 2,
    SAGAddressTypeContactAddress = 3,
    SAGAddressTypeOtherAddress = 99
};

enum SAGConnectionState {
    SAGConnectionStateWLAN = 2,
    SAGConnectionStateMobile = 1,
    SAGConnectionStateNotConnected = 0,
    SAGConnectionStateUnknown = -1
};

enum SAGDocumentType {
    SAGDocumentTypeOffer = 10,
    SAGDocumentTypePurchaseOrder = 15,
    SAGDocumentTypeOrder = 20,
    SAGDocumentTypeReturn = 25,
    SAGDocumentTypeShoppingCart = 30,
    SAGDocumentTypeTemplate = 35,
    SAGDocumentTypeVisitReport = 40,
    SAGDocumentTypeInvoice = 50,
    SAGDocumentTypeCancellation = 60,
    SAGDocumentTypeInventory = 80,
    SAGDocumentTypeLogbook = 99,
    SAGDocumentTypeCustomer = 1000,
    SAGDocumentTypeContact = 1010,
    SAGDocumentTypeAddress = 1020
};

enum SAGMediaType {
    SAGMediaTypeSmall = 1,
    SAGMediaTypeMedium = 2,
    SAGMediaTypeLarge = 3
};

enum SAGActiveState {
    SAGActiveStateActive = 1,
    SAGActiveStateDeleted = 2
};


enum SAGTransferState {
    SAGTransferStateLocal = 1,
    SAGTransferStateQueued = 2,
    SAGTransferStateDelivered = 3,
    SAGTransferStateError = 4
};


enum SAGDocumentState {
    SAGDocumentStateNew = 1,
    SAGDocumentStateAltered = 2,
    SAGDocumentStateCommited = 3
};


enum SAGItemType {
    SAGItemTypeNormal = 1,
    SAGItemTypeVariant = 3,
    SAGItemTypeSet = 4
};

enum SAGItemKind {
    SAGItemKindDefault = 1,
    SAGItemKindDummy = 2
};

enum SAGResponseCode {
    SAGResponseCodeSuccess = 0,
    SAGResponseCodeErrorMessage = 10000
    };

enum SAGDownloadPriority {
    SAGDownloadPriorityNow = 1, //A
    SAGDownloadPriorityLater = 2, //B
    SAGDownloadPriorityOnCommand = 3 //C
};

enum SAGCustomFieldType {
    SAGCustomFieldTypeText = 0,
    SAGCustomFieldTypeSelect = 2, 
    SAGCustomFieldTypeMultiSelect = 3,
    SAGCustomFieldTypeBool = 4,
    SAGCustomFieldTypeDate = 5
};

enum SAGCustomFieldDetailLevel {
    SAGCustomFieldDetailAll = 0,
    SAGCustomFieldDetailList = 1,
    SAGCustomFieldDetailDetail = 2
};

#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

@interface SAGHelper : NSObject

+ (NSString *)applicationDocumentsDirectory;
+ (NSString *)applicationPrivateDocumentsDirectory;

+ (NSString *)applicationLogDirectory;

+ (bool)createDirectoryAtPath:(NSString *)path;

+ (bool)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;

+ (NSString *)getAppVersion;

+ (void)playSound:(NSString *)name withExtension:(NSString *)extension;

#pragma mark - xml report

+ (void)sendReportWithMessage:(NSString *)errorMessage withDictionary:(NSDictionary *)userInfo andScreenshot:(UIImage *)screenshot includeLog:(BOOL)includeLog;

+ (UIImage *)takeScreenshot;

@end
