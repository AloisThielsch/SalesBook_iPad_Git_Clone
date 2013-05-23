//
//  ViewController.h
//  IntroducingCollectionViews
//
//  Created by Mark Pospesel on 10/4/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CollectionViewDataProvider.h"

#import "CatalogsAndCartsViewController.h"

#import "DragDropCraneDelegate.h"

enum
{
    LayoutStyleGrid,
    LayoutStyleLine,
    LayoutStyleList,
    
    LayoutStyleCount
}
typedef LayoutStyle;

@interface NiceLayoutsViewController : UICollectionViewController

@property (nonatomic, assign, readonly) LayoutStyle layoutStyle;
@property (nonatomic, assign, readonly) CollectionViewDataProvider *dataProvider;

@property (nonatomic, assign) id<DragDropCraneDelegate> delegate;

- (void)setLayoutStyle:(LayoutStyle)layoutStyle animated:(BOOL)animated;

- (void)btnBackTapped;
- (void)btnUpTapped;
- (void)btnDownTapped;

@end