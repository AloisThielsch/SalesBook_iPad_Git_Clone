//
//  SBSalesOrganization.h
//  SalesBook
//
//  Created by Andreas Kucher on 22.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SBPriceGroup;

@interface SBSalesOrganization : NSManagedObject

@property (nonatomic, retain) NSNumber * activeState;
@property (nonatomic, retain) NSDate * alternationDate;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSString * defaultPriceGroup;
@property (nonatomic, retain) NSNumber * documentState;
@property (nonatomic, retain) NSString * salesOrganizationDenotaion;
@property (nonatomic, retain) NSString * salesOrganizationNumber;
@property (nonatomic, retain) NSDate * transferDate;
@property (nonatomic, retain) NSNumber * transferState;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) SBPriceGroup *priceGroup;

@end
