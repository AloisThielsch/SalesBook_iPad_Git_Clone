//
//  CustomerAddressDetailViewController.h
//  SalesBook
//
//  Created by Frank Wittmann on 29.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SBAddress+Extensions.h"

@interface CustomerAddressDetailViewController : UIViewController

@property (nonatomic, strong) SBAddress *address;

@end
