//
//  ShoppingCartOverviewViewController.h
//  SalesBook
//
//  Created by Julian Knab on 13.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CatalogsAndCartsViewController, SBShoppingCart;

@interface ShoppingCartOverviewViewController : UICollectionViewController <UIActionSheetDelegate>

@property (nonatomic, assign) id delegate;

- (SBShoppingCart *)getCartAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)getIndexPathForCart:(SBShoppingCart *)shoppingCart;

@end