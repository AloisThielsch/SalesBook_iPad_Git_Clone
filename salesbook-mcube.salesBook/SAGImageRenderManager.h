//
//  SAGImageRenderManager.h
//  SalesBook
//
//  Created by Andreas Kucher on 11.05.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PendingOperations.h"
#import "ImageRenderer.h"

@protocol SAGImageRenderManagerDelegate <NSObject>

- (void)updateImage:(UIImage *)image withCellType:(enum ImageRendererCellType)cellType atIndexPath:(NSIndexPath *)indexPath inCollectionView:(UICollectionView *)collectionView;

@end

@interface SAGImageRenderManager : NSObject <ImageRendererDelegate>

@property (nonatomic, assign) id <SAGImageRenderManagerDelegate> delegate;
@property (nonatomic, getter = isCacheEnabled) BOOL cacheEnabled;

+ (SAGImageRenderManager *)sharedManager;

- (void)cancelImageRequestForCollectionView:(UICollectionView *)collectionView IndexPath:(NSIndexPath *)indexPath;
- (UIImage *)imageRequestWithVariant:(SBVariant *)variant withImageRendererType:(enum ImageRendererCellType)cellType atIndexPath:(NSIndexPath *)indexPath inCollectionView:(UICollectionView *)collectionView; //Returns cached image if already rendered!

- (void)suspendAllOperations;
- (void)resumeAllOperations;
- (void)cancelAllOperations;

@end
