//
//  SBPriceGroup.h
//  SalesBook
//
//  Created by Andreas Kucher on 22.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SBCustomer, SBPrice, SBSalesOrganization;

@interface SBPriceGroup : NSManagedObject

@property (nonatomic, retain) NSString * priceGroupNumber;
@property (nonatomic, retain) NSSet *customers;
@property (nonatomic, retain) NSSet *prices;
@property (nonatomic, retain) SBSalesOrganization *salesOrganization;
@end

@interface SBPriceGroup (CoreDataGeneratedAccessors)

- (void)addCustomersObject:(SBCustomer *)value;
- (void)removeCustomersObject:(SBCustomer *)value;
- (void)addCustomers:(NSSet *)values;
- (void)removeCustomers:(NSSet *)values;

- (void)addPricesObject:(SBPrice *)value;
- (void)removePricesObject:(SBPrice *)value;
- (void)addPrices:(NSSet *)values;
- (void)removePrices:(NSSet *)values;

@end
