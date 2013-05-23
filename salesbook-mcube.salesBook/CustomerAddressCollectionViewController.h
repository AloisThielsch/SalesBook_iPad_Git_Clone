//
//  CustomerAddressCollectionViewController.h
//  SalesBook
//
//  Created by Frank Wittmann on 26.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SBCustomer+Extensions.h"

@interface CustomerAddressCollectionViewController : UICollectionViewController

@property (nonatomic, strong) SBCustomer *customer;

- (SBAddress *)addressAtIndexPath:(NSIndexPath *)indexPath;
- (NSArray *)selectedAddresses;

@end
