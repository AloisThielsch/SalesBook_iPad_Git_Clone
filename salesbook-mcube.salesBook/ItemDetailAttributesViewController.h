//
//  ItemDetailAttributesViewController.h
//  SalesBook
//
//  Created by Frank Wittmann on 22.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SAGCustomFieldProvider.h"

#import "SBVariant+Extensions.h"

@interface ItemDetailAttributesViewController : UITableViewController

@property (nonatomic, strong) SBVariant *variant;
@property (weak, nonatomic) IBOutlet SAGCustomFieldProvider *customFieldProvider;

@end
