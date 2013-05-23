//
//  CustomerContactCollectionViewController.h
//  SalesBook
//
//  Created by Frank Wittmann on 29.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SBCustomer+Extensions.h"

@interface CustomerContactCollectionViewController : UICollectionViewController

@property (nonatomic, strong) SBCustomer *customer;

@end
