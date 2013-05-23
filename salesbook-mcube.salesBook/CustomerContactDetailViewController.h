//
//  CustomerContactDetailViewController.h
//  SalesBook
//
//  Created by Frank Wittmann on 29.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SBContact+Extensions.h"

@interface CustomerContactDetailViewController : UIViewController

@property (nonatomic, strong) SBContact *contact;

@end
