//
//  SAGMenuController.m
//  SalesBook
//
//  Created by Andreas Kucher on 26.02.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SAGMenuController.h"
#import "SAGLoginManager.h"

#import "SBDocumentType+Extensions.h"

#import "SBCustomer+Extensions.h"
#import "SBDocument+Extensions.h"
#import "SBCatalog+Extensions.h"

#import "TDBadgedCell.h"

@implementation SAGMenuController

+ (SAGMenuController *)defaultController {
    
    static SAGMenuController *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[SAGMenuController alloc] init];
    });
    
    return _sharedManager;
}

- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginMessageRecived) name:notificationLoginSuccessful object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutMessageRecived) name:notificationLogoutSuccessful object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:notificationOfflineFilesChanged object:nil];
    
    return self;
}

- (void)setCustomer:(SBCustomer *)customer
{
    _customerUniqueID = customer.uniqueID;
    
    [self reloadData];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationCustomerFilterChanged object:self.customer];
}

- (SBCustomer *)customer
{
    if (_customerUniqueID == nil)
    {
        return nil;
    }
    
    return [SBCustomer getCustomerWithUniqueID:self.customerUniqueID];
}

- (void)reloadData
{
    [_delegate performSelectorOnMainThread:@selector(menuControllerRefreshSelectedCustomerDisplayWithCustomer:) withObject:self.customer waitUntilDone:YES];
}

#pragma mark - Automated Stuff

- (void)loginMessageRecived
{
    _customerUniqueID = nil;
    
    [self reloadData];
}

- (void)logoutMessageRecived
{
    [self setCustomer:nil]; //Filter zurücksetzen
}

#pragma mark - internal stuff

- (NSArray *)customerMenuItems
{
    NSMutableArray *menuItems = [NSMutableArray new];
    
    if ([[SAGLoginManager sharedManger] isDatabaseOpen])
    {
        if (self.customer)
        {
            if ( (self.customer.noOfAdresses > 0) | [[[SAGSettingsManager sharedManager] settingForKey:@"isCreatingNewAdressesAllowed" withDefaultValue:@NO] boolValue])
            {
                NSString *identifier = @"AddressView";
                NSString *menuTitle = NSLocalizedString(@"Addresses", @"Addresses menu title");
                NSNumber *badgeValue = [NSNumber numberWithUnsignedInt:self.customer.noOfAdresses];
                
                [menuItems addObject:[self getMenuItemWithIdentifier:identifier andLabel:menuTitle optionalNumberOfObjects:badgeValue optionalDocumentType:nil optionalImage:@"flag.png"]];
            }
            
            if ( (self.customer.contacts.count > 0) | [[[SAGSettingsManager sharedManager] settingForKey:@"isCreatingNewContactsAllowed" withDefaultValue:@NO] boolValue])
            {
                NSString *identifier = @"ContactsView";
                NSString *menuTitle = NSLocalizedString(@"Contacts", @"Contacts menu title");
                NSNumber *badgeValue = [NSNumber numberWithUnsignedInt:self.customer.contacts.count];
                
                [menuItems addObject:[self getMenuItemWithIdentifier:identifier andLabel:menuTitle optionalNumberOfObjects:badgeValue optionalDocumentType:nil optionalImage:@"users.png"]];
            }
            
            if (self.customer.mediaFiles.count > 0)
            {
                NSString *identifier = @"Attachments";
                NSString *menuTitle = NSLocalizedString(@"Attachments", @"Attachments menu title");
                NSNumber *badgeValue = [NSNumber numberWithUnsignedInt:self.customer.mediaFiles.count];
                
                [menuItems addObject:[self getMenuItemWithIdentifier:identifier andLabel:menuTitle optionalNumberOfObjects:badgeValue optionalDocumentType:nil optionalImage:@"paper-clip.png"]];
            }
        }
    }
    
    return menuItems;
}

- (NSArray *)documentMenuItems
{
    NSMutableArray *menuItems = [NSMutableArray new];
    
    if ([[SAGLoginManager sharedManger] isDatabaseOpen])
    {
        for (NSDictionary *dict in [SBDocument numberOfDocumentsGroupByDocumentTypeWithCustomer:self.customer])
        {
            NSString *identifier = @"Documents";
            NSString *menuTitle = [SBDocumentType  getDenoationWith:[[dict valueForKey:@"documentType"] integerValue] andLangauge:[[SAGSettingsManager sharedManager] itemDisplayLanguage]];
            NSNumber *badgeValue = [dict valueForKey:@"numberOfDocuments"];
            NSString *documentType = [[dict valueForKey:@"documentType"] stringValue];
            
            [menuItems addObject:[self getMenuItemWithIdentifier:identifier andLabel:menuTitle optionalNumberOfObjects:badgeValue optionalDocumentType:documentType optionalImage:@"shopping-cart.png"]];
        }
    }
    
    return menuItems;
}

- (NSArray *)defaultMenuItems
{
    NSMutableArray *menuItems = [NSMutableArray new];
    
    NSNumber *noOfCatalogs;
    
    if ([[SAGLoginManager sharedManger] isDatabaseOpen])
    {
        noOfCatalogs = [SBCatalog MR_numberOfEntities];
    }
    
    if (noOfCatalogs.intValue > 0) [menuItems addObject:[self getMenuItemWithIdentifier:@"Catalogs" andLabel:NSLocalizedString(@"Catalogs", @"Catalogs menu title") optionalNumberOfObjects:noOfCatalogs optionalDocumentType:nil optionalImage:@"image.png"]];
    
    [menuItems addObject:[self getMenuItemWithIdentifier:@"LoginView" andLabel:NSLocalizedString(@"User manager", @"UserManager menu title") optionalNumberOfObjects:nil optionalDocumentType:nil optionalImage:@"lock.png"]];
    
    int offlineFiles = [[UIApplication sharedApplication] applicationIconBadgeNumber];
    
    if (offlineFiles > 0)
    {
        [menuItems addObject:[self getMenuItemWithIdentifier:@"SendFiles" andLabel:NSLocalizedString(@"Offline Files", @"Transfer Offline Files menu title") optionalNumberOfObjects:[NSNumber numberWithInt:offlineFiles] optionalDocumentType:nil optionalImage:@"hard-drive-upload.png"]];
    }

    return menuItems;
}

#pragma mark - internal Stuff

- (NSDictionary *)getMenuItemWithIdentifier:(NSString *)identifier andLabel:(NSString *)label optionalNumberOfObjects:(NSNumber *)numberOfObjects optionalDocumentType:(NSString *)documentType optionalImage:(NSString *)image;
{
    if (numberOfObjects == nil)
    {
        numberOfObjects = [NSNumber numberWithInt:0];
    }

    if (documentType == nil)
    {
        documentType = @"";
    }

    if (image == nil)
    {
        image = @"";
    }
    
    return @{@"label": label, @"identifier": identifier, @"image": image, @"numberOfObjects": numberOfObjects, @"documentType": documentType};
}

@end
