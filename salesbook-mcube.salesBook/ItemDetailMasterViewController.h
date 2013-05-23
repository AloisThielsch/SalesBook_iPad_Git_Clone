//
//  ItemDetailMasterViewController.h
//  SalesBook
//
//  Created by Frank Wittmann on 22.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SBVariant+Extensions.h"

#import "DragDropCrane.h"

@interface ItemDetailMasterViewController : UIViewController

@property (nonatomic, strong) SBVariant *variant;
@property (nonatomic) id<DragDropCraneDelegate> delegate;

@property (nonatomic, readonly) UIImage *currentImage;
@property (nonatomic, readonly) SBVariant *currentVariant;

@end
