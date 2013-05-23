//
//  DataProvider.h
//  SalesBook
//
//  Created by Julian Knab on 28.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SAGImageRenderManager.h"

enum
{
    DisplayEntityCatalog,
    DisplayEntityItemGroup,
    DisplayEntityVariant,
    
    DisplayEntityCount
}
typedef DisplayEntity;

@class SmallCardCell, LongRowCell;

@interface CollectionViewDataProvider : NSObject <UICollectionViewDataSource, UICollectionViewDelegate, SAGImageRenderManagerDelegate>

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property int layoutStyle;

- (id)initWithItems:(NSArray *)items andSortIdentifier:(NSString *)sortIdentifier;

- (id)getItemAtIndexPath:(NSIndexPath *)indexPath;

- (int)displayEntity;

- (UICollectionViewCell *)prepareSmallCard:(SmallCardCell *)cell forCellAtIndexPath:(NSIndexPath *)indexPath inCollectionView:(UICollectionView *)collectionView;
- (UICollectionViewCell *)prepareLongRow:(LongRowCell *)cell forCellAtIndexPath:(NSIndexPath *)indexPath inCollectionView:(UICollectionView *)collectionView;

- (UIImage *)prepareImageForSmallCardCellAtIndexPath:(NSIndexPath *)indexPath;
- (UIImage *)prepareImageForLongRowCellAtIndexPath:(NSIndexPath *)indexPath;

@end