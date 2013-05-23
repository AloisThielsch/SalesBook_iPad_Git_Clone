//
//  SBPrice.h
//  SalesBook
//
//  Created by Andreas Kucher on 22.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SBPriceGroup, SBVariant;

@interface SBPrice : NSManagedObject

@property (nonatomic, retain) NSNumber * activeState;
@property (nonatomic, retain) NSDate * alternationDate;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSString * currency;
@property (nonatomic, retain) NSNumber * documentState;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSNumber * price2;
@property (nonatomic, retain) NSString * priceGroupNumber;
@property (nonatomic, retain) NSNumber * recommendedPrice;
@property (nonatomic, retain) NSDate * transferDate;
@property (nonatomic, retain) NSNumber * transferState;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSString * variantNumber;
@property (nonatomic, retain) SBPriceGroup *priceGroup;
@property (nonatomic, retain) SBVariant *variant;

@end
