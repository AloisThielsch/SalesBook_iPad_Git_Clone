//
//  ItemDetailVariantViewController.h
//  SalesBook
//
//  Created by Frank Wittmann on 22.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SBVariant+Extensions.h"

@interface ItemDetailVariantViewController : UICollectionViewController

@property (nonatomic, strong) SBVariant *variant;

@end
