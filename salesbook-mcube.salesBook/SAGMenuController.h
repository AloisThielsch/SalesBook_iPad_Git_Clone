//
//  SAGMenuController.h
//  SalesBook
//
//  Created by Andreas Kucher on 26.02.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SBCustomer.h"

@protocol SAGMenuControllerDelegate <NSObject>

- (void)menuControllerRefreshSelectedCustomerDisplayWithCustomer:(SBCustomer *)customer;

@end

@interface SAGMenuController : NSObject

@property (nonatomic, weak) id  delegate;

@property (nonatomic, readonly) NSArray *defaultMenuItems;
@property (nonatomic, readonly) NSArray *customerMenuItems;
@property (nonatomic, readonly) NSArray *documentMenuItems;
@property (nonatomic, readonly) NSString *customerUniqueID;

+ (SAGMenuController *)defaultController;

- (void)setCustomer:(SBCustomer *)customer;
- (SBCustomer *)customer;

@end
