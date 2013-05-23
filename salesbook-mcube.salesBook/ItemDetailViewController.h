//
//  ItemDetailViewController.h
//  SalesBook
//
//  Created by Frank Wittmann on 22.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SBVariant+Extensions.h"

#import "DragDropCraneDelegate.h"

@interface ItemDetailViewController : UIViewController<DragDropCraneDelegate>

@property (nonatomic, strong) SBVariant *variant;

+ (ItemDetailViewController *)itemDetailViewController;

@end
