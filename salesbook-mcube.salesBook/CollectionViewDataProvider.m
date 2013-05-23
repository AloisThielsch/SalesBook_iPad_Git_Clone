//
//  DataProvider.m
//  SalesBook
//
//  Created by Julian Knab on 28.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "CollectionViewDataProvider.h"

#import "SmallCardCell.h"
#import "LongRowCell.h"

#import "SBItem+Extensions.h"

#import "SAGImageRenderManager.h"

@implementation CollectionViewDataProvider

- (id)initWithItems:(NSArray *)items andSortIdentifier:(NSString *)sortIdentifier
{
    [[SAGImageRenderManager sharedManager] setDelegate:self];
    [[SAGImageRenderManager sharedManager] setCacheEnabled:YES];
    
    NSObject *firstItem = items[0];
    NSString *className = [[firstItem class] description];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:sortIdentifier ascending:YES];
    NSArray *sortDesriptors = [NSArray arrayWithObject:sortDescriptor];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self in %@", items];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:className];
    
    [fetchRequest setFetchBatchSize:30];
    
    [fetchRequest setSortDescriptors:sortDesriptors];
    
    [fetchRequest setPredicate:predicate];
    NSManagedObjectContext *managedObjectContext = [NSManagedObjectContext MR_contextForCurrentThread];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];
    return self;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell;

    switch (self.layoutStyle)
    {
        case 0:
        case 1:
            cell = (SmallCardCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"SmallCardCell" forIndexPath:indexPath];
            cell = [self prepareSmallCard:(SmallCardCell *)cell forCellAtIndexPath:indexPath inCollectionView:collectionView];
            break;
        case 2:
            cell = (LongRowCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"LongRowCell" forIndexPath:indexPath];
            cell = [self prepareLongRow:(LongRowCell *)cell forCellAtIndexPath:indexPath inCollectionView:collectionView];
            break;
        default:
            break;
    }

    return cell;
}

- (UICollectionViewCell *)prepareSmallCard:(SmallCardCell *)cell forCellAtIndexPath:(NSIndexPath *)indexPath inCollectionView:(UICollectionView *)collectionView
{
    if (self.displayEntity == DisplayEntityVariant) //TODO: Anpassungen an Data Provider in Absprache mit Julian
    {
        SBItem *item = [self getItemAtIndexPath:indexPath];
        SBVariant *variant = [item getDefaultVariant];
        
        cell.imageView.image = [[SAGImageRenderManager sharedManager] imageRequestWithVariant:variant withImageRendererType:ImageRendererCellTypeSmallCell atIndexPath:indexPath inCollectionView:collectionView];
        
        return cell;
    }

    cell.imageView.image = nil;
    
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);

        dispatch_async(queue, ^(void)
        {
            UIImage *imageSmallCard = [self prepareImageForSmallCardCellAtIndexPath:indexPath];

            dispatch_sync(dispatch_get_main_queue(), ^{

                [self updateImage:imageSmallCard withCellType:ImageRendererCellTypeSmallCell atIndexPath:indexPath inCollectionView:collectionView];
            });
        });

    return cell;
}

- (UICollectionViewCell *)prepareLongRow:(LongRowCell *)cell forCellAtIndexPath:(NSIndexPath *)indexPath inCollectionView:(UICollectionView *)collectionView
{
    if (self.displayEntity == DisplayEntityVariant) //TODO: Anpassungen an Data Provider in Absprache mit Julian
    {
        SBItem *item = [self getItemAtIndexPath:indexPath];
        SBVariant *variant = [item getDefaultVariant];
        
        cell.imageView.image = [[SAGImageRenderManager sharedManager] imageRequestWithVariant:variant withImageRendererType:ImageRendererCellTypeLongCell atIndexPath:indexPath inCollectionView:collectionView];
        
        return cell;
    }

    cell.imageView.image = nil;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);

    dispatch_async(queue, ^(void)
    {
        UIImage *imageLongRow = [self prepareImageForLongRowCellAtIndexPath:indexPath];

        dispatch_sync(dispatch_get_main_queue(), ^{

            [self updateImage:imageLongRow withCellType:ImageRendererCellTypeLongCell atIndexPath:indexPath inCollectionView:collectionView];
        });
    });
    
    return cell;
}

- (UIImage *)prepareImageForSmallCardCellAtIndexPath:(NSIndexPath *)indexPath
{
    // needs to be overridden in derived classes!
    return nil;
}

- (UIImage *)prepareImageForLongRowCellAtIndexPath:(NSIndexPath *)indexPath
{
    // needs to be overridden in derived classes!
    return nil;
}

- (id)getItemAtIndexPath:(NSIndexPath *)indexPath
{
    id item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return item;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    int count = self.fetchedResultsController.fetchedObjects.count;
    return count;
}

- (int)displayEntity
{
    // needs to be overridden in derived classes!
    return -1;
}

#pragma mark -
#pragma mark SAGRenderManagerDelegate

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [[SAGImageRenderManager sharedManager] cancelImageRequestForCollectionView:collectionView IndexPath:indexPath];
}

- (void)updateImage:(UIImage *)image withCellType:(enum ImageRendererCellType)cellType atIndexPath:(NSIndexPath *)indexPath inCollectionView:(UICollectionView *)collectionView
{    
    SmallCardCell *cellWithNewlyPreparedImage = (SmallCardCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cellWithNewlyPreparedImage.imageView.image = image;
}

@end