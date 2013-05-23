//
//  HorizontalTabController.h
//  SalesBook
//
//  Created by Frank Wittmann on 17.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HorizontalTabController;

@protocol HorizontalTabControllerDelegate<NSObject>
- (void)horizontalTabController:(HorizontalTabController *)tabController didSelectTabWithTitle:(NSString *)title segueIdentifier:(NSString *)segueIdentifier;
@end

@interface HorizontalTabController : UIViewController

@property (nonatomic) id<HorizontalTabControllerDelegate> horizontalTabControllerDelegate;

- (void)addTabWithTitle:(NSString *)title forSegueIdentifier:(NSString *)segueIdentifier;

@end
