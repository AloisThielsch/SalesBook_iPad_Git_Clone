//
//  SAGImageRenderManager.m
//  SalesBook
//
//  Created by Andreas Kucher on 11.05.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SAGImageRenderManager.h"

@interface SAGImageRenderManager ()

@property (nonatomic, strong) PendingOperations *pendingOperations;
@property (nonatomic, strong) NSCache *imageCache;

@end

@implementation SAGImageRenderManager

+ (SAGImageRenderManager *)sharedManager
{
    static SAGImageRenderManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[SAGImageRenderManager alloc] init];
    });
    
    return _sharedManager;
}

- (id)init
{
    self = [super init];
    if (!self)
    {
        return nil;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(memoryWarningRecived) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteImageCache:) name:notificationMediaDownloadStateChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteImageCache:) name:notificationLogoutSuccessful object:nil];
    
    return self;
}

#pragma mark - PendingOperations

- (NSCache *)imageCache
{
    if (!_imageCache)
    {
        _imageCache = [[NSCache alloc] init];
        _imageCache.countLimit = 100;
    }
    
    return _imageCache;
}

- (PendingOperations *)pendingOperations
{
    if (!_pendingOperations)
    {
        _pendingOperations = [[PendingOperations alloc] init];
    }
    
    return _pendingOperations;
}

- (ImageRenderer *)imageRendererWithIndextPath:(NSIndexPath *)indexPath
{
    if ([[[SAGImageRenderManager sharedManager] pendingOperations].renderInProgress.allKeys containsObject:indexPath])
        return [[[SAGImageRenderManager sharedManager] pendingOperations].renderInProgress objectForKey:indexPath];
    
    return nil;
}

- (void)addImageRenderer:(ImageRenderer *)imageRenderer
{
    if (imageRenderer == nil || [self imageRendererWithIndextPath:imageRenderer.indexPath] != nil) return;

    [[[SAGImageRenderManager sharedManager] pendingOperations].renderInProgress setObject:imageRenderer forKey:imageRenderer.indexPath];
    [[[SAGImageRenderManager sharedManager] pendingOperations].renderQueue addOperation:imageRenderer];
}

- (void)removeImageRendererWithIndextPath:(NSIndexPath *)indexPath
{    
    ImageRenderer *imageRenderer = [self imageRendererWithIndextPath:indexPath];
    
    if (imageRenderer == nil) return;
    
    [imageRenderer cancel];
    
    [[[SAGImageRenderManager sharedManager] pendingOperations].renderInProgress removeObjectForKey:indexPath];
}

#pragma mark class methods

- (void)cancelImageRequestForCollectionView:(UICollectionView *)collectionView IndexPath:(NSIndexPath *)indexPath
{
    [[SAGImageRenderManager sharedManager] removeImageRendererWithIndextPath:indexPath];
}

- (UIImage *)imageRequestWithVariant:(SBVariant *)variant withImageRendererType:(enum ImageRendererCellType)cellType atIndexPath:(NSIndexPath *)indexPath inCollectionView:(UICollectionView *)collectionView
{
    UIImage *cachedImage = [self imageFromCacheForVariant:variant withImageRendererType:cellType];
    
    if (cachedImage)
    {
        return cachedImage;
    }
    
    ImageRenderer *imageRenderer = [[ImageRenderer alloc] initWithVariant:variant withImageRendererType:cellType atIndexPath:indexPath inCollectionView:(UICollectionView *)collectionView delegate:self];
    
    [[SAGImageRenderManager sharedManager] addImageRenderer:imageRenderer];
    
    return nil;
}

#pragma mark - imageDelegate Proxy

- (void)imageRendererDidFinish:(ImageRenderer *)renderer
{
    if (renderer.collectionView != nil && renderer.indexPath != nil)
    {
        [_delegate updateImage:renderer.image withCellType:renderer.rendererType atIndexPath:renderer.indexPath inCollectionView:renderer.collectionView];
    }
    
    if (self.isCacheEnabled && renderer.image != nil)
    {
        [[SAGImageRenderManager sharedManager].imageCache setObject:renderer.image forKey:[NSString stringWithFormat:@"%@-%u", renderer.variant.uniqueID, renderer.rendererType]];
    }
    
    [[SAGImageRenderManager sharedManager] removeImageRendererWithIndextPath:renderer.indexPath];
}


#pragma mark - cache

- (BOOL)isCacheEnabled
{
    return _cacheEnabled;
}

- (UIImage *)imageFromCacheForVariant:(SBVariant *)variant withImageRendererType:(enum ImageRendererCellType)cellType
{
    if (!self.isCacheEnabled) return nil;
    
    return [[SAGImageRenderManager sharedManager].imageCache objectForKey:[NSString stringWithFormat:@"%@-%u", variant.uniqueID, cellType]];
}

#pragma mark - Memory Management

- (void)memoryWarningRecived
{
    [SAGImageRenderManager sharedManager].imageCache = nil;
    [[[SAGImageRenderManager sharedManager] pendingOperations].renderQueue cancelAllOperations];
}

- (void)deleteImageCache:(NSNotification *)notification
{
    if ([notification.object boolValue] == YES)
    {
        [[SAGImageRenderManager sharedManager].imageCache removeAllObjects];
    }
}

#pragma mark - Manage Queue

- (void)suspendAllOperations
{
    [[[SAGImageRenderManager sharedManager] pendingOperations].renderQueue setSuspended:YES];
}

- (void)resumeAllOperations
{
    [[[SAGImageRenderManager sharedManager] pendingOperations].renderQueue setSuspended:NO];
}

- (void)cancelAllOperations
{
    [[[SAGImageRenderManager sharedManager] pendingOperations].renderQueue cancelAllOperations];
}

@end
