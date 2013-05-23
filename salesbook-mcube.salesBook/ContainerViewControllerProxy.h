//
//  ContainerViewControllerProxy.h
//  SalesBook
//
//  Created by Frank Wittmann on 17.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomerSelectorViewController.h"

@interface ContainerViewControllerProxy : UIViewController

@property (nonatomic, weak) CustomerSelectorViewController *owningViewController;

- (void)switchToViewControllerWithSegueIdentifier:(NSString *)segueIdentifier;

@end
