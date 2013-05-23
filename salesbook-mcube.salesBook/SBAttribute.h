//
//  SBAttribute.h
//  SalesBook
//
//  Created by Andreas Kucher on 22.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SBAddress, SBCatalog, SBContact, SBCustomField, SBCustomer, SBDocument, SBDocumentPosition, SBItem, SBItemGroup, SBMedia, SBSelectionOption, SBVariant;

@interface SBAttribute : NSManagedObject

@property (nonatomic, retain) NSString * language;
@property (nonatomic, retain) NSString * theKey;
@property (nonatomic, retain) id theValue;
@property (nonatomic, retain) SBAddress *address;
@property (nonatomic, retain) SBCatalog *catalog;
@property (nonatomic, retain) SBContact *contact;
@property (nonatomic, retain) SBCustomer *customer;
@property (nonatomic, retain) SBCustomField *customField;
@property (nonatomic, retain) SBDocument *document;
@property (nonatomic, retain) SBDocumentPosition *documentPosition;
@property (nonatomic, retain) SBItem *item;
@property (nonatomic, retain) SBItemGroup *itemGroup;
@property (nonatomic, retain) SBMedia *mediaFile;
@property (nonatomic, retain) SBSelectionOption *selectionOption;
@property (nonatomic, retain) SBVariant *variant;

@end
